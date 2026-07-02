#!/usr/bin/env bash

set -euo pipefail

AEROSPACE_BIN="${AEROSPACE_BIN:-}"

if [[ -z "$AEROSPACE_BIN" ]]; then
    if command -v aerospace >/dev/null 2>&1; then
        AEROSPACE_BIN="$(command -v aerospace)"
    elif [[ -x /opt/homebrew/bin/aerospace ]]; then
        AEROSPACE_BIN="/opt/homebrew/bin/aerospace"
    elif [[ -x /usr/local/bin/aerospace ]]; then
        AEROSPACE_BIN="/usr/local/bin/aerospace"
    else
        exit 0
    fi
fi

safari_windows="$(
    "$AEROSPACE_BIN" list-windows --all --format '%{window-id}|%{app-bundle-id}' 2>/dev/null \
        | awk -F '|' '$2 == "com.apple.Safari" { print $1 }' \
        || true
)"

if [[ -z "$safari_windows" ]]; then
    exit 0
fi

while IFS= read -r window_id; do
    [[ -z "$window_id" ]] && continue
    "$AEROSPACE_BIN" move-node-to-workspace --window-id "$window_id" A >/dev/null 2>&1 || true
    "$AEROSPACE_BIN" fullscreen on --window-id "$window_id" >/dev/null 2>&1 || true
done <<< "$safari_windows"

"$AEROSPACE_BIN" move-workspace-to-monitor --workspace A '^DELL U2715H \(1\)$' >/dev/null 2>&1 || true
