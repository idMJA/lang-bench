#!/usr/bin/env bash
set -euo pipefail
cd languages/nim
nim c -d:release -d:danger --opt:speed --gc:arc -o:multi multi.nim
echo "Nim build done."