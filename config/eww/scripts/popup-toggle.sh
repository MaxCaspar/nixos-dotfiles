#!/usr/bin/env bash
# Usage: popup-toggle.sh <window-name>
# Opens the popup (closing any others), or closes it if already open.
# Manages a Hyprland submap for click-outside-to-dismiss.

name="$1"

if eww windows | grep -q "^\* ${name}$"; then
    eww close "$name"
    hyprctl dispatch submap reset
else
    eww close-all
    hyprctl dispatch submap reset
    eww open "$name"
    hyprctl dispatch submap popup-dismiss
fi
