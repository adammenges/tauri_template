#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/common.sh
source "${SCRIPT_DIR}/common.sh"

if [[ "$(uname -s)" != "Darwin" ]]; then
  fail "make_icns.sh only supports macOS"
fi

ensure_command iconutil
ensure_command sips

ICON_SOURCE_PNG="${REPO_ROOT}/assets/icons/AppIcon-1024.png"
ICONSET_DIR="${REPO_ROOT}/assets/icons/AppIcon.iconset"
ICON_OUTPUT_ICNS="${REPO_ROOT}/assets/icons/AppIcon.icns"
TAURI_ICONS_DIR="${REPO_ROOT}/src-tauri/icons"
DEFAULT_ICON_SWIFT="${REPO_ROOT}/scripts/generate_default_icon.swift"

mkdir -p "$(dirname "${ICON_SOURCE_PNG}")"

if [[ ! -f "${ICON_SOURCE_PNG}" ]]; then
  print_step "AppIcon-1024.png missing, generating a default icon"
  if command -v swift >/dev/null 2>&1; then
    swift_log="$(mktemp)"
    if ! swift "${DEFAULT_ICON_SWIFT}" "${ICON_SOURCE_PNG}" >"${swift_log}" 2>&1; then
      printf 'Warning: Swift icon generation failed, trying GenericApplicationIcon fallback\n' >&2
      sed -n '1,8p' "${swift_log}" >&2 || true
    fi
    rm -f "${swift_log}"
  else
    printf 'Warning: swift not found, trying GenericApplicationIcon fallback\n' >&2
  fi
fi

if [[ ! -f "${ICON_SOURCE_PNG}" ]]; then
  print_step "Using macOS generic app icon fallback"
  generic_icon=""
  for candidate in \
    /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns \
    /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericAppIcon.icns
  do
    if [[ -f "$candidate" ]]; then
      generic_icon="$candidate"
      break
    fi
  done

  [[ -n "$generic_icon" ]] || fail "Could not find GenericApplicationIcon.icns fallback"

  sips -s format png "$generic_icon" --out "$ICON_SOURCE_PNG" >/dev/null
  sips -Z 1024 "$ICON_SOURCE_PNG" >/dev/null
fi

[[ -f "${ICON_SOURCE_PNG}" ]] || fail "Unable to produce ${ICON_SOURCE_PNG}"

rm -rf "${ICONSET_DIR}"
mkdir -p "${ICONSET_DIR}"

make_png() {
  local px_size="$1"
  local out_name="$2"
  sips -z "$px_size" "$px_size" "${ICON_SOURCE_PNG}" --out "${ICONSET_DIR}/${out_name}" >/dev/null
}

make_png 16 icon_16x16.png
make_png 32 icon_16x16@2x.png
make_png 32 icon_32x32.png
make_png 64 icon_32x32@2x.png
make_png 128 icon_128x128.png
make_png 256 icon_128x128@2x.png
make_png 256 icon_256x256.png
make_png 512 icon_256x256@2x.png
make_png 512 icon_512x512.png
make_png 1024 icon_512x512@2x.png

print_step "Building AppIcon.icns"
iconutil -c icns "${ICONSET_DIR}" -o "${ICON_OUTPUT_ICNS}"

print_step "Syncing key icon files into src-tauri/icons"
mkdir -p "${TAURI_ICONS_DIR}"
cp "${ICON_OUTPUT_ICNS}" "${TAURI_ICONS_DIR}/icon.icns"
sips -z 32 32 "${ICON_SOURCE_PNG}" --out "${TAURI_ICONS_DIR}/32x32.png" >/dev/null
sips -z 128 128 "${ICON_SOURCE_PNG}" --out "${TAURI_ICONS_DIR}/128x128.png" >/dev/null
sips -z 256 256 "${ICON_SOURCE_PNG}" --out "${TAURI_ICONS_DIR}/128x128@2x.png" >/dev/null
sips -z 512 512 "${ICON_SOURCE_PNG}" --out "${TAURI_ICONS_DIR}/icon.png" >/dev/null

print_step "Generated ${ICON_OUTPUT_ICNS}"
