# Tileset Generation Brief

This document formalizes the visual brief for the primary room tilesets in the Pig & Swine RPG. It serves as a guide for future Pixellab generation sessions and Aseprite post-processing to ensure cohesive, distinct, and consistent environments.

**Master palette:** "Marszałkowska" (Palette C) — 18 colors. See `CONVENTIONS.md` §Game palette for the full table. Each room draws a 5–6 color subset; no two rooms share more than 2 palette colors (excluding Ink/Soot).

**Sprite Generation Rules (from CONVENTIONS.md):**
- **Style Anchor:** "Polish komiks illustration, clean ink-line outlines, flat warm earth-tone colors, PRL-era mood, pixel-art"
- *(Note: Excludes "full body" and "hands at sides" which are reserved for character sprites.)*

**Distinctness Check:** No two rooms share more than 2 palette colors (excluding Ink `#0d0a08` and Soot `#1a1410`).

---

## 1. pig_swine_office

**Mood:** Cluttered, warm, panicked
**Tile Dimensions:** 64×64 native source

### Floor
- **Description:** Cream marble with subtle gray veining, slightly worn.
- **Pixellab Prompt:** Polish komiks illustration, clean ink-line outlines, flat warm earth-tone colors, PRL-era mood, pixel-art, top-down floor texture, cream marble tiles with subtle gray veining, slightly worn edges.
- **Post-processing Notes:** Convert to indexed-mode in Aseprite to exactly 6 colors to unify color drift. Pick the best 3-5 variants from each generation batch.

### Wall
- **Description:** Warm honey wood paneling, vertical planks, dark trim at top. 3/4-perspective convention (wall face visible plus thin top edge).
- **Pixellab Prompt:** Polish komiks illustration, clean ink-line outlines, flat warm earth-tone colors, PRL-era mood, pixel-art, interior wall face, 3/4 perspective, warm honey wood paneling, vertical planks, dark trim at top.
- **Post-processing Notes:** Convert to indexed-mode in Aseprite to exactly 6 colors. Pick the best 3-5 variants from each generation batch.

### Palette subset (6 colors from Marszałkowska)
- `#e8e4d8` (Parchment) — marble floor base
- `#d4b878` (Straw) — floor veining, light wood
- `#9a9088` (Plaster) — marble veining, wear
- `#1a1410` (Soot) — outlines, darkest trim
- `#c8a868` (Mustard) — wood highlight
- `#6a4a30` (Walnut) — wood paneling, dark trim

---

## 2. archive_room

**Mood:** Sparse, reverent, dusty
**Tile Dimensions:** 64×64 native source

### Floor
- **Description:** Cold concrete or linoleum, cool shadow register, coated in a fine layer of gray dust, neglected wear level.
- **Pixellab Prompt:** Polish komiks illustration, clean ink-line outlines, flat warm earth-tone colors, PRL-era mood, pixel-art, top-down floor texture, cold concrete linoleum floor, dusty, neglected.
- **Post-processing Notes:** Convert to indexed-mode in Aseprite to exactly 5 colors to unify color drift. Pick the best 3-5 variants from each generation batch.

### Wall
- **Description:** Institutional painted cinderblock or stucco, deep eggplant/navy shadows, 3/4 perspective convention (wall face visible plus thin top edge), moisture/dust stained baseboard.
- **Pixellab Prompt:** Polish komiks illustration, clean ink-line outlines, flat warm earth-tone colors, PRL-era mood, pixel-art, interior wall face, 3/4 perspective, institutional painted cinderblock, dusty baseboard.
- **Post-processing Notes:** Convert to indexed-mode in Aseprite to exactly 5 colors. Pick the best 3-5 variants from each generation batch.

### Palette subset (5 colors from Marszałkowska)
- `#5a5a60` (PKiN Gray) — concrete floor
- `#1c2a40` (Navy) — deep shadow
- `#5a2a4a` (Eggplant) — institutional paint accent
- `#0d0a08` (Ink) — darkest crevice
- `#9a9088` (Plaster) — dust layer

---

## 3. cafe_paragraf

**Mood:** Warm, social, gossipy
**Tile Dimensions:** 64×64 native source

### Floor
- **Description:** Well-trodden terracotta or warm hardwood flooring, inviting warm skin/brown register, polished but scratched from chairs.
- **Pixellab Prompt:** Polish komiks illustration, clean ink-line outlines, flat warm earth-tone colors, PRL-era mood, pixel-art, top-down floor texture, warm terracotta tile hardwood floor, scratched, inviting.
- **Post-processing Notes:** Convert to indexed-mode in Aseprite to exactly 5 colors to unify color drift. Pick the best 3-5 variants from each generation batch.

### Wall
- **Description:** Exposed oxblood brick with warm ambient uplighting implied in the colors, 3/4 perspective convention (wall face visible plus thin top edge).
- **Pixellab Prompt:** Polish komiks illustration, clean ink-line outlines, flat warm earth-tone colors, PRL-era mood, pixel-art, interior wall face, 3/4 perspective, exposed oxblood brick, warm ambient lighting tones.
- **Post-processing Notes:** Convert to indexed-mode in Aseprite to exactly 5 colors. Pick the best 3-5 variants from each generation batch.

### Palette subset (5 colors from Marszałkowska)
- `#7a1f2a` (Oxblood) — brick, wall accent
- `#f0c8c0` (Pig Pink) — warm terracotta
- `#e6b08a` (Warm Skin) — wood, warmth
- `#6a4a30` (Walnut) — dark wood, furniture
- `#0d0a08` (Ink) — outlines

---

## 4. office_street

**Mood:** Chaotic, transitional, loud
**Tile Dimensions:** 64×64 native source

### Floor
- **Description:** Cracked paving stones and concrete sidewalk, cool navy/cream highlights register, uneven, stained with city life and occasional weeds.
- **Pixellab Prompt:** Polish komiks illustration, clean ink-line outlines, flat warm earth-tone colors, PRL-era mood, pixel-art, top-down floor texture, cracked concrete paving stones sidewalk, city streets.
- **Post-processing Notes:** Convert to indexed-mode in Aseprite to exactly 5 colors to unify color drift. Pick the best 3-5 variants from each generation batch.

### Wall
- **Description:** Exterior brutalist concrete mixed with aged masonry, navy shadows and cream/mustard highlights, 3/4 perspective convention (wall face visible plus thin top edge), slightly imposing.
- **Pixellab Prompt:** Polish komiks illustration, clean ink-line outlines, flat warm earth-tone colors, PRL-era mood, pixel-art, exterior building wall face, 3/4 perspective, brutalist concrete masonry facade, imposing.
- **Post-processing Notes:** Convert to indexed-mode in Aseprite to exactly 5 colors. Pick the best 3-5 variants from each generation batch.

### Palette subset (6 colors from Marszałkowska)
- `#5a5a60` (PKiN Gray) — concrete, brutalist base
- `#e8e4d8` (Parchment) — cream highlights
- `#d84040` (Neon Red) — kiosk signage, accent
- `#3a6848` (Tram Green) — tram stop, weeds
- `#0d0a08` (Ink) — outlines, crevices
- `#486880` (Plate Glass) — building windows
