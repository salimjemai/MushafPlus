#!/usr/bin/env python3
"""Exports an openai-whisper checkpoint (see hf_to_openai.py) to the ONNX
files sherpa-onnx loads, with sherpa-onnx's own `scripts/whisper/export-onnx.py`
(Apache-2.0, fetched at a pinned tag by the workflow).

That script only accepts OpenAI's model names, so this driver imports it as
a module and points its `load_model` at our checkpoint; everything else (the
encoder/decoder graph, the metadata sherpa-onnx reads, the tokens file and the
int8 quantisation) is the upstream code, unmodified.

Usage: python3 export_sherpa.py --script export-onnx.py --checkpoint model.pt --name whisper-base-ar-quran

Writes, in the current directory: {name}-encoder.onnx, {name}-decoder.onnx,
{name}-encoder.int8.onnx, {name}-decoder.int8.onnx, {name}-tokens.txt.
"""

import argparse
import importlib.util
import sys

import torch
import whisper


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


if __name__ == "__main__":
    main()
