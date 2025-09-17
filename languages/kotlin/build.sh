#!/usr/bin/env bash
set -euo pipefail
kotlinc languages/kotlin/Multi.kt -include-runtime -d languages/kotlin/Multi.jar
echo "Kotlin build done."