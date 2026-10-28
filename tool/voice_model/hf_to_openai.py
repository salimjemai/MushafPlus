#!/usr/bin/env python3
"""Converts a Hugging Face Whisper fine-tune (WhisperForConditionalGeneration,
`pytorch_model.bin` + `config.json`) into the checkpoint layout of the
openai-whisper package (`{"dims": ..., "model_state_dict": ...}`), which is
what sherpa-onnx's Whisper export script loads.

The weight names follow the mapping transformers uses in the other direction
(`convert_openai_to_hf.py`), reversed. Only the layout changes: the values
are the fine-tuned weights, untouched.

Usage: python3 hf_to_openai.py --config config.json --weights pytorch_model.bin --out model.pt
"""

import argparse
import json

import torch

# Hugging Face name fragment -> openai-whisper name fragment. Order matters:
# the attention projections must be renamed before "layers" -> "blocks" is
# harmless either way, but "encoder.layer_norm." has to be handled before the
# generic "layer_norm" fragments would be touched.
_RENAMES = [
    ("encoder.layer_norm.", "encoder.ln_post."),
    ("decoder.layer_norm.", "decoder.ln."),
    (".self_attn_layer_norm.", ".attn_ln."),
    (".encoder_attn_layer_norm.", ".cross_attn_ln."),
    (".final_layer_norm.", ".mlp_ln."),
    (".self_attn.q_proj.", ".attn.query."),
    (".self_attn.k_proj.", ".attn.key."),
    (".self_attn.v_proj.", ".attn.value."),
    (".self_attn.out_proj.", ".attn.out."),
    (".encoder_attn.q_proj.", ".cross_attn.query."),
    (".encoder_attn.k_proj.", ".cross_attn.key."),
    (".encoder_attn.v_proj.", ".cross_attn.value."),
    (".encoder_attn.out_proj.", ".cross_attn.out."),
    (".fc1.", ".mlp.0."),
    (".fc2.", ".mlp.2."),
    (".layers.", ".blocks."),
    ("decoder.embed_tokens.", "decoder.token_embedding."),
    ("encoder.embed_positions.weight", "encoder.positional_embedding"),
    ("decoder.embed_positions.weight", "decoder.positional_embedding"),
]


def rename(key: str) -> str:
    if key.startswith("model."):
        key = key[len("model.") :]
    for old, new in _RENAMES:
        key = key.replace(old, new)
    return key


def dims_from_config(cfg: dict) -> dict:
    return {
        "n_mels": cfg["num_mel_bins"],
        "n_audio_ctx": cfg["max_source_positions"],
        "n_audio_state": cfg["d_model"],
        "n_audio_head": cfg["encoder_attention_heads"],
        "n_audio_layer": cfg["encoder_layers"],
        "n_vocab": cfg["vocab_size"],
        "n_text_ctx": cfg["max_target_positions"],
        "n_text_state": cfg["d_model"],
        "n_text_head": cfg["decoder_attention_heads"],
        "n_text_layer": cfg["decoder_layers"],
    }


def convert(config_path: str, weights_path: str, out_path: str) -> None:
    with open(config_path, encoding="utf-8") as f:
        cfg = json.load(f)
    assert cfg.get("model_type") == "whisper", cfg.get("model_type")
    state = torch.load(weights_path, map_location="cpu")
    if "state_dict" in state and isinstance(state["state_dict"], dict):
        state = state["state_dict"]
    out = {}
    for key, value in state.items():
        if key == "proj_out.weight":
            continue  # tied to the token embedding; openai-whisper reuses it
        new_key = rename(key)
        assert new_key not in out, f"duplicate after rename: {key} -> {new_key}"
        out[new_key] = value.contiguous()
    dims = dims_from_config(cfg)

    # Make sure the result loads strictly into openai-whisper's module.
    from whisper.model import ModelDimensions, Whisper

    model = Whisper(ModelDimensions(**dims))
    # The encoder positions are fixed sinusoids; older transformers checkpoints
    # leave them out of the saved weights, so take them from the fresh module.
    sinusoids = "encoder.positional_embedding"
    if sinusoids not in out:
        out[sinusoids] = model.state_dict()[sinusoids].clone()
    missing, unexpected = model.load_state_dict(out, strict=False)
    if missing or unexpected:
        raise SystemExit(f"state dict mismatch: missing={missing} unexpected={unexpected}")
    torch.save({"dims": dims, "model_state_dict": out}, out_path)
    print(f"wrote {out_path}: {len(out)} tensors, dims={dims}")


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--config", required=True)
    p.add_argument("--weights", required=True)
    p.add_argument("--out", required=True)
    a = p.parse_args()
    convert(a.config, a.weights, a.out)


if __name__ == "__main__":
    main()
