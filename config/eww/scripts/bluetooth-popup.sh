#!/usr/bin/env bash
if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    mac=$(bluetoothctl devices Connected 2>/dev/null | head -1 | awk '{print $2}')
    if [ -n "$mac" ]; then
        info=$(bluetoothctl info "$mac" 2>/dev/null)
        name=$(echo "$info" | grep "^\s*Name:" | sed 's/.*Name: //')
        battery=$(echo "$info" | grep "Battery Percentage" | grep -oP '(?<=\().*(?=\))')
        echo "{\"connected\": true, \"name\": \"${name}\", \"battery\": \"${battery}\", \"mac\": \"${mac}\"}"
    else
        echo "{\"connected\": false, \"name\": \"\", \"battery\": \"\", \"mac\": \"\"}"
    fi
else
    echo "{\"connected\": false, \"name\": \"\", \"battery\": \"\", \"mac\": \"\"}"
fi
