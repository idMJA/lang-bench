#!/usr/bin/env bash
set -euo pipefail
c++ -O3 -march=native -pipe -std=c++20 -o languages/cpp/multi languages/cpp/multi.cpp
echo "C++ build done."