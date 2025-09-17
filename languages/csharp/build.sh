#!/usr/bin/env bash
set -euo pipefail
cd languages/csharp
dotnet publish -c Release -o out
echo "C# build done."