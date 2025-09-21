#!/usr/bin/env bash
set -euo pipefail
zig build-exe languages/zig/multi.zig -O ReleaseFast -fstrip -femit-bin=languages/zig/multi
echo "Zig build done."