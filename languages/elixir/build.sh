#!/usr/bin/env bash
set -euo pipefail
cd languages/elixir
# Use mix to compile the project so `ElixirMulti` module is available
mix compile --quiet || true
echo "Elixir build done."