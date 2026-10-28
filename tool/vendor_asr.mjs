// Fetches the pinned transformers.js build the Mushaf+ voice model worker
// imports (web/asr/asr-worker.js) into web/asr/transformers.min.js, verifying
// its SHA-256 and prepending the licence header. The file is not committed:
// GitHub's push protection flags a class name inside the minified bundle as a
// secret, so it is fetched at build time instead (locally and in the Pages
// workflow) and served from our own site, never from a CDN at run time.
//
// Usage: node tool/vendor_asr.mjs   (run before `flutter build web`)
import { createHash } from 'node:crypto';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { join } from 'node:path';

const version = '4.3.1';
const url = `https://cdn.jsdelivr.net/npm/@huggingface/transformers@${version}/dist/transformers.min.js`;
const sha256 = '8d6716d9086f57c30a4bf367dba61b887593573c770c454465e8019b2703e743';
const header = `/*!
 * @huggingface/transformers ${version} (dist/transformers.min.js), vendored unmodified for the Mushaf+ voice model worker.
 * Copyright 2023-present Hugging Face Inc. Licensed under the Apache License, Version 2.0; see LICENSE-transformers.txt
 * beside this file. Bundles onnxruntime-web (Microsoft, MIT). Source: https://www.npmjs.com/package/@huggingface/transformers
 */
`;
const out = join(process.cwd(), 'web', 'asr', 'transformers.min.js');

const digest = (buf) => createHash('sha256').update(buf).digest('hex');

const existing = await readFile(out, 'utf8').catch(() => null);
if (existing !== null && existing.startsWith(header) && digest(existing.slice(header.length)) === sha256) {
  console.log(`web/asr/transformers.min.js already present (transformers.js ${version})`);
  process.exit(0);
}
const res = await fetch(url);
if (!res.ok) throw new Error(`${url}: HTTP ${res.status}`);
const body = Buffer.from(await res.arrayBuffer());
const got = digest(body);
if (got !== sha256) throw new Error(`SHA-256 mismatch for ${url}: expected ${sha256}, got ${got}`);
await mkdir(join(process.cwd(), 'web', 'asr'), { recursive: true });
await writeFile(out, header + body.toString('utf8'));
console.log(`web/asr/transformers.min.js written (${(body.length / 1e6).toFixed(2)} MB, transformers.js ${version})`);
