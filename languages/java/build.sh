#!/usr/bin/env bash
set -euo pipefail
mkdir -p languages/java/out
javac -d languages/java/out languages/java/bench/Main.java
echo "Java build done."