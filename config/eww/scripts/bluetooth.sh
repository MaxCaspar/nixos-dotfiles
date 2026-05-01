#!/usr/bin/env bash
# Outputs a short bluetooth status string for the pill button label.
if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    connected=$(bluetoothctl devices Connected 2>/dev/null | head -1 | cut -d' ' -f3-)
    if [ -n "$connected" ]; then
        echo "bt: $connected"
    else
        echo "bt: on"
    fi
else
    echo "bt: off"
fi
