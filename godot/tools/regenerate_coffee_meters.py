#!/usr/bin/env python3
"""Regenerate coffee minigame meter sprites with Praga Nowa palette colors.

Produces four 240x24 PNG sprites:
  - meter_brew_bg.png:    Matte Black #2a2826 background
  - meter_brew_fill.png:  Sage Green #98a888 fill
  - meter_bitter_bg.png:  Matte Black #2a2826 background
  - meter_bitter_fill.png: Exposed Brick #a8543a fill

All with 1px Mushroom Gray #888078 border for readability.
"""

import struct
import zlib
import os

WIDTH = 240
HEIGHT = 24
BORDER = 1

# Praga Nowa palette colors (R, G, B, A)
MATTE_BLACK = (0x2a, 0x28, 0x26, 0xFF)
SAGE_GREEN = (0x98, 0xa8, 0x88, 0xFF)
EXPOSED_BRICK = (0xa8, 0x54, 0x3a, 0xFF)
MUSHROOM_GRAY = (0x88, 0x80, 0x78, 0xFF)


def make_png(width: int, height: int, fill_color: tuple, border_color: tuple) -> bytes:
    """Generate a minimal RGBA PNG with a fill color and 1px border."""
    raw_rows = []
    for y in range(height):
        row = bytearray()
        row.append(0)  # filter byte: None
        for x in range(width):
            if x < BORDER or x >= width - BORDER or y < BORDER or y >= height - BORDER:
                row.extend(border_color)
            else:
                row.extend(fill_color)
        raw_rows.append(bytes(row))

    raw_data = b"".join(raw_rows)

    def chunk(ctype: bytes, data: bytes) -> bytes:
        c = ctype + data
        crc = struct.pack(">I", zlib.crc32(c) & 0xFFFFFFFF)
        return struct.pack(">I", len(data)) + c + crc

    sig = b"\x89PNG\r\n\x1a\n"
    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)  # 8-bit RGBA
    idat = zlib.compress(raw_data, 9)

    return sig + chunk(b"IHDR", ihdr) + chunk(b"IDAT", idat) + chunk(b"IEND", b"")


def main():
    out_dir = os.path.join(os.path.dirname(__file__), "..", "art", "minigames", "coffee")
    out_dir = os.path.normpath(out_dir)

    sprites = [
        ("meter_brew_bg.png", MATTE_BLACK, MUSHROOM_GRAY),
        ("meter_brew_fill.png", SAGE_GREEN, SAGE_GREEN),
        ("meter_bitter_bg.png", MATTE_BLACK, MUSHROOM_GRAY),
        ("meter_bitter_fill.png", EXPOSED_BRICK, EXPOSED_BRICK),
    ]

    for name, fill, border in sprites:
        path = os.path.join(out_dir, name)
        data = make_png(WIDTH, HEIGHT, fill, border)
        with open(path, "wb") as f:
            f.write(data)
        print(f"  wrote {name} ({len(data)} bytes)")


if __name__ == "__main__":
    main()
