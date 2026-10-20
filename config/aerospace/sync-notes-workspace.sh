#!/usr/bin/env bash

# Work setup only (PHL 346B1C connected): lay out workspace O (Obsidian + Apple Notes).
# - Both apps open: tile side by side, Obsidian left half, Notes right half.
# - Only one open: float it on the left half of the monitor.
# Re-applies only when that state changes, so windows can still be moved by hand.

set -euo pipefail

WORK_MONITOR="PHL 346B1C"
OBSIDIAN_ID="md.obsidian"
NOTES_ID="com.apple.Notes"

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

"$AEROSPACE_BIN" list-monitors --format '%{monitor-name}' 2>/dev/null | grep -qx "$WORK_MONITOR" || exit 0

windows="$(
    "$AEROSPACE_BIN" list-windows --workspace O --format '%{window-id}|%{app-bundle-id}' 2>/dev/null || true
)"
obsidian_ids="$(awk -F '|' -v id="$OBSIDIAN_ID" '$2 == id { print $1 }' <<< "$windows")"
notes_ids="$(awk -F '|' -v id="$NOTES_ID" '$2 == id { print $1 }' <<< "$windows")"

if [[ -n "$obsidian_ids" && -n "$notes_ids" ]]; then
    state="both"
elif [[ -n "$obsidian_ids" ]]; then
    state="obsidian:$obsidian_ids"
elif [[ -n "$notes_ids" ]]; then
    state="notes:$notes_ids"
else
    state="none"
fi

state_file="${TMPDIR:-/tmp}/aerospace-notes-workspace-state"
[[ -f "$state_file" && "$(cat "$state_file")" == "$state" ]] && exit 0
printf '%s' "$state" > "$state_file"

case "$state" in
    none) exit 0 ;;
    both)
        for window_id in $obsidian_ids $notes_ids; do
            "$AEROSPACE_BIN" layout --window-id "$window_id" tiling >/dev/null 2>&1 || true
        done
        "$AEROSPACE_BIN" flatten-workspace-tree --workspace O >/dev/null 2>&1 || true
        "$AEROSPACE_BIN" layout --workspace O tiles horizontal >/dev/null 2>&1 || true
        for window_id in $obsidian_ids; do
            "$AEROSPACE_BIN" move --window-id "$window_id" left >/dev/null 2>&1 || true
        done
        for window_id in $notes_ids; do
            "$AEROSPACE_BIN" move --window-id "$window_id" right >/dev/null 2>&1 || true
        done
        "$AEROSPACE_BIN" balance-sizes --workspace O >/dev/null 2>&1 || true
        ;;
    *)
        if [[ "$state" == obsidian:* ]]; then
            app_name="Obsidian"
            ids="$obsidian_ids"
        else
            app_name="Notes"
            ids="$notes_ids"
        fi
        for window_id in $ids; do
            "$AEROSPACE_BIN" layout --window-id "$window_id" floating >/dev/null 2>&1 || true
        done
        log_file="${TMPDIR:-/tmp}/aerospace-notes-workspace.log"
        AEROSPACE_APP_NAME="$app_name" AEROSPACE_MONITOR="$WORK_MONITOR" osascript -l JavaScript <<'JXA' >> "$log_file" 2>&1 || true
ObjC.import('Cocoa')

const env = $.NSProcessInfo.processInfo.environment
const appName = ObjC.unwrap(env.objectForKey('AEROSPACE_APP_NAME'))
const monitorName = ObjC.unwrap(env.objectForKey('AEROSPACE_MONITOR'))

const screens = $.NSScreen.screens
const primaryHeight = ObjC.deepUnwrap(screens.objectAtIndex(0).frame).size.height
let target = null

for (let i = 0; i < screens.count; i++) {
  const screen = screens.objectAtIndex(i)
  if (ObjC.unwrap(screen.localizedName) === monitorName) {
    target = ObjC.deepUnwrap(screen.visibleFrame)
  }
}

if (target) {
  const gap = 5
  const x = target.origin.x + gap
  const y = primaryHeight - (target.origin.y + target.size.height) + gap
  const width = Math.floor(target.size.width / 2) - gap - 1
  const height = target.size.height - gap * 2

  const process = Application('System Events').processes.byName(appName)
  const windows = process.windows()
  for (const win of windows) {
    win.position = [x, y]
    win.size = [width, height]
  }
  `${new Date().toISOString()} ${appName}: ${windows.length} window(s) -> ${x},${y} ${width}x${height}`
}
JXA
        ;;
esac
