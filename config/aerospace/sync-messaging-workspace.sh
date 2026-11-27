#!/usr/bin/env bash

set -euo pipefail

messaging_windows="$(
    aerospace list-windows --all --format '%{window-id}|%{app-bundle-id}' 2>/dev/null \
        | awk -F '|' '$2 == "com.apple.MobileSMS" || $2 == "net.whatsapp.WhatsApp" { print $1 }' \
        || true
)"

if [[ -z "$messaging_windows" ]]; then
    exit 0
fi

while IFS= read -r window_id; do
    [[ -z "$window_id" ]] && continue
    aerospace move-node-to-workspace --window-id "$window_id" M >/dev/null 2>&1 || true
done <<< "$messaging_windows"

if aerospace list-apps 2>/dev/null | grep -q 'com.mitchellh.ghostty'; then
    aerospace move-workspace-to-monitor --workspace M 1 >/dev/null 2>&1 || true
else
    aerospace move-workspace-to-monitor --workspace M 2 >/dev/null 2>&1 || true
fi
