#!/usr/bin/env bash
set -euo pipefail

directory="${1:-target/wasm32v1-none/release}"
max_bytes="${WASM_MAX_BYTES:-262144}"
shopt -s nullglob
files=("$directory"/sororail_*.wasm)
if ((${#files[@]} == 0)); then
  echo "No contract WASM files found in $directory" >&2
  exit 1
fi

failed=0
for file in "${files[@]}"; do
  size=$(stat -c%s "$file")
  echo "$(basename "$file"): $size bytes (limit: $max_bytes)"
  if ((size > max_bytes)); then
    echo "${file} exceeds the ${max_bytes}-byte WASM limit" >&2
    failed=1
  fi
done
exit "$failed"
