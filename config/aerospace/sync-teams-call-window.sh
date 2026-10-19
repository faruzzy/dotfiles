#!/usr/bin/env bash

# Float Microsoft Teams call/meeting windows over Ghostty in workspace T.
# The main Teams window is titled "<Section> | <name>" (e.g. "Chat | Frontend Team only");
# call windows are titled after the meeting or person, without " | ".
# Each call window is handled once, so it can still be moved elsewhere manually.

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

state_file="${TMPDIR:-/tmp}/aerospace-teams-call-windows"
touch "$state_file"

call_windows="$(
    "$AEROSPACE_BIN" list-windows --monitor all --app-bundle-id com.microsoft.teams2 \
        --format '%{window-id}|%{window-title}' 2>/dev/null \
        | awk -F '|' 'NF == 2 && $2 != "" && $2 != "Microsoft Teams" { print $1 }' \
        || true
)"

if [[ -z "$call_windows" ]]; then
    exit 0
fi

while IFS= read -r window_id; do
    [[ -z "$window_id" ]] && continue
    grep -qx "$window_id" "$state_file" && continue
    "$AEROSPACE_BIN" layout --window-id "$window_id" floating >/dev/null 2>&1 || true
    "$AEROSPACE_BIN" move-node-to-workspace --window-id "$window_id" T >/dev/null 2>&1 || true
    echo "$window_id" >> "$state_file"
done <<< "$call_windows"
