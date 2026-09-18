#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $EUID -ne 0 ]]; then
    echo "Requesting administrative privileges (sudo)..."
    exec sudo bash "$SCRIPT_DIR/optimize-daffodil-dc253d.sh" "$@"
else
    bash "$SCRIPT_DIR/optimize-daffodil-dc253d.sh" "$@"
fi
