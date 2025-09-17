#!/usr/bin/env bash
set -euo pipefail
cd languages/go
GOFLAGS="-ldflags=-s -w" go build -o multi multi.go
echo "Go build done."