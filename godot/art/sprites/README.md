# Sprite Generation & Regeneration Protocol

This directory contains the canonical world-layer character sprites for the Pig & Swine RPG, generated via Pixellab. The visual direction follows **Jacek Świdziński's "synthetic" minimalism** — sparse, functional, deliberately crude line drawings where characters are identifiable from silhouette alone.

For the full two-layer art direction (world sprites + portraits), see `CONVENTIONS.md` §Art direction.

## Current Runtime Warning

Do not start a full sprite regeneration pass until the sprite-size decision is
normalized. Current project facts disagree:

- `State.CHAR_HEIGHT` is 64.
- This protocol describes a 128-to-64 workflow.
- Many committed character PNGs are 112x112.
- `art/sprites/new/cula` contains 124x124 Pixellab output.
- `CONVENTIONS.md` currently mentions both 124x124 canonical sprites and
  64x64 y-sort examples.

For Chapter 1, use the existing runtime assets. New full walking sets should
wait for a single Art/Code decision on source size, runtime size, and y-sort
offset policy.

## The Świdziński Principle

**If a feature isn't visible at arm's length as a silhouette, remove it from the prompt.**

Characters are chess pieces: round blob in tight suit = Mr. Pig. Slim figure in oversized suit = Cula. Stooped figure in cardigan = Murrow. The simplicity IS the style — not a limitation.

## Generation Workflow

1. **Generate in Pixellab at 128×128** — more pixels = cleaner walking animations.
2. **Downscale to 64×64** with nearest-neighbor interpolation (Aseprite → Sprite Size → 50%, Nearest Neighbor). This step naturally "chunkifies" the sprite.
3. **Minimal cleanup (5–10 min max):** fix stray silhouette pixels, snap off-palette colors.
4. **Save both 128 and 64 versions** — keep 128 as source in `<char>/src_128/`.

## The Pixellab Protocol

- **One Session Per Character:** Generate all directions and frames for a single character in one Pixellab session.
- **Lock Metadata:** Lock the seed and Pixellab Character ID once a successful look is achieved.
- **Documentation:** Every character folder MUST contain a `PROMPT.txt` file recording the exact prompt, seed, Pixellab Character ID, template, view, and generation date.
- **Visual Continuity:** Re-generations must visually match the established "canon" look of the character. Compare new outputs against the existing set before committing.

## Prompt Construction Rules

Every character prompt follows a strict 3-part structure:
1. **Silhouette + One Feature:** ONE short sentence describing the character's body shape, posture, and single distinguishing clothing item. Drop everything that won't survive 128→64 downscale.
2. **Style Anchor (Verbatim):**
   > Minimal synthetic line drawing, sparse flat shapes, Polish satirical illustration, institutional mood, pixel-art, adult proportions, full body, hands at sides.
3. **Palette:** 5–6 hex codes from the shared palette-safe set.

### Negative Prompts
Every generation must use the **Negative Anchor**:
> detailed, shaded, gradient, anime, chibi, cute, big head, decorative, fantasy, realistic, 3D, held objects, facial expressions

Add character-specific negatives only where Pixellab tends to drift (e.g., `"raised hands"` for Whimsy, or `"four-legged pig, human in pig mask"` for the founders).

## Technical Constraints

### HARD RULES
- **NO held objects / raised hands:** Pixellab walking animations break with stuck poses.
- **NO facial detail:** At 64×64, faces are ~6 pixels. Personality lives in the portrait system, not the walking sprite.
- **NO chibi proportions:** Adult 1:4 or 1:5 head-to-body ratio. Fight Pixellab's drift explicitly.
- **Silhouette-first:** Body shape and posture distinguish characters, not color or face.

### Size
- **Generation Size:** 128×128 in Pixellab UI
- **Canonical Output Size:** 64×64 (after nearest-neighbor downscale)
- **Do not** include size descriptors in the prompt text.

## Shared Character Palette
All character sprites use colors from the palette-safe set (present in all six game palettes):
- `#1a1410` (Soot — outlines)
- `#0d0a08` (Ink — true black)
- `#e8e4d8` (Parchment — cream shirt/paper)
- `#1c2a40` (Navy — suits)
- `#7a1f2a` (Oxblood — tie/leather)
- `#5a2a4a` (Eggplant — Whimsy's blazer)
- `#c8a868` (Mustard — knitwear)
- `#d4b878` (Straw — sand/beige)
- `#e6b08a` (Warm Skin — skin tones)
- `#6a4a30` (Walnut — warm brown wool)
- `#f0c8c0` (Pig Pink — Mr. Pig, Mr. Swine)
- `#9a9088` (Plaster — gray hair)
