#!/usr/bin/env python3
"""Prints a JSON manifest (name, bytes, sha256) of the model files in the
current directory that start with the given prefix."""

import hashlib
import json
import os
import sys

prefix = sys.argv[1]
files = sorted(f for f in os.listdir(".") if f.startswith(prefix) and f.endswith((".onnx", ".txt")))
manifest = [
    {"file": f, "bytes": os.path.getsize(f), "sha256": hashlib.sha256(open(f, "rb").read()).hexdigest()}
    for f in files
]
print(json.dumps(manifest, indent=2))
