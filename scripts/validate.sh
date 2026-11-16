#!/usr/bin/env bash
set -euo pipefail
for file in examples/*/main.bicep; do
  echo "Linting $file"
  az bicep lint --file "$file"
  az bicep build --file "$file" --stdout >/dev/null
done
for file in examples/*/*.bicepparam; do
  echo "Building $file"
  az bicep build-params --file "$file" --stdout >/dev/null
done
