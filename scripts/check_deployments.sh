#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
deployments="$root/DEPLOYMENTS.md"

test -f "$deployments" || { echo "DEPLOYMENTS.md is missing" >&2; exit 1; }

mapfile -t contracts < <(
  cargo metadata --no-deps --format-version 1 --manifest-path "$root/Cargo.toml" \
    | jq -r '.packages[] | select(.targets | any(.kind[]; . == "cdylib")) | .name'
)

if ((${#contracts[@]} == 0)); then
  echo "No deployable cdylib packages found" >&2
  exit 1
fi

failed=0
for package in "${contracts[@]}"; do
  contract="${package#sororail-}"
  contract="${contract//-/_}"
  if ! grep -Eq "(^|[|[:space:]])${contract}([|[:space:]]|$)" "$deployments"; then
    echo "Missing deployment entry for $package (expected '$contract')" >&2
    failed=1
  fi
done

if ((failed)); then
  exit 1
fi
echo "DEPLOYMENTS.md lists all ${#contracts[@]} deployable contracts."
