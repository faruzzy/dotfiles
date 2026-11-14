#!/usr/bin/env bash

# Run after moving a window to another workspace or monitor. AeroSpace re-fits tiled windows, but a
# floating one keeps the frame it had on the old monitor, which can land off-screen on a smaller one
# (e.g. Philips -> built-in). Re-center a floating window like Cmd+Enter only when it doesn't fit
# on its new monitor, so moves between same-size monitors keep its size; leave tiled ones alone.

AEROSPACE_BIN="$(command -v aerospace || echo /opt/homebrew/bin/aerospace)"

layout="$("$AEROSPACE_BIN" list-windows --focused --format '%{window-layout}' 2>/dev/null)"
[[ "$layout" == floating ]] || exit 0

exec /bin/bash "$HOME/.config/aerospace/window-frame.sh" fit
