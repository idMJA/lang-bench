#!/usr/bin/env bash
set -euo pipefail
cd languages/d
ldc2 -O3 -release --boundscheck=off -mcpu=native --of=multi multi.d
echo "D (LDC) build done."