#!/usr/bin/env bash
# Toggle monitor dashboard on workspace 9.
# Layout:
#   top-left:   btop   | top-middle: neo  | right: terminal (full height)
#   bottom:     nvitop (spans left 2/3)   |

wait_for_window() {
  local title="$1"
  for _ in $(seq 1 30); do
    hyprctl clients -j | jq -e ".[] | select(.title == \"$title\")" > /dev/null 2>&1 && return 0
    sleep 0.1
  done
}

COUNT=$(hyprctl clients -j | jq '[.[] | select(.title | test("^ws-monitor"))] | length')
if [ "$COUNT" -gt 0 ]; then
  hyprctl clients -j | jq -r '.[] | select(.title | test("^ws-monitor")) | .address' | \
    while read -r addr; do
      hyprctl dispatch closewindow "address:$addr"
    done
  exit 0
fi

# 1. Terminal opens first — will be the full-height right column
hyprctl dispatch exec "kitty --title ws-monitor-term"
wait_for_window "ws-monitor-term"

# 2. Neo opens to the left of the terminal
hyprctl dispatch focuswindow "title:^(ws-monitor-term)$"
hyprctl dispatch layoutmsg "preselect l"
hyprctl dispatch exec "kitty --title ws-monitor-neo -e neo -c cyan -D"
wait_for_window "ws-monitor-neo"

# 3. nvitop opens below neo (spans the left 2/3 bottom)
hyprctl dispatch focuswindow "title:^(ws-monitor-neo)$"
hyprctl dispatch layoutmsg "preselect d"
hyprctl dispatch exec "kitty --title ws-monitor-gpu -e nvitop"
wait_for_window "ws-monitor-gpu"

# 4. btop opens to the left of neo (top-left slot)
hyprctl dispatch focuswindow "title:^(ws-monitor-neo)$"
hyprctl dispatch layoutmsg "preselect l"
hyprctl dispatch exec "kitty --title ws-monitor-cpu -e btop"
wait_for_window "ws-monitor-cpu"

