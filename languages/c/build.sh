#!/usr/bin/env bash
set -euo pipefail
cc -O3 -march=native -pipe -std=c11 -o languages/c/multi languages/c/multi.c -lm
echo "C build done."