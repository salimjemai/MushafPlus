#!/usr/bin/env python3
"""Exports an openai-whisper checkpoint (see hf_to_openai.py) to the ONNX
files sherpa-onnx loads, with sherpa-onnx's own `scripts/whisper/export-onnx.py`
(Apache-2.0, fetched at a pinned tag by the workflow).

That script only accepts OpenAI's model names, so this driver imports it as
a module and points its `load_model` at our checkpoint; everything else (the
encoder/decoder graph, the metadata sherpa-onnx reads, the tokens file and the
int8 quantisation) is the upstream code, unmodified.

One addition: the upstream int8 pass quantises MatMul weights only and leaves
the token embedding table (n_vocab x n_text_state, 80 to 106 MB in fp32) as
most of the decoder file, because ONNX Runtime's dynamic quantiser does not
touch the Gather that reads it. `shrink_embedding` stores that table as
per-row int8 (scale per token, like per-channel weight quantisation) and
reads it back with Gather -> Cast -> Mul, which are plain ONNX ops; the int8
decoder is then produced from that graph.

Usage: python3 export_sherpa.py --script export-onnx.py --checkpoint model.pt --name whisper-base-ar-quran

Writes, in the current directory: {name}-encoder.onnx, {name}-decoder.onnx,
{name}-encoder.int8.onnx, {name}-decoder.int8.onnx, {name}-tokens.txt.
"""

import argparse
import importlib.util
import os
import sys

import numpy as np
import onnx
import torch
import whisper
from onnx import helper, numpy_helper
from onnxruntime.quantization import QuantType, quantize_dynamic


def shrink_embedding(src: str, dst: str, min_rows: int = 10000) -> None:
    """Rewrites the token-embedding Gather of the decoder at [src] to read a
    per-row int8 table and writes the result to [dst]."""
    model = onnx.load(src)
    graph = model.graph
    inits = {i.name: i for i in graph.initializer}
    uses = {}
    for node in graph.node:
        for name in node.input:
            uses[name] = uses.get(name, 0) + 1
    done = 0
    for node in list(graph.node):
        if node.op_type != "Gather" or node.input[0] not in inits:
            continue
        table = inits[node.input[0]]
        if table.data_type != onnx.TensorProto.FLOAT or len(table.dims) != 2 or table.dims[0] < min_rows:
            continue
        axis = next((a.i for a in node.attribute if a.name == "axis"), 0)
        if axis != 0:
            continue
        w = numpy_helper.to_array(table).astype(np.float32)
        scale = np.maximum(np.abs(w).max(axis=1), 1e-8) / 127.0
        q = np.clip(np.rint(w / scale[:, None]), -127, 127).astype(np.int8)
        base = node.input[0]
        q_name, s_name = f"{base}_int8", f"{base}_row_scale"
        graph.initializer.extend([numpy_helper.from_array(q, q_name), numpy_helper.from_array(scale.astype(np.float32), s_name)])
        out = node.output[0]
        gathered_q, gathered_s, gathered_f, scale_u = f"{out}_q", f"{out}_s", f"{out}_f", f"{out}_su"
        axes_name = f"{out}_unsq_axes"
        graph.initializer.append(numpy_helper.from_array(np.array([-1], dtype=np.int64), axes_name))
        new_nodes = [
            helper.make_node("Gather", [q_name, node.input[1]], [gathered_q], axis=0, name=f"{node.name}_int8"),
            helper.make_node("Cast", [gathered_q], [gathered_f], to=onnx.TensorProto.FLOAT, name=f"{node.name}_cast"),
            helper.make_node("Gather", [s_name, node.input[1]], [gathered_s], axis=0, name=f"{node.name}_scale"),
            helper.make_node("Unsqueeze", [gathered_s, axes_name], [scale_u], name=f"{node.name}_unsqueeze"),
            helper.make_node("Mul", [gathered_f, scale_u], [out], name=f"{node.name}_dequant"),
        ]
        idx = list(graph.node).index(node)
        graph.node.remove(node)
        for k, n in enumerate(new_nodes):
            graph.node.insert(idx + k, n)
        # The logits are x @ table.T: the exporter keeps that as a Transpose of
        # the same fp32 table, which the MatMul quantiser cannot touch (it only
        # quantises initializer weights). Fold the transpose into its own
        # initializer so the int8 pass picks it up and the fp32 table goes.
        folded = 0
        # torch.onnx inserts Identity nodes in front of shared initializers;
        # route their consumers to the table itself so the transpose is found.
        changed = True
        while changed:
            changed = False
            for ident in list(graph.node):
                if ident.op_type == "Identity" and list(ident.input) == [base]:
                    for consumer in graph.node:
                        for k, name in enumerate(consumer.input):
                            if name == ident.output[0]:
                                consumer.input[k] = base
                    graph.node.remove(ident)
                    changed = True
        for other in list(graph.node):
            if other.op_type == "Transpose" and list(other.input) == [base]:
                perm = next((list(a.ints) for a in other.attribute if a.name == "perm"), None)
                if perm not in (None, [1, 0]):
                    continue
                t_name = f"{base}_T"
                if t_name not in inits:
                    graph.initializer.append(numpy_helper.from_array(np.ascontiguousarray(w.T), t_name))
                    inits[t_name] = True
                for consumer in graph.node:
                    for k, name in enumerate(consumer.input):
                        if name == other.output[0]:
                            consumer.input[k] = t_name
                graph.node.remove(other)
                folded += 1
        # sherpa-onnx's exporter computes the logits as
        # matmul(table, x.permute(0, 2, 1)).permute(0, 2, 1): the table is the
        # left operand, which the MatMul quantiser leaves alone (it quantises
        # right-hand initializers). Rewrite that product as
        # transpose(matmul(transpose(x), table_T)), the same values; the
        # transposes cancel with their neighbours inside ONNX Runtime.
        for mm in list(graph.node):
            if mm.op_type != "MatMul" or mm.input[0] != base:
                continue
            y = mm.input[1]
            producer = next((n for n in graph.node if y in n.output), None)
            rank = 3
            if producer is not None and producer.op_type == "Transpose":
                rank = len(next(a.ints for a in producer.attribute if a.name == "perm"))
            perm = list(range(rank))
            perm[-1], perm[-2] = perm[-2], perm[-1]
            t_name = f"{base}_T"
            if t_name not in inits:
                graph.initializer.append(numpy_helper.from_array(np.ascontiguousarray(w.T), t_name))
                inits[t_name] = True
            y_t, pre = f"{y}_swapped", f"{mm.output[0]}_swapped"
            before = helper.make_node("Transpose", [y], [y_t], perm=perm, name=f"{mm.name}_swap_in")
            after = helper.make_node("Transpose", [pre], [mm.output[0]], perm=perm, name=f"{mm.name}_swap_out")
            mm.input[0] = y_t
            mm.input[1] = t_name
            mm.output[0] = pre
            pos = list(graph.node).index(mm)
            graph.node.insert(pos, before)
            graph.node.insert(pos + 2, after)
            folded += 1
        remaining = [n.name or n.op_type for n in graph.node if base in n.input]
        if not remaining:
            graph.initializer.remove(table)
        done += 1
        print(f"embedding {base}: {table.dims[0]} x {table.dims[1]} stored as per-row int8; transposes folded: {folded}; fp32 table still used by: {remaining}")
    if done != 1:
        raise SystemExit(f"expected one token-embedding Gather, rewrote {done}")
    onnx.checker.check_model(model)
    onnx.save(model, dst)


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--script", required=True, help="path to sherpa-onnx's scripts/whisper/export-onnx.py")
    p.add_argument("--checkpoint", required=True, help="openai-whisper .pt checkpoint")
    p.add_argument("--name", required=True, help="prefix of the output files")
    a = p.parse_args()
    if "large" in a.name or "turbo" in a.name:
        raise SystemExit("the name must not contain 'large' or 'turbo': the export script treats those specially")

    spec = importlib.util.spec_from_file_location("sherpa_whisper_export", a.script)
    mod = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = mod
    spec.loader.exec_module(mod)

    mod.get_args = lambda: argparse.Namespace(model=a.name)
    mod.load_model = lambda _name: whisper.load_model(a.checkpoint, device="cpu")

    torch.set_num_threads(1)
    torch.set_num_interop_threads(1)
    from whisper.model import disable_sdpa

    with disable_sdpa():
        mod.main()

    small = f"{a.name}-decoder.small-embedding.onnx"
    shrink_embedding(f"{a.name}-decoder.onnx", small)
    quantize_dynamic(
        model_input=small,
        model_output=f"{a.name}-decoder.int8.onnx",
        op_types_to_quantize=["MatMul"],
        weight_type=QuantType.QInt8,
    )
    os.remove(small)
    for f in sorted(os.listdir(".")):
        if f.startswith(a.name):
            print(f"{os.path.getsize(f) / 1e6:8.1f} MB  {f}")


if __name__ == "__main__":
    main()
