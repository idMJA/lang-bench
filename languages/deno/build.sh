#!/usr/bin/env bash
set -euo pipefail
# Deno doesn't need compilation, but we can check syntax
cd languages/deno
deno check multi.js
echo "Deno build done."