#!/usr/bin/env bash

set -euo pipefail

action="${1:-}"

case "$action" in
    left-half|right-half|maximize|center) ;;
    *) exit 64 ;;
esac

export AEROSPACE_WINDOW_FRAME_ACTION="$action"

if ! output="$(osascript -l JavaScript <<'JXA'
ObjC.import('Cocoa')

const action = ObjC.unwrap(
  $.NSProcessInfo.processInfo.environment.objectForKey('AEROSPACE_WINDOW_FRAME_ACTION')
)
const systemEvents = Application('System Events')
const processes = systemEvents.applicationProcesses.whose({ frontmost: true })()

if (processes.length === 0 || processes[0].windows.length === 0) {
  $.exit(0)
}

const win = processes[0].windows[0]
const position = win.position()
const size = win.size()
const centerX = position[0] + size[0] / 2
const centerY = position[1] + size[1] / 2

function nsValueToRect(value) {
  const rect = ObjC.deepUnwrap(value)
  return {
    x: rect.origin.x,
    y: rect.origin.y,
    width: rect.size.width,
    height: rect.size.height,
  }
}

const screens = $.NSScreen.screens
const frames = []

for (let i = 0; i < screens.count; i++) {
  const frame = nsValueToRect(screens.objectAtIndex(i).visibleFrame)
  frames.push(frame)
}

const maxY = frames.reduce((top, frame) => Math.max(top, frame.y + frame.height), -Infinity)

function toAxRect(frame) {
  return {
    x: frame.x,
    y: maxY - (frame.y + frame.height),
    width: frame.width,
    height: frame.height,
  }
}

const axFrames = frames.map(toAxRect)
let screen = axFrames.find((frame) =>
  centerX >= frame.x &&
  centerX <= frame.x + frame.width &&
  centerY >= frame.y &&
  centerY <= frame.y + frame.height
)

if (!screen) {
  screen = axFrames[0]
}

let target
const halfWidth = Math.floor(screen.width / 2)

switch (action) {
  case 'left-half':
    target = { x: screen.x, y: screen.y, width: halfWidth, height: screen.height }
    break
  case 'right-half':
    target = {
      x: screen.x + screen.width - halfWidth,
      y: screen.y,
      width: halfWidth,
      height: screen.height,
    }
    break
  case 'maximize':
    target = { x: screen.x, y: screen.y, width: screen.width, height: screen.height }
    break
  case 'center': {
    const targetWidth = Math.floor(screen.width * 0.7)
    const targetHeight = Math.floor(screen.height * 0.8)
    target = {
      x: screen.x + Math.floor((screen.width - targetWidth) / 2),
      y: screen.y + Math.floor((screen.height - targetHeight) / 2),
      width: targetWidth,
      height: targetHeight,
    }
    break
  }
}

win.position = [target.x, target.y]
win.size = [target.width, target.height]
JXA
)"; then
    log_file="${TMPDIR:-/tmp}/aerospace-window-frame.log"
    {
        printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$output"
    } >> "$log_file"

    if [[ "$output" == *"not allowed assistive access"* ]]; then
        osascript -e 'display notification "Grant Accessibility access to /usr/bin/osascript, then try the shortcut again." with title "AeroSpace window shortcut failed"' >/dev/null 2>&1 || true
    fi

    exit 1
fi
