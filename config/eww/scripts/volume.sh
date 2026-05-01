#!/usr/bin/env bash
# Outputs current default sink volume as a plain integer (0–100).
pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null \
  | grep -oP '\d+(?=%)' | head -1 || echo "0"
