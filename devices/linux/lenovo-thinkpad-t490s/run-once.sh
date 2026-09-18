#!/usr/bin/env bash
# ==============================================================================
# ThinkPad T490s 1-Click Autonomous Optimization Launcher
# Repository: ShoumikBalaSomu/Device-Base-Optimization
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $EUID -ne 0 ]]; then
    echo "Requesting administrative privileges (sudo)..."
    exec sudo bash "${SCRIPT_DIR}/optimize-thinkpad-t490s.sh" "$@"
else
    exec bash "${SCRIPT_DIR}/optimize-thinkpad-t490s.sh" "$@"
fi
