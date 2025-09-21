#!/usr/bin/env bash
set -euo pipefail
# Run the Elixir module without forcing a compile every invocation.
cd "$(dirname "$0")"
# If compiled beams exist, add them to the code path and run; otherwise require the source file.
if [ -d "_build/dev/lib/elixir_multi/ebin" ]; then
	exec elixir -pa _build/dev/lib/elixir_multi/ebin -e "ElixirMulti.main(System.argv())" -- "$@"
else
	exec elixir -r lib/elixir_multi.ex -e "ElixirMulti.main(System.argv())" -- "$@"
fi
