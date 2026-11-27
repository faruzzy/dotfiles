#!/usr/bin/env bash

set -euo pipefail

safari_windows="$(
    aerospace list-windows --all --format '%{window-id}|%{app-bundle-id}' 2>/dev/null \
        | awk -F '|' '$2 == "com.apple.Safari" { print $1 }' \
        || true
)"

if [[ -z "$safari_windows" ]]; then
    exit 0
fi

while IFS= read -r window_id; do
    [[ -z "$window_id" ]] && continue
    aerospace move-node-to-workspace --window-id "$window_id" A >/dev/null 2>&1 || true
    aerospace fullscreen on --window-id "$window_id" >/dev/null 2>&1 || true
done <<< "$safari_windows"

aerospace move-workspace-to-monitor --workspace A 1 >/dev/null 2>&1 || true
