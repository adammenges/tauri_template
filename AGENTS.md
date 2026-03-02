# AGENTS.md

These instructions are for coding agents working in this repository (Codex, Claude Code, Qodo, Cursor, etc.).

## Feedback Loop

If I ever correct you, add the correction to `FEEDBACK.md` so it never happens again.

## Mission

Build clean, modern desktop apps that with generally be run on macOS, but should be portable to other platforms in the future.

## Non-negotiables

- Prefer simple, clean UI and obvious interaction flows. Make it well designed. I'm looking for this UI to win awards, not just be functional.

## UI direction

- Very CLI like a terminal, but in a hacky kind of cool way.
- Keyboard shortcuts for everything.
- ASCII art is nice
- Beautiful, easy to use, hacker
- Center the UI, it should always look good regardless of window width

## Iconography

- Prefer SF Symbols for in-app iconography.
- Store symbol exports in `assets/symbols/` (typically SVG).
- Keep icon weights and sizes consistent within a screen.

## Build and packaging expectations

- `.app` bundles are created with `scripts/build_macos_app.sh`.
- Icon generation pipeline:
  - `assets/icons/AppIcon-1024.png`
  - `scripts/make_icns.sh` -> `assets/icons/AppIcon.icns`
  - bundle embeds `Contents/Resources/AppIcon.icns`
- If icon source is missing, fallback chain is:
  - `scripts/generate_default_icon.swift`
  - macOS `GenericApplicationIcon.icns` extraction

## Commands agents should run

```bash
./scripts/dev.sh
./scripts/check.sh
./scripts/build_macos_app.sh
```

## Change checklist

- Keep README/docs in sync with behavior.
- Keep scripts executable and cross-shell safe (`bash`, `set -euo pipefail`).
- Validate macOS packaging still works after refactors.
