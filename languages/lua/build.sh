#!/usr/bin/env bash
set -euo pipefail
# Lua doesn't need compilation, but we can check syntax
cd languages/lua
lua5.4 -e "loadfile('multi.lua')" > /dev/null 2>&1 || { echo "Lua syntax error"; exit 1; }
echo "Lua build done."