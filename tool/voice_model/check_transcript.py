#!/usr/bin/env python3
"""Fails unless the transcript sherpa-onnx's test.py printed for Al-Fatiha 1
is vocalised Arabic with the expected words (so a broken export cannot be
released). Usage: check_transcript.py transcript.txt"""

import re
import sys

MARKS = "ًٌٍَُِّْٰ"

text = open(sys.argv[1], encoding="utf-8").read()
arabic = [l for l in text.splitlines() if re.search(r"[؀-ۿ]", l)]
if not arabic:
    raise SystemExit("no Arabic in the transcript:\n" + text)
last = arabic[-1].strip()
marks = sum(1 for ch in last if ch in MARKS)
bare = "".join(ch for ch in last if ch not in MARKS).replace("ٱ", "ا")
print("transcript:", last)
print("vowel marks:", marks)
if marks < 5:
    raise SystemExit("the model returned no vowel marks")
for word in ("بسم", "الرحيم"):
    if word not in bare:
        raise SystemExit(f"expected '{word}' in the transcript")
print("ok")
