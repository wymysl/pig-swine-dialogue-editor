# Project Conventions

Authoritative spec for the Pig & Swine RPG Godot project. Every script, scene, and asset adheres to these. Active divergences are tracked at the bottom and resolved in dedicated follow-up prompts.

## Canonical numbers

- **Viewport**: 1280×720 (16:9). Window override 2560×1440 (clean 2× for editor preview on 1440p+ monitors). `canvas_items` stretch with `fractional` mode.
- **Texture filter**: nearest (`default_texture_filter=0`) — pixel-art renders crisp.
- **Tile grid (layout convention)**: 64×64 px. Visible play area = 20×11.25 tiles. Used for positioning and authoring discipline; not enforced by a Godot TileMap node (see Floor system below).
- **Character sprites (canonical)**: 124×124 px, 8-direction (idle + walk + run). Generated via Pixellab at 124×124 (no downscale step). Previous passes at 180×180, 112×112, and 128×128 are superseded.
- **Walk-animation policy**: 8-dir idle for everyone; 8-dir walk for Cula (player); 4-cardinal walk for NPCs (diagonal walk states map to nearest cardinal animation).
- **Movement**: free 8-way via CharacterBody2D, NOT grid-locked. Diagonal velocity normalised (`velocity = input.normalized() * speed`). Walk 96 px/s, sprint 1.6×.
- **Y-sort**: enabled on every interior root. Every character/prop Sprite2D has `offset.y` set so the node origin sits at the figure's feet.
- **Camera**: Camera2D with `position_smoothing_enabled = true`, `limit_*` set to room bounds. Tiny rooms lock the camera; large rooms scroll.
- **Target max interior room dimension**: 20×11 tiles (1280×704 px) — fits entirely in the viewport with no scrolling. Streets and plazas may exceed.

## Y-sort and Sprite2D origin convention

**Rule (canonical as of 2026-05-11):** Every interior room root node must have `y_sort_enabled = true`. Every character `Sprite2D` and every tall prop `Sprite2D` must have `offset.y` set so that the node origin sits at the figure's feet.

**Formula:**
```
offset.y = -(texture_height / 2)
```
This works because Godot Sprite2D is centered by default (`centered = true`): the texture is drawn from `−height/2` to `+height/2` around the node origin. Shifting by `−height/2` moves the entire sprite upward so the bottom edge lands at Y = 0 (the node's world position = the figure's feet).

**Do NOT hard-code a constant.** Read the actual PNG header dimensions for each sprite. Current canonical sizes:
- Character sprites (Cula, Mr. Pig, Murrow, Asia, Crab, Whimsy…): **64 × 64 px** → `offset.y = -32`
- Bookshelf: **128 × 128 px** → `offset.y = -64`
- Printer, Fern: **80 × 80 px** → `offset.y = -40`
- CoffeeMachine: **64 × 64 px** → `offset.y = -32`

**Scope:** applies to every `Sprite2D` that stands in world space (characters, tall props). Wall-mounted sprites that already use a negative `z_index` (windows, calendars, clocks) are pinned behind all actors by z_index and are exempt from this rule.

**Verification:** `tests/test_ysort_canon.gd` enforces this rule headlessly. All interior scenes are checked on every CI run.

## State autoload constants

`State` exports the canonical numbers for any script to reference by name:
- `State.TILE_SIZE` (64)
- `State.CHAR_HEIGHT` (64)
- `State.VIEWPORT_SIZE` (Vector2i(1280, 720))

## Game palettes — Warsaw multi-palette system

Six Warsaw-themed palettes adopted 2026-05-11. Different scenes, interiors, and chapters draw from different palettes to create distinct moods. Characters use a shared subset of palette-safe colors (see §Sprite generation rules). Swatch PNGs for all six live in `art/palettes/`.

### Shared character colors (palette-safe across all six)

These colors appear in every palette and are safe for character sprites:

| Hex | Name | Use |
|-----|------|-----|
| `#0d0a08` | Ink | True black, text |
| `#1a1410` | Soot | Outlines, darkest shadow |
| `#e6b08a` | Warm Skin | Skin tones |
| `#f0c8c0` | Pig Pink | Pig/Swine |
| `#1c2a40` | Navy | Suits, night shadow |
| `#5a2a4a` | Eggplant | Whimsy's blazer |
| `#6a4a30` | Walnut | Wood, furniture |
| `#9a9088` | Plaster | Gray hair, aged walls |

### Palette A: "Milk Bar" — warm institutional (18 colors)
`art/palettes/milk_bar_palette.png`
Mood: bar mleczny under a 40-watt bulb. Cozy, faded, amber.
Scene assignments: interior fallback, warm office lighting.
Revised 2026-05-11: killed two duplicate near-blacks. Added `#4a3424` Warm Shadow (interior shading) and `#a8b89c` Milk-Bar Wall Green (signature PRL canteen wall color — previously missing).

### Palette B: "Kiosk RUCH" — gray + signage (18 colors)
`art/palettes/kiosk_ruch_palette.png`
Mood: concrete housing blocks, tram stops, newsstand signage. Cool base with committed warm signage punches.
Scene assignments: court exterior, institutional buildings.
Revised 2026-05-11: stripped competing teal `#3a6068`; committed to historic RUCH signage hues — `#e87830` RUCH Orange and `#f0e8d0` Signage Cream as the warm accent system. Added `#2a2c2e` Concrete Shadow.

### Palette C: "Marszałkowska" — the full clash (18 colors)
`art/palettes/marszalkowska_palette.png`
Mood: 1990s Marszałkowska — PKiN gray, tram green, neon kiosk signs, cheap gold signage, mint renovation paint.
Scene assignments: office_street, general daytime outdoor.

Revised 2026-05-11: dropped redundant Straw (#d4b878 collapsed into Mustard/Cheap Gold at thumbnail scale); added Burnt Brick for facade detail. Mustard now means warm building paint; Cheap Gold means signage — keep them distinct in use.

| Hex | Name |
|-----|------|
| `#5a5a60` | PKiN Gray |
| `#e8e4d8` | Parchment |
| `#c8a868` | Mustard (paint) |
| `#e8c840` | Cheap Gold (signage) |
| `#b85e3a` | Burnt Brick |
| `#486880` | Plate Glass |
| `#3a6848` | Tram Green |
| `#7a1f2a` | Oxblood |
| `#d84040` | Neon Red |
| `#88b0a0` | Mint |

### Palette D: "Warsaw Night Life" — neon + wet pavement (18 colors)
`art/palettes/nightlife_palette.png`
Mood: the city after dark — neon reflections, Vistula at night, bar amber.
Scene assignments: nighttime scenes, Chapter 3 basement, Chapter 5 evening protest.
Revised 2026-05-11: replaced duplicate near-blacks with `#1a1c2a` Wet Pavement and `#f0e0a8` Streetlight Glow. **Lemon Yellow `#f0c850` is highlight-only** — reserve for sub-pixel neon highlights and signage glints; do not use as a fill color or it will read cartoon.

### Palette E: "Praga Północ" — the gritty east bank (18 colors)
`art/palettes/praga_palette.png`
Mood: pre-gentrification Praga — rust, crumbling facades, faded murals, courtyard moss.
Scene assignments: archive_room, run-down interiors, investigation scenes.
Revised 2026-05-11: replaced duplicate near-black with `#1f3221` Moss Dark for shadowed courtyard vegetation.

### Palette F: "Łazienki Autumn" — royal park in October (18 colors)
`art/palettes/lazienki_palette.png`
Mood: golden leaves, peacock teal, marble white, park green.
Scene assignments: outdoor park scenes, wistful/reflective beats, Chapter 4 walks.
Revised 2026-05-11: replaced duplicate near-blacks with `#c8b08c` Pale Sandstone (marble-pavilion light) and `#b04830` Maple Red (autumn leaf accent — previously absent despite the autumn-park brief).

### Palette G: "Casebook Dark" — Waliszewska folk-horror (18 colors)
`art/palettes/casebook_dark_palette.png`
Mood: full Waliszewska. Saturated arterial reds against gangrene greens, bone cream against bruise purple, sulfur yellow against cold pond blue. Folk-horror environment register.
Scene assignments: Casebook card backgrounds, chapter transition card environments, Chapter 3 basement, Halina's testimony memory flashbacks.

| Hex | Name |
|-----|------|
| `#2a3a26` | Deep Moss |
| `#3a1e3c` | Bruise |
| `#2a3a4a` | Cold Pond |
| `#6a3a28` | Dried Rust |
| `#b89028` | Sulfur |
| `#b8a890` | Dirty Linen |
| `#e8dcc0` | Bone Cream |
| `#8a1820` | Blood Crimson |
| `#c81e28` | Arterial Red |
| `#4a6038` | Gangrene Green |

Usage discipline: arterial red is for *the* moment in a card, not background fill. Gangrene green is for organic decay surfaces (mold, vegetation in court documents, wallpaper rot). Sulfur reads as warm rot when next to bruise. Pair bone cream + arterial red for the most authentic Waliszewska contrast.

### Palette H: "Court Interior" — institutional grotesque (18 colors)
`art/palettes/court_interior_palette.png`
Mood: bureaucratic dread under sodium-vapor and fluorescent tubes. Drier than Casebook Dark — institutional rather than mythic. The horror of paperwork, oxidized brass railings, and pale-green PRL-era walls.
Scene assignments: court interior rooms, judge chambers, registry archives, deposition rooms.

| Hex | Name |
|-----|------|
| `#3a2818` | Institutional Wood |
| `#4a4848` | Cold Ash |
| `#5a7858` | Fluorescent Pall |
| `#5a1a20` | Dried Oxblood |
| `#3a1e3c` | Bruise |
| `#7a6a3a` | Brass-Oxidized |
| `#c8a040` | Document Ochre |
| `#e8b840` | Sodium-Vapor |
| `#b8a890` | Dirty Linen |
| `#d8d4cc` | Ash White |

Usage discipline: sodium-vapor is the room's "key light" hue — apply to ceiling lamps, document highlights, brass glints; do not use as wall fill. Fluorescent Pall is the wall fill — flat, drained. Pair dried oxblood with bruise for upholstery and judicial robes; pair institutional wood with brass-oxidized for railings and bench fronts.

**Heavy-scene escalation rule:** Casebook Dark is the *symbolic* register (the card depicting an encounter); Court Interior is the *procedural* register (the room where the encounter takes place). A single scene may transition from Court Interior to Casebook Dark when something ruptures (witness breaks down, judge reveals, evidence flips) — treat that palette shift as a beat, not a setting change.

### Era-bridge note: 2019 setting, mixed-era aesthetic

The game is set in 2019, but the aesthetic intentionally splits by location. The Pig & Swine office and the courts read as period-frozen 1990s/2000s — small Polish law firms and public courts in 2019 genuinely look like this (un-renovated chipboard furniture, PRL-green walls). The four palettes below cover the 2019 Warsaw exterior world, where the game leaves the firm.

### Palette I: "Termomodernizacja" — pastel insulated blocks (18 colors)
`art/palettes/termomodernizacja_palette.png`
Mood: the signature 2010s Polish residential look. Candy pastels (mint, salmon, peach, butter yellow, baby blue, lilac) wrapped over communist-era concrete grids. Cheerful styrofoam-paint colors against drained concrete trim and balcony glass tint. One saturated red-door accent.
Scene assignments: residential exteriors, Mokotów/Ursynów blocks, walking-through-Warsaw transitions, suburban housing estates.

| Hex | Name |
|-----|------|
| `#a8a8a8` | Concrete Trim |
| `#7a7a78` | Concrete Shadow |
| `#98a8a8` | Balcony Glass Tint |
| `#b8d4be` | Pale Mint |
| `#b8c8d8` | Baby Blue |
| `#c8b4c8` | Lilac |
| `#e8d894` | Butter Yellow |
| `#e8c4a4` | Peach |
| `#e8a896` | Salmon Pink |
| `#c84838` | Door Red |

Usage discipline: pastels are wall fills; concrete is structural detail (balcony slabs, window frames, ground-floor bands); Door Red is the single saturated accent per facade — never use as a fill, only as one element (a door, a sign, a curtain) per scene.

### Palette J: "Warsaw Mordor" — glass-tower corporate (18 colors)
`art/palettes/warsaw_mordor_palette.png`
Mood: Mokotów Biznesowy (the office district everyone calls "Mordor"). Cobalt-tinted glass facades, chrome, white aluminum, polished concrete, LED-magenta and electric-blue accents for signage, corporate IBM-blue, new-marble cream. The aesthetic antithesis of the firm's stuck-in-time office.
Scene assignments: opposing counsel offices, corporate elevators and lobbies, big-firm meeting rooms, glass-tower cutaways.

| Hex | Name |
|-----|------|
| `#2a3a4a` | Glass Shadow |
| `#1c3a5a` | Corporate IBM Blue |
| `#4a6878` | Cobalt Glass |
| `#6a8898` | Sky Glass |
| `#4070d0` | Electric Blue Accent |
| `#888884` | Polished Concrete |
| `#c8cccc` | Chrome Silver |
| `#e0e0e0` | White Aluminum |
| `#f0ead8` | New Marble |
| `#d040a0` | LED Magenta Accent |

Usage discipline: cobalt glass and sky glass are the facade fills; chrome and white aluminum are structural trim; LED Magenta and Electric Blue are reserved for signage and screen glints, never fill. The point of this palette is *coolness* — never warm the temperature unless a character (warm skin) is in frame.

### Palette K: "Praga Nowa" — gentrified Praga 2019 (18 colors)
`art/palettes/praga_nowa_palette.png`
Mood: third-wave coffee, craft beer, exposed brick, matte-black storefronts, brass details, sage green and dusty pink — third-wave aesthetic layered over remaining Praga rust. Decay reframed as authenticity.
Scene assignments: gentrified Praga bars and coffee shops (Centrum Praskie Koneser, Hala Koneser, Ząbkowska strips), young-creative meeting locations, hipster-investigation scenes.

| Hex | Name |
|-----|------|
| `#2a2826` | Matte Black |
| `#3a2a1c` | Espresso |
| `#888078` | Mushroom Gray |
| `#ecebe8` | Chalk White |
| `#a8543a` | Exposed Brick |
| `#b89868` | Brass |
| `#98a888` | Sage Green |
| `#5a6a4a` | Courtyard Moss |
| `#d8a898` | Dusty Pink |
| `#ff5a5a` | Neon Coral Sign |

Usage discipline: matte black and chalk white are the dominant fills (storefront / interior); exposed brick and espresso provide the rust-and-wood foundation; brass, sage, and dusty pink are restrained accent hits (one per surface, not stacked); Neon Coral Sign is for one signage element only — neon hits the eye like an exclamation point, multiple coral signs cancel each other out.

Praga proper (the original palette E) and Praga Nowa can coexist in adjacent rooms: walk into the gentrified bar and the palette shifts from rust to chalk. Use the transition as visual storytelling.

### Palette L: "Smog Warsaw" — winter atmospheric (18 colors)
`art/palettes/smog_warsaw_palette.png`
Mood: peak Warsaw winter smog. Drained smog-yellow sun through haze, uniform smog-gray wash, sodium-vapor compromised, headlight warm-white piercing the murk, exhaust blue, dirty snow, frozen-breath cream. 2019 was the peak smog-crisis discourse year — this palette is period-coded, not just atmospheric.
Scene assignments: winter exterior scenes, January–February street walks, any scene where the smog itself is a character (a smog-anxiety beat, a "you can't see the buildings" moment).

| Hex | Name |
|-----|------|
| `#2a2624` | Bare Branch |
| `#4a4c4c` | Dark Smog |
| `#4a5868` | Exhaust Blue |
| `#888c8c` | Smog Gray |
| `#b8b4ac` | Dirty Snow |
| `#d8d4d0` | Frozen Breath |
| `#f0e8c8` | Headlight Warm-White |
| `#c8b870` | Smog Sun |
| `#8c704c` | Sodium-Vapor Compromised |
| `#5a8c98` | Smog Cyan Signal |

Usage discipline: this is a *desaturation* palette — everything reads through a haze. Use Smog Gray and Dirty Snow as the dominant fills; Bare Branch and Exhaust Blue as structural darks. Headlight Warm-White and Smog Cyan Signal are the only hues that "pierce" the haze — reserve them for actual light sources (car headlamps, LED screens visible through smog) and never use as fill. Smog Sun is the only sky color in this palette; do not introduce blue sky.

**Palette discipline:** each room draws from one palette. Per-room palette subsets are documented in `art/tilesets/TILESET_BRIEF.md`. Character sprites use only the shared palette-safe colors listed above plus their character-specific accent (e.g., Mustard for Asia's cardigan, Oxblood for Cula's tie).

## Floor system (current architecture)

The project is actively migrating to Godot 4 `TileMap` and `TileSet` resources.
- The canonical master TileSet for the Pig & Swine office is located at `art/tilesets/office_tileset.tres`. It contains the configured marble floor variants and wood panel walls (with 64x64 collision).
- This TileSet is designated for use in `pig_swine_office.tscn`. Future rooms will either share this TileSet or define their own in `art/tilesets/`.

**Room layout — `pig_swine_office.tscn` (rebuilt 2026-05-11, compact plan):**

- Dimensions: 20×11 floor tiles (1280×704 px) inside a wall ring. Fits entirely in the 1280×720 viewport — camera locked, no scrolling.
- **Tile coordinate system:** rows 0–10 / cols 0–19 = floor (pixels x=0..1279, y=0..703). Wall ring sits at row -1 (north), row 11 (south), col -1 (west), col 20 (east). Camera limits set to `(0, 0, 1280, 704)` — effectively locked.
- **Top half (rows 0–4):**
  - **Meeting Room** — cols 0–6. Halina meets the player here. NPC spawns once `chapter1.halina_arrived` flips.
  - **Pig's Office** — cols 7–12. Mr. Pig at his desk; bookshelf, lamp.
  - **Desks / bullpen** — cols 13–17. Murrow + Swine desks.
- **Divider** — row 5 (horizontal wall, doorway gaps).
- **Bottom half (rows 6–10):**
  - **Hall / Entrance** — cols 0–12. Entrance from street at bottom (cols 4–5), couch, printer.
  - **Reception** — cols 13–17. Asia behind desk, fern, cabinets.
  - **Files / Archive** — cols 18–19. Binder pickup, archive-door exit.
  - **Coffee** — cols 18–19, bottom rows. Coffee machine + minigame trigger.
- **Wall topology** (Walls TileMapLayer; collision baked into tiles via `office_tileset.tres` source 1):
  - Exterior ring: north (row -1), south (row 11, gap cols 4-5), west (col -1), east (col 20).
  - Interior horizontal divider at row 5, doorway gaps.
  - Interior vertical divider at col 17–18 area, doorway gaps.
- **Generator** (`_build_office.py`) emits the scene end-to-end. TileMapLayer `tile_map_data` is a base64-encoded `PackedByteArray` with a 2-byte zero prefix followed by 12-byte cells (`(x, y, source_id, atlas_x, atlas_y, alt_tile)` packed as six little-endian int16). The probe script `_probe_tilemap_format.py` decodes the binary back to verify the roundtrip.
- **Legacy backup:** `pig_swine_office.tscn.legacy` preserves the prior scene state.

**Legacy System:** Older scenes may still use `TextureRect` nodes with `stretch_mode = 1` (STRETCH_TILE) and a tiling texture (e.g. `art/tiles/office_tile.png`, 256×256) with manual `CollisionShape2D` walls. These will be phased out.

## TileMap vs Sprite2D placement

**Rule:** Tilemap layers handle floors, wall faces, and any other surface that repeats across many cells. Placed `Sprite2D` nodes handle unique furniture and props.

- **TileMap (Repeating Surfaces):** Floors and walls must be handled by `TileMapLayer` nodes. For example, in `pig_swine_office.tscn`, the `Floor` and `Walls` layers manage the marble tiles and wood wall faces. Walls must use an auto-tiling terrain set, and all wall collision shapes must be baked directly into the wall tiles within the `TileSet` resource (e.g., `office_tileset.tres`). Do not use separate `CollisionShape2D` nodes for wall boundaries.
- **Sprite2D (Unique Props):** Unique items must be placed as individual `Sprite2D` nodes in the scene. In `pig_swine_office.tscn`, elements like desks (`DeskPig`, `DeskSwine`), the `Printer`, `Fern`, filing cabinets, the typewriter save point, doors (`OfficeDoor`), and windows are all individual `Sprite2D` props. Do not use `ColorRect` or generic nodes for prop visuals. These props must adhere to the established `offset.y` Y-sort rules.

## Art direction — two-layer system (Świdziński + Waliszewska)

The game uses two distinct visual registers that create comedy through contrast:

| Layer | Style reference | Resolution | Mood | Tool |
|-------|----------------|-----------|------|------|
| **World sprites** | Jacek Świdziński | 64×64 px | Synthetic, minimal, institutional | Pixellab |
| **Portraits (normal)** | Warm Polish illustration | 512×512 px | Readable, slightly naive, human | AI image gen |
| **Portraits (intense)** | Aleksandra Waliszewska | 512×512 px | Dark symbolism, naive gouache, grotesque | AI image gen |
| **Casebook cards** | Full Waliszewska | 512×512 px | Each judgment = a small symbolic painting | AI image gen |

**The contrast IS the joke.** The world layer is flat and calm — tiny figures in a tiny office. The portrait layer erupts with emotional reality when you press E to talk. Mr. Pig as a 64px blob is a harmless pink circle. Mr. Pig's portrait in panic mode is a Waliszewska painting of a pig-man whose suit is strangling him.

### When to use which portrait register

| Situation | Portrait register |
|-----------|------------------|
| Normal office dialogue | Warm, slightly naive (Butenko-adjacent) |
| Mr. Pig panic states | Waliszewska-dark |
| Court/Judge scenes | Waliszewska-dark (institutional grotesque) |
| Casebook encounters | Waliszewska-dark (legal procedure as folk-horror) |
| Halina's testimony | Waliszewska-dark (memory rendered as dark symbolism) |
| Asia, Murrow, Whimsy normal | Warm register |
| Chapter transition cards | Waliszewska-dark (title cards as symbolic paintings) |

## World sprite generation rules (Pixellab — Świdziński direction)

The Świdziński principle: **if a feature isn't visible at arm's length as a silhouette, remove it from the prompt.** Characters are identified by shape + one attribute. Embrace the crudeness — it's not a limitation, it's the style.

**Generation workflow:**
1. Generate in Pixellab at **124×124** (current default export size — do not resize before importing)
2. Minimal cleanup: fix stray silhouette pixels, snap off-palette colors. 5–10 min per character max.

**Style anchor** (use in every world sprite prompt):
> "Minimal synthetic line drawing, sparse flat shapes, Polish satirical illustration, institutional mood, pixel-art, adult proportions, full body, hands at sides."

**Negative anchor** (use in every world sprite prompt):
> "detailed, shaded, gradient, anime, chibi, cute, big head, decorative, fantasy, realistic, 3D, held objects, facial expressions"

**Rules:**
- **No held objects, no raised-hand gestures.** Pixellab walking animations break with held objects. Attached body props (glasses on face) are fine.
- **Silhouette-first design.** Each character must be identifiable from their outline alone — like chess pieces. Body shape, posture, and one clothing feature.
- **No facial detail.** At 124×124 runtime size, faces are ~10 pixels. Don't waste prompt space on eyes, expressions, or facial hair. Personality lives in the portrait system.
- **Adult proportions.** 1:4 or 1:5 head-to-body ratio. Fight Pixellab's chibi drift explicitly.
- **Brevity rule.** One sentence of distinguishing features + style/negative anchors + palette. Drop everything that won't survive downscaling.
- **Palette discipline.** Each character uses 5–6 colors from the shared palette-safe set (see §Game palettes). Character-specific accents (Mustard for Asia's cardigan, Oxblood for Cula's tie) must come from one of the six game palettes.
- **One Pixellab session per character per generation pass.** Lock seed and prompt; save both in `art/sprites/<char>/PROMPT.txt`.
- **Visual object interaction.** Layer a separate object Sprite2D on top of the character at runtime. Never bake held items into character art.
- **Re-generation must match canon, not match itself.** Compare against the saved canon set; do not let style drift compound across sessions.

## Portrait generation rules (AI image gen — hybrid register)

Portraits are generated at **512×512** using AI image generation (Midjourney, DALL-E, or equivalent). Two registers:

### Warm register (normal dialogue)

**Style anchor:**
> "Small format gouache painting, naive Polish illustration technique, flat warm earth-tone colors, slightly satirical, expressive but grounded, institutional office setting, visible brushstroke texture."

**Negative:**
> "photorealistic, 3D render, anime, digital art, smooth gradients, horror, dark"

Use for: everyday dialogue, introductions, humor beats, Asia/Murrow/Whimsy normal conversation.

### Dark register (Waliszewska-inspired)

**Style anchor:**
> "Small format oil painting, naive primitive technique, Polish dark symbolism, Młoda Polska mood, grotesque folk-art, warm earth tones with sickly accents, slightly unsettling, gouache texture, Balto-Slavic atmosphere."

**Negative:**
> "photorealistic, 3D render, anime, digital art, cute, clean, corporate"

Use for: panic states, court scenes, Casebook encounters, chapter transitions, emotional climaxes.

### Portrait rules:
- **Expression sets.** Each character needs: neutral, speaking, surprised, stressed. Warm-register characters get 4 expressions. Characters with dark-register scenes (Mr. Pig, Judge, Halina) get an additional 2–4 dark-register variants.
- **Consistency within register.** Generate all warm portraits in one session per character; all dark portraits in another. Don't mix sessions.
- **Palette.** Portraits have wider latitude than world sprites but must stay tonally aligned with the active scene palette. Dark-register portraits may introduce off-palette darks and sickly highlights.
- **Store in `art/portraits/<char>/`.** Warm = `neutral.png`, `speaking.png`, etc. Dark = `dark_neutral.png`, `dark_stressed.png`, etc.

## Walk-folder naming convention

Camera-relative naming: `front`, `back`, `left`, `right`, `front_left`, `front_right`, `back_left`, `back_right`. Cula already follows this. Asia currently uses cardinal naming (`north`, `east`, `south`, `west`) — migrate during the regeneration pass.

## Existing scaffold to reuse, not rebuild

- Autoloads: `State`, `Signals`, `Casebook`, `DialogueRunner`.
- Actor scripts: `player.gd`, `npc.gd`, `asia.gd`, `door.gd`, `pickup.gd`, `wall_occluder.gd`, `room_fog.gd`, `behind_desk_zone.gd`, `pig_idle_zone.gd`, `minigame_trigger.gd`.
- System scripts: `room_transition.gd`, `save.gd`, `coffee_brewing.gd`.
- UI scripts: `dialogue_box.gd`, `interaction_prompt.gd`.
- Scenes: `Main`, `pig_swine_office`, `archive_room`, `cafe_paragraf`, `office_street`, `coffee_brewing` (minigame), `dialogue_box`, `interaction_prompt`.

## NPC presence schema

NPC visibility in interior scenes keys off the `State.data.chapter1` flag bag via `presence_flags: Array[String]` + `presence_logic: "any"|"all"` exports on `npc.gd`; re-evaluated on `Signals.chapter1_flag_changed`. Beats are narrative concepts in `narrative_revision/beats/`, **not** runtime state — do not add `current_beat` to `State.data`. Callers that mutate a chapter1 flag must emit `Signals.chapter1_flag_changed(flag_name, new_value)` for the gate to refresh between scene loads.

## Chapter 1 state schema

`State.data.chapter1` carries every flag the chapter-1 dialogue layer reads or writes. `State.data.badges` and `State.data.routes_unlocked` are top-level (not under `chapter1`) so badges and route unlocks can outlive the chapter. Schema added in `SAVE_VERSION = 8` (see `save.gd` migration step v7→v8); the contract is also enumerated in `data/chapters/chapter1.json` `new_state_flags`.

**Flag semantic ownership.** "Owner" means *the system that writes the flag*; everything else only reads. Adding or renaming an owner without an explicit migration step is a schema bug.

- **Phase 7 / sprint 3 baseline** (booleans, default `false`; `court_outcome` is a string, default `""`): `met_pig`, `pig_revealed_crisis`, `met_murrow`, `met_crab`, `met_whimsy`, `has_law_binder`, `has_rights_memo`, `recruited_crab`, `recruited_whimsy`, `coffee_tutorial_seen`, `court_ready`, `entered_court`, `court_outcome`, `met_asia`, `met_asia_via_behind`, `viewed_family_photo`. Owners: respective NPC dialogues (`asia.json`, `cula.json`, etc.), pickup interactions, and the existing court orchestration.
- **Beat 7-8 client meeting.** `halina_met`, `client_fee_agreed`, `bonus_evidence_collected` (string enum: `wojcik_witness_statement` / `return_to_sender_slip` / `lease_1962_inheritance_1987`), `cardiologist_plant_landed` — all owned by `halina.json` `client_meeting_<stance>` `on_dismiss`. `client_meeting_stance` (string enum: `sympathetic` / `blunt_procedural` / `technical`) is owned by the Beat 7 stance-pick UI (Phase B.1, not yet built). `halina_arrived` is owned by the engine's Beat-7-close handler (Phase B.2).
- **Beat 9 archive research.** `archive_research_complete` — flag declared now so V1.A Asia state 8 dispatches; owner is the Beat 9 dialogue (not yet authored).
- **Beat 12 court rounds.** `casebook_judge_state` (string enum: `round_1_open` / `round_1_react` / `round_2_open` / `round_2_react` / `round_3_open` / `round_3_remedy`) is owned by the casebook engine's Beat-12 round orchestration. `court_won_procedural_reset` is owned by `judge_district_ch1.json` `remedy_round_3_<stance>` `on_dismiss`.
- **Beat 13-14 payoff + postcard.** `beat13_complete` is owned by the Beat-13 close handler. `received_swine_postcard` is owned by the Beat-14 postcard arrival trigger. The five progression flags (`postcard_asia_announced`, `postcard_readaloud_cue_shown`, `postcard_body_read`, `pig_postcard_reaction_shown`, `whimsy_postcard_deflection_shown`) and `complete` are owned by `postcard_swine_ch1.json` state `on_dismiss` arrays.
- **Badges.** `State.data.badges.day_one_survivor` — owned by `postcard_swine_ch1.json` `chapter_close` `award_badge` action. The DialogueRunner rejects unknown badge ids; declare a new badge in `State.reset_state().badges` AND the v7→v8 (or later) migration before referencing it from JSON.
- **Routes unlocked.** `State.data.routes_unlocked.{residential, business_district, court_plaza}` — owned by `postcard_swine_ch1.json` `chapter_close` `unlock_route` actions. Same declaration contract as badges.

**Dialogue trigger syntax supported by `DialogueRunner._evaluate_clause`:**

- `path == value` / `path != value` (string comparison after lowercasing; quoted RHS strings work).
- `path` (bare) — passes when the resolved value is truthy.
- `!path` — passes when the resolved value is falsy or missing.
- Clauses combined with `&&` (logical AND). `||` is **not** supported and will warn; current usage in `judge_district_ch1.json` `open_round` predates this rule and will need either an engine extension or per-round trigger duplication when Phase C wires court rounds.

**Dialogue option schema (in-box choice picker).**

A dialogue state may carry an `options` block alongside its `lines`. The dialogue box renders the choice list under the prompt's last line; the player navigates with `move_up`/`move_down` and commits with `interact`. The selected option renders in red (per `dialogue_box.gd` `OPTION_COLOR_SELECTED`).

```json
{
    "id": "stance_pick",
    "trigger": "...",
    "lines": ["How would you like to open with Mrs. Sikorska?"],
    "options": {
        "write_path": "chapter1.client_meeting_stance",
        "choices": [
            { "text": "Lead with how she's holding up.", "value": "sympathetic" },
            { "text": "Lead with the timeline.",          "value": "blunt_procedural" },
            { "text": "Lead with the lease history.",     "value": "technical" }
        ]
    },
    "on_dismiss": [
        /* optional — set actions, award_badge, unlock_route still run on commit */
    ]
}
```

Mechanics. On state match, `DialogueRunner` emits `dialogue_line_ready` (the prompt) then `dialogue_options_ready(write_path, choices)`. `DialogueBox` stashes the choices and renders the option list when the player reaches the last prompt line. On `interact`, the box emits `Signals.dialogue_option_committed(value)`; the runner writes the value to State at `write_path`, emits `chapter1_flag_changed` if the path is under `chapter1.`, runs the matched state's `on_dismiss` block, and clears its mutation queue (so the subsequent `dialogue_dismissed` is a no-op). Player gets one pick per state; option states are dead-ended (no advance-past behaviour). The standalone modal `client_stance_menu.tscn` is retired in favour of this flow.

## Chapter 1 meeting-room sub-area

The Beat 8 client meeting takes place inside `pig_swine_office.tscn` in the `MeetingFloor` zone (top-right quadrant: x 768–1536, y 0–400). Three nodes implement the gate:

`Halina` (`Area2D` + `npc.gd`) — positioned at (1152, 200), inside the meeting-room area. `presence_flags = ["halina_arrived"]` with `presence_logic = "all"` hides her until Beat 7's Asia-announcement on_dismiss flips `chapter1.halina_arrived`. She remains visible after `halina_met = true`; post-meeting dismissal is a Beat 9 concern (out of scope for Phase B).

`MeetingRoomBoundary` (`StaticBody2D`) — a 768×16 wall along the south edge of `MeetingFloor` (y = 392). Blocks the player from crossing into the meeting area until `client_meeting_stance != ""`. `meeting_room_trigger.gd` disables its `CollisionShape2D` on stance commit and on scene-load if a stance is already persisted (save/load mid-meeting).

`MeetingRoomEntryTrigger` (`Area2D` + `meeting_room_trigger.gd`) — a 768×40 sensor strip just south of the boundary (y = 360). On `body_entered`, evaluates the gating: if preconditions met and stance unset, spawns `client_stance_menu.tscn`; if stance set and meeting unheld, emits `Signals.dialogue_requested("halina", "Mrs. Sikorska")` (DialogueRunner picks the correct `client_meeting_<stance>` branch). Post-`halina_met`, the trigger is a no-op.

## Asia Beat 7-close announcement (Option A)

The "Mrs. Sikorska is here..." cue is implemented as a new V1.A state (`hint_halina_arrived_announcement`) in `asia_hint_states_ch1.json`, priority-ordered ahead of `hint_halina_met`. The on_dismiss flips `chapter1.halina_arrived` true, which simultaneously (a) reveals the Halina NPC node via `presence_flags` and (b) routes the next Asia interaction to `hint_halina_met`. **Rationale for Option A over a custom `asia.gd` hook:** the V1.A hint surface already owns Asia's repeatable progression-cue dispatch; adding the announcement there means one place to read, one place to debug, no parallel announcement system. The player still has to actively interact with Asia to trigger it (not a push-notification), which matches the existing Beat 1–6 progression-cue ergonomics.

## Current divergences (resolve in follow-up prompts)

**Character sprite size.** Canonical = 64×64 (changed from 112×112 per 2026-05-11 playtest feedback). Reality:
- All existing sprites are still 112×112 — pending Pixellab regeneration at 64×64.
- Cula: `walk/_alt/back_left_v2/` contains 92×92 sprites (legacy).
- `scripts/ui/interaction_prompt.gd` comment updated to reflect 64×64.

**Room sizing (against 1280×720 viewport).**
- `pig_swine_office.tscn`: Rebuilt to 20×11 TileMap (1280×704 px) — fits entirely in viewport, no scrolling (2026-05-11 playtest feedback).
- `cafe_paragraf.tscn`: Floor offsets hardcoded at 640×480. Significantly undersized.
- `archive_room.tscn`: Floor offsets hardcoded at 640×480. Significantly undersized.
- `office_street.tscn`: Floor offsets hardcoded at 960×640. Extend to ≥ 1280×720.

**Naming convention drift.**
- Asia walks: redundant cardinal/ordinal folders (`north`, `south-west`, etc.) exist alongside the new camera-relative folders. Delete old redundant folders.

**TileMap vs Sprite2D placement violations (`pig_swine_office.tscn`).**
- **Wall Collisions:** Resolved 2026-05-12. The four perimeter `StaticBody2D` nodes (`LeftWall`, `RightWall`, `BottomWallLeft`, `BottomWallRight`) are gone. All wall collision is baked into wall tiles via `office_tileset.tres` source 1 (`physics_layer_0/polygon_0/points`). Wall tiles are painted on the exterior ring (row -1, row 16, col -1, col 24) and on interior dividers (row 6 horizontal, col 19 vertical) by `_build_office.py`.
- **Prop Construction:** `FileCabinet` and `ProceduralBinder` visuals remain `ColorRect` placeholders pending art. `Couch` placeholder (`Couch_TODO_placeholder`, `ColorRect` on the north edge of Hall, cols 1-2) added 2026-05-12 — pending `couch.png` asset.
- **Architectural Conflicts:** `wall_occluder.gd` and the stale `test_office_wall_visibility.gd` test (expects `WallOccluder` and 960×640 camera limits) are incompatible with the two-row TileMapLayer wall topology. Leave both untouched until they're either deleted or rewritten against the new wall structure — `test_office_wall_visibility.gd` is not in the green-test list.

## Open architectural decisions

- **TileMap migration**: continue with TextureRect+CollisionShape2D, or migrate to Godot 4 TileMap nodes? Affects walls, collision authoring, and whether `office_tile.png` should become a proper tileset atlas.
- **Asset pipeline for tilesets**: if migrating to TileMap, decide Pixellab vs Kenney vs custom for tile art. Per-room wall styles already briefed in `art/tilesets/WALLS_BRIEF.md` (Prompt 7 output) once that runs.
