# Tauri Personal App Template

Opinionated Tauri + React + TypeScript starter for shipping desktop apps on macOS first, while staying portable.

## Project layout

```text
.
├── assets/
│   ├── icons/              # Source + generated app icons (macOS pipeline)
│   └── symbols/            # SF Symbol exports for in-app iconography
├── scripts/
│   ├── dev.sh              # Start desktop dev flow
│   ├── check.sh            # Frontend/Rust sanity checks
│   ├── build_macos_app.sh  # Build a launchable .app bundle
│   ├── make_icns.sh        # Generate AppIcon.icns from AppIcon-1024.png
│   └── generate_default_icon.swift
├── src/                    # React UI
└── src-tauri/              # Rust + Tauri config
```

## Core commands

```bash
./scripts/dev.sh
./scripts/check.sh
./scripts/build_macos_app.sh
```

You can also run the same flows via npm scripts:

```bash
npm run dev:desktop
npm run check
npm run build:macos-app
```

## macOS app bundling

`./scripts/build_macos_app.sh` produces a launchable `.app` and stages it at:

```text
build/macos/<ProductName>.app
```

Use `--open` to launch immediately after build:

```bash
./scripts/build_macos_app.sh --open
```

### Icon pipeline

- Source icon: `assets/icons/AppIcon-1024.png`
- Generated ICNS: `assets/icons/AppIcon.icns` (via `./scripts/make_icns.sh`)
- Bundle target: `Contents/Resources/AppIcon.icns`

Fallback chain when `AppIcon-1024.png` is missing:
1. `scripts/generate_default_icon.swift`
2. macOS `GenericApplicationIcon.icns`

## Setup notes

- Update `src-tauri/tauri.conf.json`:
  - `productName`
  - `identifier`
- Recommended IDE: VS Code + Tauri extension + rust-analyzer
