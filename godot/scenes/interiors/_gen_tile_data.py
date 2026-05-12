#!/usr/bin/env python3
"""Generate tile_data PackedInt32Array for pig_swine_office.tscn.

Grid layout:
  - Row -1 (y=-1): Wall tiles (source 1). 24 cells.
  - Rows 0–15 (y=0..15): Floor tiles (source 0). 24×16 = 384 cells.
  Total: 408 cells × 3 ints = 1224 ints in the PackedInt32Array.

Floor tile atlas (source 0, office_marble_tiles.png 192×128, 3×2 grid):
  6 variants: (0,0) (1,0) (2,0) (0,1) (1,1) (2,1)

Wall tile atlas (source 1, office_wall.png 384×64, 6×1 strip):
  (0,0)=left-cap, (1,0)..(4,0)=middle, (5,0)=right-cap

Encoding (Godot 4 TileMap format=2):
  Each cell = 3 int32: [cell_key, source_id, atlas_packed]
  cell_key = x_unsigned_16 | (y_signed_16 << 16)
  For negative y: use two's complement 16-bit → (y & 0xFFFF) << 16
  atlas_packed = atlas_x | (atlas_y << 16)
"""

import struct
import hashlib

SEED = 42
FLOOR_W = 24
FLOOR_H = 16  # rows 0..15
WALL_ROW = -1

# Floor tile variants: (atlas_x, atlas_y) for source 0
FLOOR_VARIANTS = [(0,0), (1,0), (2,0), (0,1), (1,1), (2,1)]

def cell_key(x: int, y: int) -> int:
    """Encode (x, y) into Godot's cell key format."""
    x_u16 = x & 0xFFFF
    y_u16 = y & 0xFFFF  # two's complement for negative y
    return x_u16 | (y_u16 << 16)

def atlas_packed(ax: int, ay: int) -> int:
    return ax | (ay << 16)

def deterministic_variant(x: int, y: int, seed: int) -> int:
    """Pick a floor variant index 0-5 deterministically from position."""
    h = hashlib.md5(f"{seed}:{x}:{y}".encode()).hexdigest()
    return int(h, 16) % len(FLOOR_VARIANTS)

def generate():
    ints = []
    
    # --- Wall row (y = -1), source 1 ---
    for x in range(FLOOR_W):
        ck = cell_key(x, WALL_ROW)
        src = 1
        if x == 0:
            ap = atlas_packed(0, 0)  # left end-cap
        elif x == FLOOR_W - 1:
            ap = atlas_packed(5, 0)  # right end-cap
        else:
            mid = ((x - 1) % 4) + 1  # cycle 1,2,3,4
            ap = atlas_packed(mid, 0)
        ints.extend([ck, src, ap])
    
    # --- Floor rows (y = 0..15), source 0 ---
    for y in range(FLOOR_H):
        for x in range(FLOOR_W):
            ck = cell_key(x, y)
            src = 0
            vi = deterministic_variant(x, y, SEED)
            ax, ay = FLOOR_VARIANTS[vi]
            ap = atlas_packed(ax, ay)
            ints.extend([ck, src, ap])
    
    return ints

def to_signed_int32(val: int) -> int:
    """Convert unsigned 32-bit to signed 32-bit (Python int)."""
    if val >= 0x80000000:
        return val - 0x100000000
    return val

def main():
    ints = generate()
    
    # Convert to signed int32 for Godot's PackedInt32Array
    signed = [to_signed_int32(v) for v in ints]
    
    # Verify counts
    wall_cells = FLOOR_W
    floor_cells = FLOOR_W * FLOOR_H
    total_cells = wall_cells + floor_cells
    total_ints = total_cells * 3
    
    assert len(signed) == total_ints, f"Expected {total_ints} ints, got {len(signed)}"
    assert floor_cells == 384, f"Expected 384 floor cells, got {floor_cells}"
    assert wall_cells == 24, f"Expected 24 wall cells, got {wall_cells}"
    
    print(f"# Wall cells: {wall_cells}")
    print(f"# Floor cells: {floor_cells}")
    print(f"# Total cells: {total_cells}")
    print(f"# Total ints: {total_ints}")
    print()
    
    # Output the PackedInt32Array content
    int_strs = [str(v) for v in signed]
    line = "PackedInt32Array(" + ", ".join(int_strs) + ")"
    print(line)

if __name__ == "__main__":
    main()
