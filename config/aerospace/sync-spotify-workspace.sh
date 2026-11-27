#!/usr/bin/env bash

set -euo pipefail

spotify_windows="$(
    aerospace list-windows --all --format '%{window-id}|%{app-bundle-id}' 2>/dev/null \
        | awk -F '|' '$2 == "com.spotify.client" { print $1 }' \
        || true
)"

if [[ -z "$spotify_windows" ]]; then
    exit 0
fi

while IFS= read -r window_id; do
    [[ -z "$window_id" ]] && continue
    aerospace move-node-to-workspace --window-id "$window_id" S >/dev/null 2>&1 || true
done <<< "$spotify_windows"

if aerospace list-apps 2>/dev/null | grep -q 'com.apple.logic10'; then
    aerospace move-workspace-to-monitor --workspace S 3 >/dev/null 2>&1 || true
else
    aerospace move-workspace-to-monitor --workspace S 2 >/dev/null 2>&1 || true
fi
