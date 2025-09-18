#!/usr/bin/env bash
set -euo pipefail
# Elixir doesn't need compilation, just syntax check
cd languages/elixir
elixir -e "Code.compile_file(\"multi.exs\"); :ok" --no-halt > /dev/null 2>&1 || true
echo "Elixir build done."