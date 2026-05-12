#!/bin/bash
# Process generated coffee brewing art assets into correct sizes
# Uses macOS sips for resizing since PIL is not available

set -e

BRAIN="/Users/piotr/.gemini/antigravity/brain/d501b945-6b7d-4f24-bd29-09c778495aed"
DEST="/Users/piotr/Documents/Silly projects/pig-swine-rpg/godot/art/minigames/coffee"
PORTRAITS="/Users/piotr/Documents/Silly projects/pig-swine-rpg/godot/art/portraits/barista"

echo "=== Processing Coffee Machine Sprites (128x128) ==="

# Coffee machine sprites - resize to 128x128
for state in idle gurgle happy angry; do
    src=$(ls "$BRAIN"/coffee_machine_${state}_*.png 2>/dev/null | head -1)
    if [ -f "$src" ]; then
        cp "$src" "$DEST/coffee_machine_${state}.png"
        sips -z 128 128 "$DEST/coffee_machine_${state}.png" --out "$DEST/coffee_machine_${state}.png" > /dev/null 2>&1
        echo "  ✓ coffee_machine_${state}.png (128x128)"
    else
        echo "  ✗ MISSING coffee_machine_${state}"
    fi
done

echo ""
echo "=== Processing Coffee Cup Sprites (64x64) ==="

# Coffee cups - the sheet has 4 cups side by side
# We need to extract each as 64x64
# First resize the sheet proportionally, then crop
CUPS_SRC=$(ls "$BRAIN"/coffee_cups_*.png 2>/dev/null | head -1)
if [ -f "$CUPS_SRC" ]; then
    # The sheet is ~1024x1024 with 4 cups at roughly equal spacing
    # Resize to 256x256 first (4 x 64), then crop each 64x64 segment
    sips -z 256 256 "$CUPS_SRC" --out "$DEST/_cups_sheet.png" > /dev/null 2>&1
    
    # Crop each cup from the sheet
    sips -c 256 64 --cropOffset 0 0 "$DEST/_cups_sheet.png" --out "$DEST/coffee_cup_empty.png" > /dev/null 2>&1
    sips -c 256 64 --cropOffset 0 64 "$DEST/_cups_sheet.png" --out "$DEST/coffee_cup_fill_01.png" > /dev/null 2>&1
    sips -c 256 64 --cropOffset 0 128 "$DEST/_cups_sheet.png" --out "$DEST/coffee_cup_fill_02.png" > /dev/null 2>&1
    sips -c 256 64 --cropOffset 0 192 "$DEST/_cups_sheet.png" --out "$DEST/coffee_cup_fill_03.png" > /dev/null 2>&1
    
    # Resize to 64x64 final
    for f in coffee_cup_empty coffee_cup_fill_01 coffee_cup_fill_02 coffee_cup_fill_03; do
        sips -z 64 64 "$DEST/${f}.png" --out "$DEST/${f}.png" > /dev/null 2>&1
        echo "  ✓ ${f}.png (64x64)"
    done
    rm -f "$DEST/_cups_sheet.png"
else
    echo "  ✗ MISSING cups sheet"
fi

echo ""
echo "=== Processing Prompt Icons (32x32) ==="

# Prompt icons - sheet has 6 icons in a row
ICONS_SRC=$(ls "$BRAIN"/prompt_icons_*.png 2>/dev/null | head -1)
if [ -f "$ICONS_SRC" ]; then
    # Resize to 192x32 (6 x 32), then crop each 32x32
    sips -z 32 192 "$ICONS_SRC" --out "$DEST/_icons_sheet.png" > /dev/null 2>&1
    
    NAMES=("prompt_bean" "prompt_milk" "prompt_sugar" "prompt_stamp" "prompt_file" "prompt_mug")
    for i in 0 1 2 3 4 5; do
        offset=$((i * 32))
        name=${NAMES[$i]}
        sips -c 32 32 --cropOffset 0 $offset "$DEST/_icons_sheet.png" --out "$DEST/${name}.png" > /dev/null 2>&1
        echo "  ✓ ${name}.png (32x32)"
    done
    rm -f "$DEST/_icons_sheet.png"
else
    echo "  ✗ MISSING icons sheet"
fi

echo ""
echo "=== Processing Timing Line (8x96) ==="

TIMING_SRC=$(ls "$BRAIN"/timing_line_*.png 2>/dev/null | head -1)
if [ -f "$TIMING_SRC" ]; then
    cp "$TIMING_SRC" "$DEST/timing_line.png"
    sips -z 96 8 "$DEST/timing_line.png" --out "$DEST/timing_line.png" > /dev/null 2>&1
    echo "  ✓ timing_line.png (8x96)"
fi

echo ""
echo "=== Processing Meter Sprites (240x24) ==="

METERS_SRC=$(ls "$BRAIN"/meter_sprites_*.png 2>/dev/null | head -1)
if [ -f "$METERS_SRC" ]; then
    # Sheet has 4 bars stacked vertically
    # Resize to 240x96 (4 x 24), then crop each 240x24
    sips -z 96 240 "$METERS_SRC" --out "$DEST/_meters_sheet.png" > /dev/null 2>&1
    
    MNAMES=("meter_brew_bg" "meter_brew_fill" "meter_bitter_bg" "meter_bitter_fill")
    for i in 0 1 2 3; do
        offset=$((i * 24))
        name=${MNAMES[$i]}
        sips -c 24 240 --cropOffset $offset 0 "$DEST/_meters_sheet.png" --out "$DEST/${name}.png" > /dev/null 2>&1
        echo "  ✓ ${name}.png (240x24)"
    done
    rm -f "$DEST/_meters_sheet.png"
fi

echo ""
echo "=== Processing Result Stamps (96x64) ==="

for stamp in admitted objected; do
    src=$(ls "$BRAIN"/result_stamp_${stamp}_*.png 2>/dev/null | head -1)
    if [ -f "$src" ]; then
        cp "$src" "$DEST/result_stamp_${stamp}.png"
        sips -z 64 96 "$DEST/result_stamp_${stamp}.png" --out "$DEST/result_stamp_${stamp}.png" > /dev/null 2>&1
        echo "  ✓ result_stamp_${stamp}.png (96x64)"
    fi
done

echo ""
echo "=== Processing Feedback Effects ==="

EFFECTS_SRC=$(ls "$BRAIN"/feedback_effects_*.png 2>/dev/null | head -1)
if [ -f "$EFFECTS_SRC" ]; then
    # The effects sheet has 3 rows of sprites (sparkle, foam, puff)
    # Extract a representative from each row at the target sizes
    
    # Resize to workable size: 128x96 for 3 sections
    sips -z 96 128 "$EFFECTS_SRC" --out "$DEST/_effects_sheet.png" > /dev/null 2>&1
    
    # Sparkle: top section -> 16x16
    sips -c 32 32 --cropOffset 0 0 "$DEST/_effects_sheet.png" --out "$DEST/sparkle.png" > /dev/null 2>&1
    sips -z 16 16 "$DEST/sparkle.png" --out "$DEST/sparkle.png" > /dev/null 2>&1
    echo "  ✓ sparkle.png (16x16)"
    
    # Bitter foam: middle section -> 32x32
    sips -c 32 32 --cropOffset 32 32 "$DEST/_effects_sheet.png" --out "$DEST/bitter_foam.png" > /dev/null 2>&1
    echo "  ✓ bitter_foam.png (32x32)"
    
    # Puff offended: bottom section -> 32x32
    sips -c 32 32 --cropOffset 64 32 "$DEST/_effects_sheet.png" --out "$DEST/puff_offended.png" > /dev/null 2>&1
    echo "  ✓ puff_offended.png (32x32)"
    
    rm -f "$DEST/_effects_sheet.png"
fi

echo ""
echo "=== Processing Barista Portraits (512x512) ==="

for expr in perfect good okay bad machine_objects; do
    src=$(ls "$BRAIN"/barista_${expr}_*.png 2>/dev/null | head -1)
    if [ -f "$src" ]; then
        cp "$src" "$PORTRAITS/${expr}.png"
        sips -z 512 512 "$PORTRAITS/${expr}.png" --out "$PORTRAITS/${expr}.png" > /dev/null 2>&1
        echo "  ✓ barista/${expr}.png (512x512)"
    fi
done

echo ""
echo "=== Verifying all files ==="
echo "Coffee sprites:"
ls -la "$DEST"/*.png 2>/dev/null | awk '{print "  " $5 " " $NF}' | sed "s|$DEST/||"
echo ""
echo "Barista portraits:"
ls -la "$PORTRAITS"/*.png 2>/dev/null | awk '{print "  " $5 " " $NF}' | sed "s|$PORTRAITS/||"

echo ""
echo "=== Checking dimensions ==="
for f in "$DEST"/*.png; do
    dims=$(sips -g pixelWidth -g pixelHeight "$f" 2>/dev/null | grep pixel | awk '{print $2}' | tr '\n' 'x' | sed 's/x$//')
    basename=$(basename "$f")
    echo "  $basename: ${dims}"
done
for f in "$PORTRAITS"/*.png; do
    dims=$(sips -g pixelWidth -g pixelHeight "$f" 2>/dev/null | grep pixel | awk '{print $2}' | tr '\n' 'x' | sed 's/x$//')
    basename=$(basename "$f")
    echo "  barista/$basename: ${dims}"
done

echo ""
echo "Done!"
