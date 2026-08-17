#!/usr/bin/env bash
set -euo pipefail

direction="${1:?usage: move-focused-window.sh <left|right|prev|next>}"
obsidian_center_workspace="Y"
obsidian_home_workspace="O"

focused_window="$(aerospace list-windows --focused --format '%{window-id}|%{app-bundle-id}' 2>/dev/null || true)"
window_id="${focused_window%%|*}"
app_id="${focused_window#*|}"

if [[ -z "${focused_window}" || "${window_id}" == "${app_id}" ]]; then
  aerospace move-node-to-monitor --focus-follows-window "${direction}"
  exit 0
fi

if [[ "${app_id}" == "md.obsidian" ]]; then
  case "${direction}" in
    left|prev)
      aerospace move-node-to-workspace --window-id "${window_id}" --focus-follows-window "${obsidian_center_workspace}"
      aerospace fullscreen on --window-id "${window_id}"
      ;;
    right|next)
      aerospace move-node-to-workspace --window-id "${window_id}" --focus-follows-window "${obsidian_home_workspace}"
      aerospace fullscreen on --window-id "${window_id}"
      ;;
    *)
      aerospace move-node-to-monitor --window-id "${window_id}" --focus-follows-window "${direction}"
      ;;
  esac
  exit 0
fi

aerospace move-node-to-monitor --window-id "${window_id}" --focus-follows-window "${direction}"
