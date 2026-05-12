#!/usr/bin/env python3
"""Decode TileMapLayer binary tile_map_data from pig_swine_office.tscn.

Hypothesis: 12 bytes per cell, 6 little-endian int16 fields:
  (x, y, source_id, atlas_x, atlas_y, alt_tile)
Whole blob is then base64-encoded.

Verifies hypothesis against:
- known floor cell counts (24x16 = 384)
- known wall row at y=-1 (24 cells)
- known atlas coords for floor variants (0:0..2:1) and wall (0:0..5:0)
"""
import base64
import re
import struct
from pathlib import Path
from collections import Counter

SCENE = Path(__file__).parent / "pig_swine_office.tscn"
text = SCENE.read_text()

def extract_layer_data(layer_name: str) -> bytes:
    # Find: [node name="<name>" ... \ntile_map_data = PackedByteArray("...")
    pat = re.compile(
        r'\[node name="' + re.escape(layer_name) + r'".*?\n.*?tile_map_data = PackedByteArray\("([^"]*)"\)',
        re.DOTALL,
    )
    m = pat.search(text)
    if not m:
        raise SystemExit(f"Couldn't find tile_map_data for layer {layer_name}")
    return base64.b64decode(m.group(1))


def decode_cells(blob: bytes):
    """Try several plausible layouts. Returns (cells, header_bytes, err)."""
    # Direct 12-byte cells, no header
    if len(blob) % 12 == 0:
        prefix = 0
    elif (len(blob) - 2) % 12 == 0:
        prefix = 2
    elif (len(blob) - 4) % 12 == 0:
        prefix = 4
    else:
        return None, None, f"blob length {len(blob)} not 12-aligned"

    header = blob[:prefix]
    rest = blob[prefix:]
    cells = []
    for i in range(0, len(rest), 12):
        fields = struct.unpack("<6h", rest[i : i + 12])
        cells.append(fields)
    return cells, header, None


def report(layer_name: str):
    print(f"=== {layer_name} ===")
    blob = extract_layer_data(layer_name)
    print(f"  base64-decoded bytes: {len(blob)}")
    print(f"  / 12 = {len(blob) / 12} cells")

    cells, header, err = decode_cells(blob)
    if err:
        print(f"  HYPOTHESIS FAILS: {err}")
        # Show byte counts at other strides for diagnosis
        for stride in (4, 8, 16):
            if len(blob) % stride == 0:
                print(f"  alt stride {stride}: {len(blob)//stride} cells")
        # Dump first 48 bytes hex
        print(f"  first 48 hex: {blob[:48].hex()}")
        return

    print(f"  header bytes ({len(header)}): {header.hex()}")
    print(f"  decoded {len(cells)} cells")
    print(f"  first 5 cells: {cells[:5]}")
    print(f"  last 5 cells:  {cells[-5:]}")

    # Distribution
    xs = [c[0] for c in cells]
    ys = [c[1] for c in cells]
    sources = Counter(c[2] for c in cells)
    atlas = Counter((c[3], c[4]) for c in cells)
    print(f"  x range: {min(xs)}..{max(xs)}")
    print(f"  y range: {min(ys)}..{max(ys)}")
    print(f"  source_id distribution: {dict(sources)}")
    print(f"  atlas coord distribution (top 8): {atlas.most_common(8)}")

    alt_counter = Counter(c[5] for c in cells)
    print(f"  alt_tile (6th field) distribution: {dict(alt_counter)}")


for layer in ("Floor", "Walls"):
    report(layer)
    print()
