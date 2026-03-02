#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/common.sh
source "${SCRIPT_DIR}/common.sh"

if [[ "$(uname -s)" != "Darwin" ]]; then
  fail "build_macos_app.sh only supports macOS"
fi

ensure_command node
ensure_command cargo
ensure_command rustc
ensure_command /usr/libexec/PlistBuddy

open_after_build=false
declare -a tauri_extra_args=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --open)
      open_after_build=true
      ;;
    *)
      tauri_extra_args+=("$1")
      ;;
  esac
  shift
done

"${SCRIPT_DIR}/make_icns.sh"
install_js_dependencies_if_missing

print_step "Building macOS .app bundle with Tauri"
if [[ ${#tauri_extra_args[@]} -gt 0 ]]; then
  run_js_script tauri build --bundles app "${tauri_extra_args[@]}"
else
  run_js_script tauri build --bundles app
fi

bundle_dir="${REPO_ROOT}/src-tauri/target/release/bundle/macos"
[[ -d "$bundle_dir" ]] || fail "Bundle output directory not found: $bundle_dir"

product_name="$({
  cd "$REPO_ROOT"
  node -e 'const fs=require("fs");const c=JSON.parse(fs.readFileSync("src-tauri/tauri.conf.json","utf8"));process.stdout.write(c.productName||"")'
})"

app_path="${bundle_dir}/${product_name}.app"
if [[ ! -d "$app_path" ]]; then
  first_app="$(find "$bundle_dir" -maxdepth 1 -type d -name '*.app' | head -n 1 || true)"
  [[ -n "$first_app" ]] || fail "No .app bundle found under $bundle_dir"
  app_path="$first_app"
fi

print_step "Ensuring AppIcon.icns is embedded in bundle"
cp "${REPO_ROOT}/assets/icons/AppIcon.icns" "${app_path}/Contents/Resources/AppIcon.icns"

plist_path="${app_path}/Contents/Info.plist"
if /usr/libexec/PlistBuddy -c "Print :CFBundleIconFile" "$plist_path" >/dev/null 2>&1; then
  /usr/libexec/PlistBuddy -c "Set :CFBundleIconFile AppIcon" "$plist_path"
else
  /usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string AppIcon" "$plist_path"
fi

staging_dir="${REPO_ROOT}/build/macos"
mkdir -p "$staging_dir"
final_app_path="${staging_dir}/$(basename "$app_path")"

rm -rf "$final_app_path"
cp -R "$app_path" "$final_app_path"

touch "$final_app_path"

print_step "macOS app ready"
printf 'App path: %s\n' "$final_app_path"

if [[ "$open_after_build" == true ]]; then
  print_step "Opening app"
  open "$final_app_path"
fi
