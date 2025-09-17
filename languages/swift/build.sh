#!/usr/bin/env bash
set -euo pipefail
swiftc -O -o languages/swift/multi languages/swift/Multi.swift
echo "Swift build done."