# App Icons

- Put your source icon at `assets/icons/AppIcon-1024.png`.
- Run `./scripts/make_icns.sh` to generate `assets/icons/AppIcon.icns` and sync key files to `src-tauri/icons/`.
- `./scripts/build_macos_app.sh` calls `make_icns.sh` automatically.

If `AppIcon-1024.png` is missing, the scripts use this fallback chain:
1. `scripts/generate_default_icon.swift`
2. macOS `GenericApplicationIcon.icns`
