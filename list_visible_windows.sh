#!/usr/bin/env bash
set -euo pipefail

# Lists windows that xdotool considers "visible", limited to the current desktop
# (or sticky windows on all desktops).
#
# By default this filters out the noisy helper/child windows (often 1x1 with no
# WM_CLASS / type). Use --raw to include everything.
#
# Output columns:
#   wid desk geo type state class title

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing: $1" >&2; exit 2; }; }
need xdotool
need xprop
need xwininfo

RAW=0
if [ "${1:-}" = "--raw" ]; then
  RAW=1
  shift
fi

DESK="$(
  xprop -root _NET_CURRENT_DESKTOP 2>/dev/null | awk -F'= ' '{print $2}' || true
)"
DESK="${DESK:-0}"

xdotool search --onlyvisible --name '.*' 2>/dev/null | while read -r wid; do
  [ -n "${wid:-}" ] || continue

  wdesk="$(
    xprop -id "$wid" _NET_WM_DESKTOP 2>/dev/null | awk -F'= ' '{print $2}' | tr -d ',' || true
  )"
  wdesk="${wdesk:-$DESK}"
  [[ "$wdesk" != "$DESK" && "$wdesk" != "-1" ]] && continue

  title="$(xdotool getwindowname "$wid" 2>/dev/null | head -c 160 || true)"
  cls="$(xprop -id "$wid" WM_CLASS 2>/dev/null | sed -n 's/.*= //p' || true)"
  wtype="$(xprop -id "$wid" _NET_WM_WINDOW_TYPE 2>/dev/null | sed -n 's/.*= //p' || true)"
  state="$(xprop -id "$wid" _NET_WM_STATE 2>/dev/null | sed -n 's/.*= //p' || true)"
  geo="$(
    xwininfo -id "$wid" 2>/dev/null | awk '
      /Absolute upper-left X:/ {x=$NF}
      /Absolute upper-left Y:/ {y=$NF}
      /^  Width:/ {w=$NF}
      /^  Height:/ {h=$NF}
      END {print x+0, y+0, w+0, h+0}
    ' || true
  )"

  if (( !RAW )); then
    # Drop tiny helper/child windows and menus/tooltips.
    set -- $geo
    w="${3:-0}"
    h="${4:-0}"
    if (( w < 50 || h < 50 )); then
      continue
    fi

    # Keep "real" windows and the important shell surfaces (desktop/panels).
    case "$wtype" in
      *"_NET_WM_WINDOW_TYPE_NORMAL"* | *"_NET_WM_WINDOW_TYPE_DIALOG"* | *"_NET_WM_WINDOW_TYPE_UTILITY"* | *"_NET_WM_WINDOW_TYPE_DESKTOP"* | *"_NET_WM_WINDOW_TYPE_DOCK"*)
        ;;
      *)
        continue
        ;;
    esac
  fi

  printf "%s desk=%s geo=%s type=%s state=%s class=%s title=%s\n" \
    "$wid" "$wdesk" "$geo" "$wtype" "$state" "$cls" "$title"
done | sort
