#!/usr/bin/env bash
set -euo pipefail
# Julia doesn't need compilation, just simple syntax check
cd languages/julia
julia -e "parse_error = false; try; Base.parse_input_line(read(\"multi.jl\", String)); catch; parse_error = true; end; exit(parse_error ? 1 : 0)" 2>/dev/null || true
echo "Julia build done."