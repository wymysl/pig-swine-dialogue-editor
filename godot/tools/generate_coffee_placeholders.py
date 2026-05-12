#!/usr/bin/env python3
"""
Generate pixel-art placeholder sprites for the coffee brewing mini-game.
Uses only Python stdlib (struct + zlib for raw PNG encoding).
These are functional placeholders with correct dimensions and palette-safe colors.

Usage: python3 tools/generate_coffee_placeholders.py
"""

import struct
import zlib
import os

BASE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art", "minigames", "coffee")
PORTRAITS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art", "portraits", "barista")

# Milk Bar palette colors (R, G, B, A)
INK = (13, 10, 8, 255)
SOOT = (26, 20, 16, 255)
WALNUT = (106, 74, 48, 255)
MUSTARD = (200, 168, 104, 255)
PARCHMENT = (232, 228, 216, 255)
PLASTER = (154, 144, 136, 255)
WARM_SHADOW = (74, 52, 36, 255)
MILK_BAR_GREEN = (168, 184, 156, 255)
OXBLOOD = (122, 31, 42, 255)
TRANSPARENT = (0, 0, 0, 0)
ESPRESSO = (58, 42, 28, 255)  # Praga Nowa espresso
BREW_AMBER = (200, 168, 104, 255)
BITTER_BROWN = (106, 74, 48, 255)
INDICATOR_GREEN = (74, 140, 74, 255)
INDICATOR_AMBER = (200, 160, 60, 255)
INDICATOR_RED = (180, 50, 50, 255)
STEAM_GRAY = (180, 175, 168, 200)
WHITE_CUP = (232, 228, 216, 255)
COFFEE_FILL = (58, 32, 16, 255)
FOAM = (200, 168, 104, 255)
SPARKLE_GOLD = (232, 200, 64, 255)
SPARKLE_WHITE = (255, 255, 240, 255)


def make_png(width, height, pixels):
    """Create a PNG file from raw RGBA pixel data.
    pixels: list of (R, G, B, A) tuples, row-major order.
    """
    def chunk(chunk_type, data):
        c = chunk_type + data
        crc = struct.pack('>I', zlib.crc32(c) & 0xFFFFFFFF)
        return struct.pack('>I', len(data)) + c + crc

    raw = b''
    for y in range(height):
        raw += b'\x00'  # filter byte
        for x in range(width):
            px = pixels[y * width + x]
            raw += struct.pack('BBBB', *px)

    header = b'\x89PNG\r\n\x1a\n'
    ihdr = chunk(b'IHDR', struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0))
    idat = chunk(b'IDAT', zlib.compress(raw, 9))
    iend = chunk(b'IEND', b'')
    return header + ihdr + idat + iend


def fill_rect(pixels, w, h, x0, y0, x1, y1, color):
    """Fill a rectangle in the pixel buffer."""
    for y in range(max(0, y0), min(h, y1)):
        for x in range(max(0, x0), min(w, x1)):
            pixels[y * w + x] = color


def draw_outline(pixels, w, h, x0, y0, x1, y1, color):
    """Draw a rectangle outline."""
    for x in range(x0, x1):
        if 0 <= y0 < h and 0 <= x < w:
            pixels[y0 * w + x] = color
        if 0 <= (y1-1) < h and 0 <= x < w:
            pixels[(y1-1) * w + x] = color
    for y in range(y0, y1):
        if 0 <= y < h and 0 <= x0 < w:
            pixels[y * w + x0] = color
        if 0 <= y < h and 0 <= (x1-1) < w:
            pixels[y * w + (x1-1)] = color


def draw_circle_outline(pixels, w, h, cx, cy, r, color):
    """Draw a rough circle outline using midpoint algorithm."""
    x, y = r, 0
    d = 1 - r
    while x >= y:
        for dx, dy in [(x,y),(y,x),(-x,y),(-y,x),(x,-y),(y,-x),(-x,-y),(-y,-x)]:
            px, py = cx + dx, cy + dy
            if 0 <= px < w and 0 <= py < h:
                pixels[py * w + px] = color
        y += 1
        if d < 0:
            d += 2 * y + 1
        else:
            x -= 1
            d += 2 * (y - x) + 1


def draw_pixel(pixels, w, h, x, y, color):
    if 0 <= x < w and 0 <= y < h:
        pixels[y * w + x] = color


def save_png(path, width, height, pixels):
    data = make_png(width, height, pixels)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'wb') as f:
        f.write(data)
    size_kb = len(data) / 1024
    print(f"  ✓ {os.path.basename(path)} ({width}×{height}, {size_kb:.1f} KB)")


# ============================================================
# Coffee Machine Sprites (128×128)
# ============================================================

def make_coffee_machine(indicator_color, steam=False, tilt=0, shake=False):
    """Generate a coffee machine sprite with variants."""
    w, h = 128, 128
    pixels = [TRANSPARENT] * (w * h)
    
    # Body offset for tilt
    ox = tilt
    
    # Main body - dark brown top section
    fill_rect(pixels, w, h, 30+ox, 20, 98+ox, 50, SOOT)
    # Tan middle section
    fill_rect(pixels, w, h, 30+ox, 50, 98+ox, 85, MUSTARD)
    # Dark brown lower housing
    fill_rect(pixels, w, h, 34+ox, 85, 94+ox, 100, WALNUT)
    # Drip tray
    fill_rect(pixels, w, h, 28+ox, 100, 100+ox, 108, SOOT)
    fill_rect(pixels, w, h, 32+ox, 100, 96+ox, 106, WARM_SHADOW)
    
    # Outline
    draw_outline(pixels, w, h, 29+ox, 19, 99+ox, 109, INK)
    draw_outline(pixels, w, h, 30+ox, 50, 98+ox, 51, SOOT)
    
    # Dispenser nozzle
    fill_rect(pixels, w, h, 58+ox, 80, 70+ox, 100, SOOT)
    
    # Indicator light
    fill_rect(pixels, w, h, 80+ox, 60, 86+ox, 66, indicator_color)
    
    # Steam puff
    if steam:
        for dy, dx in [(14, 60), (12, 64), (10, 58), (8, 62), (6, 66)]:
            draw_pixel(pixels, w, h, dx+ox, dy, STEAM_GRAY)
            draw_pixel(pixels, w, h, dx+ox+1, dy, STEAM_GRAY)
            draw_pixel(pixels, w, h, dx+ox, dy+1, STEAM_GRAY)
    
    # Shake lines
    if shake:
        for y in range(40, 90, 8):
            draw_pixel(pixels, w, h, 22, y, INK)
            draw_pixel(pixels, w, h, 20, y+2, INK)
            draw_pixel(pixels, w, h, 106, y, INK)
            draw_pixel(pixels, w, h, 108, y+2, INK)
    
    return w, h, pixels


print("=== Coffee Machine Sprites (128×128) ===")

w, h, px = make_coffee_machine(INDICATOR_GREEN)
save_png(os.path.join(BASE, "coffee_machine_idle.png"), w, h, px)

w, h, px = make_coffee_machine(INDICATOR_AMBER, steam=True)
save_png(os.path.join(BASE, "coffee_machine_gurgle.png"), w, h, px)

w, h, px = make_coffee_machine(INDICATOR_GREEN, tilt=3)
save_png(os.path.join(BASE, "coffee_machine_happy.png"), w, h, px)

w, h, px = make_coffee_machine(INDICATOR_RED, steam=True, tilt=-2, shake=True)
save_png(os.path.join(BASE, "coffee_machine_angry.png"), w, h, px)


# ============================================================
# Coffee Cup Fill Stack (64×64)
# ============================================================

def make_coffee_cup(fill_level=0.0):
    """Generate a coffee cup. fill_level 0..1."""
    w, h = 64, 64
    pixels = [TRANSPARENT] * (w * h)
    
    # Cup body
    cup_left, cup_right = 14, 46
    cup_top, cup_bottom = 18, 52
    
    # Cup interior (lighter)
    fill_rect(pixels, w, h, cup_left+2, cup_top+2, cup_right-2, cup_bottom-2, PARCHMENT)
    
    # Coffee fill
    if fill_level > 0:
        fill_top = int(cup_bottom - 2 - (cup_bottom - cup_top - 4) * fill_level)
        fill_rect(pixels, w, h, cup_left+2, fill_top, cup_right-2, cup_bottom-2, COFFEE_FILL)
        # Foam line at top of coffee
        if fill_level >= 0.9:
            fill_rect(pixels, w, h, cup_left+2, fill_top, cup_right-2, fill_top+2, FOAM)
    
    # Cup outline
    draw_outline(pixels, w, h, cup_left, cup_top, cup_right, cup_bottom, INK)
    # Cup rim highlight
    fill_rect(pixels, w, h, cup_left+1, cup_top, cup_right-1, cup_top+2, WHITE_CUP)
    
    # Handle
    fill_rect(pixels, w, h, cup_right, 26, cup_right+8, 28, INK)
    fill_rect(pixels, w, h, cup_right+6, 28, cup_right+8, 42, INK)
    fill_rect(pixels, w, h, cup_right, 42, cup_right+8, 44, INK)
    
    # Saucer
    fill_rect(pixels, w, h, 10, cup_bottom, 54, cup_bottom+4, PLASTER)
    draw_outline(pixels, w, h, 10, cup_bottom, 54, cup_bottom+4, INK)
    
    return w, h, pixels


print("\n=== Coffee Cup Fill Stack (64×64) ===")

w, h, px = make_coffee_cup(0.0)
save_png(os.path.join(BASE, "coffee_cup_empty.png"), w, h, px)

w, h, px = make_coffee_cup(0.33)
save_png(os.path.join(BASE, "coffee_cup_fill_01.png"), w, h, px)

w, h, px = make_coffee_cup(0.66)
save_png(os.path.join(BASE, "coffee_cup_fill_02.png"), w, h, px)

w, h, px = make_coffee_cup(1.0)
save_png(os.path.join(BASE, "coffee_cup_fill_03.png"), w, h, px)


# ============================================================
# Prompt Icons (32×32)
# ============================================================

def make_icon_bean():
    w, h = 32, 32
    px = [TRANSPARENT] * (w * h)
    # Oval coffee bean
    for y in range(10, 24):
        for x in range(9, 23):
            dx = x - 16
            dy = y - 17
            if dx*dx*1.5 + dy*dy < 50:
                px[y * w + x] = WALNUT
    # Center crease line
    for y in range(12, 22):
        draw_pixel(px, w, h, 16, y, SOOT)
    # Outline
    draw_circle_outline(px, w, h, 16, 17, 7, INK)
    return w, h, px

def make_icon_milk():
    w, h = 32, 32
    px = [TRANSPARENT] * (w * h)
    # Milk carton
    fill_rect(px, w, h, 10, 8, 22, 24, PARCHMENT)
    draw_outline(px, w, h, 10, 8, 22, 24, INK)
    # Carton top fold
    fill_rect(px, w, h, 12, 6, 20, 8, PARCHMENT)
    draw_outline(px, w, h, 12, 6, 20, 8, INK)
    # "MILK" label area
    fill_rect(px, w, h, 12, 14, 20, 18, MUSTARD)
    return w, h, px

def make_icon_sugar():
    w, h = 32, 32
    px = [TRANSPARENT] * (w * h)
    # Sugar cube - angular
    fill_rect(px, w, h, 10, 10, 22, 22, PARCHMENT)
    draw_outline(px, w, h, 10, 10, 22, 22, INK)
    # Highlight
    fill_rect(px, w, h, 11, 11, 15, 15, (245, 240, 230, 255))
    return w, h, px

def make_icon_stamp():
    w, h = 32, 32
    px = [TRANSPARENT] * (w * h)
    # Stamp body (square base)
    fill_rect(px, w, h, 8, 16, 24, 24, WALNUT)
    draw_outline(px, w, h, 8, 16, 24, 24, INK)
    # Handle on top
    fill_rect(px, w, h, 13, 8, 19, 16, MUSTARD)
    draw_outline(px, w, h, 13, 8, 19, 16, INK)
    # Stamp bottom surface (red ink hint)
    fill_rect(px, w, h, 9, 22, 23, 24, OXBLOOD)
    return w, h, px

def make_icon_file():
    w, h = 32, 32
    px = [TRANSPARENT] * (w * h)
    # Folded document
    fill_rect(px, w, h, 9, 6, 23, 26, PARCHMENT)
    draw_outline(px, w, h, 9, 6, 23, 26, INK)
    # Fold corner
    fill_rect(px, w, h, 18, 6, 23, 11, PLASTER)
    draw_pixel(px, w, h, 18, 11, INK)
    for i in range(5):
        draw_pixel(px, w, h, 18+i, 6+i, INK)
    # Text lines
    for y_line in [14, 17, 20]:
        fill_rect(px, w, h, 11, y_line, 21, y_line+1, PLASTER)
    return w, h, px

def make_icon_mug():
    w, h = 32, 32
    px = [TRANSPARENT] * (w * h)
    # Mug body
    fill_rect(px, w, h, 9, 10, 21, 24, WALNUT)
    draw_outline(px, w, h, 9, 10, 21, 24, INK)
    # Handle
    fill_rect(px, w, h, 21, 13, 26, 15, INK)
    fill_rect(px, w, h, 24, 15, 26, 20, INK)
    fill_rect(px, w, h, 21, 20, 26, 22, INK)
    # Coffee surface
    fill_rect(px, w, h, 10, 11, 20, 14, COFFEE_FILL)
    # Steam wisps
    draw_pixel(px, w, h, 13, 7, STEAM_GRAY)
    draw_pixel(px, w, h, 16, 6, STEAM_GRAY)
    draw_pixel(px, w, h, 14, 8, STEAM_GRAY)
    return w, h, px


print("\n=== Prompt Icons (32×32) ===")

for name, fn in [("prompt_bean", make_icon_bean), ("prompt_milk", make_icon_milk),
                  ("prompt_sugar", make_icon_sugar), ("prompt_stamp", make_icon_stamp),
                  ("prompt_file", make_icon_file), ("prompt_mug", make_icon_mug)]:
    w, h, px = fn()
    save_png(os.path.join(BASE, f"{name}.png"), w, h, px)


# ============================================================
# Timing Line (8×96)
# ============================================================

print("\n=== Timing Line (8×96) ===")

w, h = 8, 96
px = [TRANSPARENT] * (w * h)
# Outline
draw_outline(px, w, h, 0, 0, 8, 96, INK)
# Fill
fill_rect(px, w, h, 1, 1, 7, 95, MUSTARD)
save_png(os.path.join(BASE, "timing_line.png"), w, h, px)


# ============================================================
# Meter Sprites (240×24)
# ============================================================

print("\n=== Meter Sprites (240×24) ===")

# Brew quality background
w, h = 240, 24
px = [TRANSPARENT] * (w * h)
draw_outline(px, w, h, 0, 0, 240, 24, SOOT)
draw_outline(px, w, h, 1, 1, 239, 23, WALNUT)
save_png(os.path.join(BASE, "meter_brew_bg.png"), w, h, px)

# Brew quality fill
px = [TRANSPARENT] * (w * h)
fill_rect(px, w, h, 0, 0, 240, 24, BREW_AMBER)
save_png(os.path.join(BASE, "meter_brew_fill.png"), w, h, px)

# Bitterness background
px = [TRANSPARENT] * (w * h)
draw_outline(px, w, h, 0, 0, 240, 24, SOOT)
draw_outline(px, w, h, 1, 1, 239, 23, WALNUT)
save_png(os.path.join(BASE, "meter_bitter_bg.png"), w, h, px)

# Bitterness fill
px = [TRANSPARENT] * (w * h)
fill_rect(px, w, h, 0, 0, 240, 24, BITTER_BROWN)
save_png(os.path.join(BASE, "meter_bitter_fill.png"), w, h, px)


# ============================================================
# Result Stamps (96×64)
# ============================================================

def make_stamp(text_rows, ink_color):
    w, h = 96, 64
    px = [TRANSPARENT] * (w * h)
    # Circular border
    draw_circle_outline(px, w, h, 48, 32, 28, ink_color)
    draw_circle_outline(px, w, h, 48, 32, 26, ink_color)
    # Inner circle
    draw_circle_outline(px, w, h, 48, 32, 22, ink_color)
    # Simple horizontal text lines (decorative)
    for i, y_pos in enumerate([26, 36]):
        row_width = 30 if i == 0 else 20
        fill_rect(px, w, h, 48 - row_width//2, y_pos, 48 + row_width//2, y_pos + 4, ink_color)
    return w, h, px


print("\n=== Result Stamps (96×64) ===")

w, h, px = make_stamp(["DOPUSZCZONY", "DO AKT"], OXBLOOD)
save_png(os.path.join(BASE, "result_stamp_admitted.png"), w, h, px)

w, h, px = make_stamp(["SPRZECIW", "WNIESIONY"], PLASTER)
save_png(os.path.join(BASE, "result_stamp_objected.png"), w, h, px)


# ============================================================
# Visual Feedback Sprites
# ============================================================

print("\n=== Visual Feedback Sprites ===")

# Sparkle (16×16)
w, h = 16, 16
px = [TRANSPARENT] * (w * h)
# 4-point star
draw_pixel(px, w, h, 8, 4, SPARKLE_GOLD)
draw_pixel(px, w, h, 8, 5, SPARKLE_GOLD)
draw_pixel(px, w, h, 8, 6, SPARKLE_WHITE)
draw_pixel(px, w, h, 8, 7, SPARKLE_WHITE)
draw_pixel(px, w, h, 8, 8, SPARKLE_WHITE)
draw_pixel(px, w, h, 8, 9, SPARKLE_WHITE)
draw_pixel(px, w, h, 8, 10, SPARKLE_GOLD)
draw_pixel(px, w, h, 8, 11, SPARKLE_GOLD)
draw_pixel(px, w, h, 4, 8, SPARKLE_GOLD)
draw_pixel(px, w, h, 5, 8, SPARKLE_GOLD)
draw_pixel(px, w, h, 6, 8, SPARKLE_WHITE)
draw_pixel(px, w, h, 7, 8, SPARKLE_WHITE)
draw_pixel(px, w, h, 9, 8, SPARKLE_WHITE)
draw_pixel(px, w, h, 10, 8, SPARKLE_WHITE)
draw_pixel(px, w, h, 11, 8, SPARKLE_GOLD)
draw_pixel(px, w, h, 12, 8, SPARKLE_GOLD)
# Diagonal accents
for d in [(6,6),(10,6),(6,10),(10,10)]:
    draw_pixel(px, w, h, d[0], d[1], SPARKLE_GOLD)
save_png(os.path.join(BASE, "sparkle.png"), w, h, px)

# Bitter foam (32×32)
w, h = 32, 32
px = [TRANSPARENT] * (w * h)
# Messy splat shape
for y in range(10, 24):
    for x in range(8, 24):
        dx = x - 16
        dy = y - 17
        if dx*dx + dy*dy < 45 + (hash((x*7+y*13)) % 8):
            color = COFFEE_FILL if (x + y) % 3 != 0 else WALNUT
            px[y * w + x] = color
save_png(os.path.join(BASE, "bitter_foam.png"), w, h, px)

# Puff offended (32×32)
w, h = 32, 32
px = [TRANSPARENT] * (w * h)
# Steam cloud shape
for y in range(8, 24):
    for x in range(8, 24):
        dx = x - 16
        dy = y - 16
        if dx*dx + dy*dy < 52 + (hash((x*11+y*7)) % 10):
            px[y * w + x] = STEAM_GRAY
# Angry motion lines
for d in [(-1, 0), (1, 0)]:
    for i in range(3):
        draw_pixel(px, w, h, 4 + d[0]*i, 12+i*3, INK)
        draw_pixel(px, w, h, 28 + d[0]*i, 12+i*3, INK)
save_png(os.path.join(BASE, "puff_offended.png"), w, h, px)


# ============================================================
# Barista Portraits (512×512) — warm gouache placeholders
# These are solid-color placeholders with face outlines.
# The real portraits from generate_image need manual copy.
# ============================================================

print("\n=== Barista Portrait Placeholders (512×512) ===")
print("  NOTE: Real barista portraits were generated via generate_image.")
print("  The generated images in the brain directory need manual copy by the human.")
print("  Creating minimal placeholders so the scene doesn't show pink missing textures.")

for expr in ["perfect", "good", "okay", "bad", "machine_objects"]:
    w, h = 512, 512
    px = [PARCHMENT] * (w * h)
    # Simple face outline
    draw_circle_outline(px, w, h, 256, 220, 120, WALNUT)
    draw_circle_outline(px, w, h, 256, 220, 119, WALNUT)
    # Eyes
    fill_rect(px, w, h, 210, 200, 230, 210, SOOT)
    fill_rect(px, w, h, 280, 200, 300, 210, SOOT)
    # Mouth varies by expression
    if expr == "perfect":
        # Smile
        for x in range(230, 282):
            y = 270 + (x-256)*(x-256)//200
            draw_pixel(px, w, h, x, y, SOOT)
    elif expr == "good":
        # Slight smile
        fill_rect(px, w, h, 240, 268, 272, 272, SOOT)
    elif expr == "okay":
        # Flat
        fill_rect(px, w, h, 235, 270, 277, 274, SOOT)
    elif expr == "bad":
        # Frown
        for x in range(230, 282):
            y = 280 - (x-256)*(x-256)//300
            draw_pixel(px, w, h, x, y, SOOT)
    else:  # machine_objects
        # Deadpan
        fill_rect(px, w, h, 235, 270, 277, 274, PLASTER)
    
    # Apron indication
    fill_rect(px, w, h, 180, 340, 332, 512, PARCHMENT)
    draw_outline(px, w, h, 180, 340, 332, 480, WALNUT)
    
    save_png(os.path.join(PORTRAITS, f"{expr}.png"), w, h, px)


print("\n=== Summary ===")
coffee_files = [f for f in os.listdir(BASE) if f.endswith('.png')]
portrait_files = [f for f in os.listdir(PORTRAITS) if f.endswith('.png')]
print(f"  Coffee sprites: {len(coffee_files)} files")
print(f"  Barista portraits: {len(portrait_files)} files")
print(f"  Total: {len(coffee_files) + len(portrait_files)} files")
print("\nAll assets generated successfully!")
