#!/usr/bin/env python3
"""Streams eww literal markup for the matrix rain panel."""
import random
import sys
import time

COLS, ROWS = 11, 8

KATAKANA = [chr(i) for i in range(0x30A1, 0x30F7)]
CHARS = KATAKANA + list("0123456789")

HEAD = "#b4d4c0"   # pale mint  – leading char
SAGE = "#7a9e87"   # sage green – close trail
LAV  = "#8a80a8"   # lavender   – mid trail
DIM  = "#2a3a32"   # dark sage  – far trail
DARK = "#050907"   # near-black – invisible

heads  = [random.randint(0, ROWS - 1) for _ in range(COLS)]
speeds = [random.randint(1, 3)        for _ in range(COLS)]
ticks  = [0] * COLS
grid   = [[random.choice(CHARS) for _ in range(ROWS)] for _ in range(COLS)]


def get_color(row: int, head: int) -> str:
    d = (head - row) % ROWS
    if d == 0:
        return HEAD
    if d == 1:
        return SAGE
    if d == 2:
        return LAV if random.random() < 0.38 else SAGE
    if d <= 4:
        return DIM
    return DARK


def render() -> str:
    row_parts = []
    for r in range(ROWS):
        cells = []
        for c in range(COLS):
            col = get_color(r, heads[c])
            ch  = grid[c][r]
            cells.append(
                f"(label :markup \"<span foreground='{col}'>{ch}</span>\")"
            )
        row_parts.append(
            "(box :orientation \"h\" :spacing 10 :halign \"center\" "
            + " ".join(cells)
            + ")"
        )
    return (
        "(box :orientation \"v\" :spacing 5 :valign \"center\" :vexpand true "
        + " ".join(row_parts)
        + ")"
    )


while True:
    print(render(), flush=True)

    for c in range(COLS):
        ticks[c] += 1
        if ticks[c] >= speeds[c]:
            ticks[c] = 0
            heads[c] = (heads[c] + 1) % ROWS
            grid[c][heads[c]] = random.choice(CHARS)

    time.sleep(0.18)
