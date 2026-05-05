#!/usr/bin/env bash
# Outputs current default sink volume as a plain integer (0–100).
wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null \
  | awk '{printf "%d", $2 * 100}' || echo "0"
