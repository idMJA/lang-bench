#!/usr/bin/env bash
set -euo pipefail
# PyPy doesn't need compilation, but we can check syntax  
cd languages/pypy
pypy3 -m py_compile multi.py
echo "PyPy build done."