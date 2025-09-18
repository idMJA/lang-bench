#!/usr/bin/env bash
set -euo pipefail
cd languages/zig
zig build-exe -O ReleaseFast multi.zig
echo "Zig build done."