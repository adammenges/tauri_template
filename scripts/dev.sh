#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/common.sh
source "${SCRIPT_DIR}/common.sh"

ensure_command cargo
ensure_command rustc
install_js_dependencies_if_missing

print_step "Starting Tauri development server"
run_js_script tauri dev "$@"
