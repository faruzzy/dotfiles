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

spotify_windows="$(
    "$AEROSPACE_BIN" list-windows --all --format '%{window-id}|%{app-bundle-id}' 2>/dev/null \
        | awk -F '|' '$2 == "com.spotify.client" { print $1 }' \
        || true
)"

if [[ -z "$spotify_windows" ]]; then
    exit 0
fi

while IFS= read -r window_id; do
    [[ -z "$window_id" ]] && continue
    "$AEROSPACE_BIN" move-node-to-workspace --window-id "$window_id" S >/dev/null 2>&1 || true
done <<< "$spotify_windows"

if "$AEROSPACE_BIN" list-apps 2>/dev/null | grep -q 'com.apple.logic10'; then
    "$AEROSPACE_BIN" move-workspace-to-monitor --workspace S 3 >/dev/null 2>&1 || true
else
    "$AEROSPACE_BIN" move-workspace-to-monitor --workspace S 2 >/dev/null 2>&1 || true
fi
