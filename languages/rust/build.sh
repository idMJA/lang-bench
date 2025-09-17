#!/usr/bin/env bash
set -euo pipefail
cd languages/rust
cargo build --release
cp target/release/multi ./multi
echo "Rust build done."