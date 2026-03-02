#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

print_step() {
  printf '\n==> %s\n' "$1"
}

fail() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

ensure_command() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || fail "Required command not found: $cmd"
}

detect_package_manager() {
  local preferred="${JS_PM:-}"
  if [[ -n "$preferred" ]]; then
    case "$preferred" in
      npm|pnpm|yarn|bun)
        command -v "$preferred" >/dev/null 2>&1 || fail "JS_PM is set to '$preferred' but it is not installed"
        printf '%s\n' "$preferred"
        return 0
        ;;
      *)
        fail "Unsupported JS_PM '$preferred'. Use one of: npm, pnpm, yarn, bun"
        ;;
    esac
  fi

  if [[ -f "${REPO_ROOT}/pnpm-lock.yaml" ]] && command -v pnpm >/dev/null 2>&1; then
    printf 'pnpm\n'
    return 0
  fi

  if [[ -f "${REPO_ROOT}/yarn.lock" ]] && command -v yarn >/dev/null 2>&1; then
    printf 'yarn\n'
    return 0
  fi

  if [[ ( -f "${REPO_ROOT}/bun.lock" || -f "${REPO_ROOT}/bun.lockb" ) ]] && command -v bun >/dev/null 2>&1; then
    printf 'bun\n'
    return 0
  fi

  if command -v npm >/dev/null 2>&1; then
    printf 'npm\n'
    return 0
  fi

  if command -v pnpm >/dev/null 2>&1; then
    printf 'pnpm\n'
    return 0
  fi

  if command -v yarn >/dev/null 2>&1; then
    printf 'yarn\n'
    return 0
  fi

  if command -v bun >/dev/null 2>&1; then
    printf 'bun\n'
    return 0
  fi

  fail "No JavaScript package manager found. Install one of: npm, pnpm, yarn, bun"
}

run_js_script() {
  local script="$1"
  shift || true

  local manager
  manager="$(detect_package_manager)"

  case "$manager" in
    npm)
      if [[ $# -eq 0 ]]; then
        (cd "$REPO_ROOT" && npm run "$script")
      else
        (cd "$REPO_ROOT" && npm run "$script" -- "$@")
      fi
      ;;
    pnpm)
      (cd "$REPO_ROOT" && pnpm run "$script" "$@")
      ;;
    yarn)
      (cd "$REPO_ROOT" && yarn "$script" "$@")
      ;;
    bun)
      (cd "$REPO_ROOT" && bun run "$script" "$@")
      ;;
    *)
      fail "Unsupported package manager: $manager"
      ;;
  esac
}

install_js_dependencies_if_missing() {
  if [[ -d "${REPO_ROOT}/node_modules" ]]; then
    return 0
  fi

  local manager
  manager="$(detect_package_manager)"
  print_step "Installing JS dependencies with ${manager}"

  case "$manager" in
    npm)
      (cd "$REPO_ROOT" && npm install)
      ;;
    pnpm)
      (cd "$REPO_ROOT" && pnpm install)
      ;;
    yarn)
      (cd "$REPO_ROOT" && yarn install)
      ;;
    bun)
      (cd "$REPO_ROOT" && bun install)
      ;;
    *)
      fail "Unsupported package manager: $manager"
      ;;
  esac
}
