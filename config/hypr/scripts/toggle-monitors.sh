#!/etc/profiles/per-user/maxcaspar/bin/bash

HYPRCTL=/run/current-system/sw/bin/hyprctl
ALACRITTY=/run/current-system/sw/bin/alacritty
BTOP=/etc/profiles/per-user/maxcaspar/bin/btop
NVITOP=/etc/profiles/per-user/maxcaspar/bin/nvitop

WORKSPACE_ID=$($HYPRCTL activeworkspace | awk 'NR==1{print $3}')

get_window_address() {
    local title="$1"
    $HYPRCTL clients | awk -v ws="$WORKSPACE_ID" -v t="$title" '
        /^Window /    { addr = $2; found_title = 0; found_ws = 0 }
        /^\tworkspace: /    { if ($2 == ws) found_ws = 1 }
        /^\tinitialTitle: / { if ($2 == t) found_title = 1 }
        found_title && found_ws { print addr; found_title = 0; found_ws = 0 }
    '
}

CPU_ADDR=$(get_window_address "ws-monitor-cpu")
GPU_ADDR=$(get_window_address "ws-monitor-gpu")

if [ -n "$CPU_ADDR" ] || [ -n "$GPU_ADDR" ]; then
    [ -n "$CPU_ADDR" ] && $HYPRCTL dispatch closewindow "address:0x$CPU_ADDR"
    [ -n "$GPU_ADDR" ] && $HYPRCTL dispatch closewindow "address:0x$GPU_ADDR"
else
    $ALACRITTY --title ws-monitor-cpu -e $BTOP &
    sleep 0.4
    $HYPRCTL dispatch movewindow l
    $ALACRITTY --title ws-monitor-gpu -e $NVITOP &
fi
