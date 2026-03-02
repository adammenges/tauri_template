#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/common.sh
source "${SCRIPT_DIR}/common.sh"

if [[ $# -lt 1 ]]; then
  fail "Usage: $0 <script-name> [args...]"
fi

script_name="$1"
shift || true

install_js_dependencies_if_missing
run_js_script "$script_name" "$@"
