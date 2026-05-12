# Antigravity prompts — map & UI implementation pass

Each prompt is self-contained and copy-pasteable into Antigravity. Prompts are listed in execution order — run them top to bottom. Each declares a recommended model, required reading, allowed writes, forbidden scope, and acceptance criteria.

**Current project state (2026-05-11):**
- Viewport 1280×720 (16:9), 64-px logical tile grid, character sprites at 112×112 (Pixellab Polish komiks set).
- Cula has `cula_sprite_frames.tres`; Asia has `asia_sprite_frames.tres`. Other NPCs have idles only (or partial walks — Murrow has south-only).
- Floor system: hybrid in transition. Some rooms still use TextureRect tile-stretch; the office is being rebuilt as a Godot TileMap (Prompts 8 + 9 below).
- TileMap migration is COMMITTED.
- Tile-preparation workflow: Pixellab generates tile candidates → Aseprite indexed-mode palette conversion (6 colors max) → resulting PNG drops into Godot TileSet.

Models referenced:

- **Gemini 3 Pro** — large context, strong reasoning. Use for cross-file audits, multi-asset coordination, anything that needs to hold the whole project in head.
- **Claude Sonnet 4.6** — precise, surgical edits. Use for scene-tree changes, refactors with clear contracts, test writing.
- **Claude Opus 4.6** — heaviest reasoning, slower. Reserve for risky/ambiguous changes touching state machines or story logic.
- **Gemini 2.5 Flash** — cheap one-shot. Use for file shuffling, scaffolding, stub generation.

If a model isn't available in your Antigravity workspace, fall back upward (Sonnet → Opus, Flash → Sonnet, Gemini 3 Pro → Opus).

---

## 1. Foundation audit — viewport, tile, sprite dimensions

**Status: ran once before sprite-size churn stabilized. Optional re-run to refresh `CONVENTIONS.md` against current state.**

**Model: Gemini 3 Pro**

**Goal.** Audit the entire Godot project for adherence to the canonical numbers — 1280×720 viewport (16:9), 64×64 logical tile grid, 112×112 character sprites — and produce a written delta. The three constants are already exported from `State`; verify they match the audit results.

**Required reading.**
- `godot/project.godot`
- Every `.tscn` under `godot/scenes/`
- Every `.gd` under `godot/scripts/`
- Every directory under `godot/art/sprites/` (filenames + image dimensions only — no opening images)
- `godot/art/props/` filenames + dimensions
- `godot/CONVENTIONS.md` (existing)

**Allowed writes.**
- `godot/CONVENTIONS.md` — refresh the "Current divergences" section against current state.
- `godot/scripts/autoload/state.gd` — only if the three constants are wrong (currently `TILE_SIZE := 64`, `CHAR_HEIGHT := 112`, `VIEWPORT_SIZE := Vector2i(1280, 720)`).

**Forbidden.**
- Changing any pixel dimension, sprite, scene layout, or game logic.
- Touching art assets.
- Modifying tests.

**Acceptance.**
- `CONVENTIONS.md` divergences section reflects 2026-05-11 reality.
- The three constants in `State` match the canonical numbers.
- `godot --check-only` passes.
- Existing tests still pass.

**Output artifact.** A diff and the refreshed `CONVENTIONS.md`.

---

## 2. Y-sort + feet-origin canon

**Model: Claude Sonnet 4.6**

**Goal.** Every interior room root has `y_sort_enabled = true`. Every character `Sprite2D` and every tall prop has `offset.y` set so the node origin sits at the figure's feet. Add a regression test that drops the player at five Y positions next to five tall props in `pig_swine_office` and screenshots, asserting visible-pixel order matches Y order.

**Compute offset from feet position, not canvas center.** Pixellab sprites have transparent padding around the figure — a 112×112 canvas might have the actual character occupying only ~80px with feet at row ~100. Using `offset.y = -texture_height / 2` would place the origin at canvas center, which is the figure's chest, breaking Y-sort.

For each character sprite, scan the alpha channel to find the bottom-most non-transparent row (`feet_y`), and set `offset.y = -feet_y`. This puts the node origin exactly at the figure's feet, regardless of padding or future sprite size changes. Use the idle-south PNG as the reference (Pixellab keeps feet consistent across the 8 directions, so one scan per character suffices).

For tall props (desks, bookshelves, fern, etc.), do the same alpha-scan to find the bottom of the prop graphic.

**Required reading.**
- Every `.tscn` under `godot/scenes/interiors/` and `godot/scenes/world/`
- `godot/scripts/actors/player.gd`, `npc.gd`, `behind_desk_zone.gd`
- `godot/tests/test_office_wall_visibility.gd` and `godot/tests/test_visual_capture.gd` for test conventions
- `godot/CONVENTIONS.md`

**Allowed writes.**
- Interior `.tscn` files — Y-sort flag and Sprite2D offsets only.
- `godot/tests/test_ysort_canon.gd` (new).
- A single new section in `godot/CONVENTIONS.md` documenting the rule.

**Forbidden.**
- Collision shapes, art assets, dialogue, navigation.
- Z-index changes — Y-sort only.
- Sprite scaling.

**Acceptance.**
- Every interior root has `y_sort_enabled = true`.
- Every character Sprite2D has `offset.y` set such that node origin = figure's feet, computed by scanning the sprite's alpha channel to find the bottom-most opaque row (NOT computed from texture height).
- New test passes; all existing tests still pass.

**Output artifact.** Diff of scene files + the new test + the conventions update.

---

## 3. Camera2D bounds standard + reusable RoomCamera component

**Model: Claude Sonnet 4.6**

**Goal.** Each interior scene uses a `Camera2D` with `position_smoothing_enabled = true` and `limit_left/right/top/bottom` set to room bounds. Extract a reusable `RoomCamera.tscn` component that auto-detects its parent room's bounds on `_ready()`. The component should handle both layouts:
- TileMap-based rooms (use `TileMap.get_used_rect()` × `tile_size`).
- Legacy TextureRect-floor rooms (use `Floor.offset_right` / `Floor.offset_bottom`).

The component picks the right method automatically by looking for a TileMap child first, falling back to a Floor TextureRect.

**Required reading.**
- Every `.tscn` under `godot/scenes/interiors/`
- `godot/scripts/systems/room_transition.gd`
- `godot/CONVENTIONS.md`

**Allowed writes.**
- `godot/scenes/components/room_camera.tscn` (new)
- `godot/scripts/components/room_camera.gd` (new)
- Each interior `.tscn` — replace existing camera with the component.

**Forbidden.**
- Zoom changes, post-process, screenshake, camera logic during cutscenes.
- Modifying `room_transition.gd`.

**Acceptance.**
- Walking to any room edge stops the camera at the room bound (whichever layout the room uses).
- Small rooms lock the camera; large rooms scroll.
- New test `test_room_camera_bounds.gd` verifies camera limits match the room bounds for every interior.
- Existing room-transition test still passes.

**Output artifact.** New component + scene diffs + new test.

---

## 4. Player movement — 8-way free, diagonal-normalised, sprint at 1.6×

**Model: Claude Sonnet 4.6**

**Goal.** Player CharacterBody2D walks at 96 px/s (1.5 tiles/sec on the 64-px logical grid), sprints at exactly 1.6× (153.6 px/s) using the existing `sprint` action. Diagonal input is normalised so W+D yields the same speed as W. Animation direction is selected from `velocity.angle()` discretised into 8 buckets of 45°, with bucket centers at the eight cardinal/diagonal directions. Idle animation uses the last non-zero direction.

**Required reading.**
- `godot/scripts/actors/player.gd`
- `godot/scripts/actors/asia.gd`
- `godot/tests/test_player_animation.gd`, `test_player_sprint.gd`, `test_input_check.gd`
- `godot/CONVENTIONS.md`

**Allowed writes.**
- `godot/scripts/actors/player.gd`
- `godot/tests/test_player_diagonal_normalised.gd` (new)

**Forbidden.**
- Modifying input map (already W/A/S/D + arrows + E + Shift in `project.godot`).
- Adding new input actions.
- Touching NPC movement.
- Changing animation frame data.

**Acceptance.**
- Holding W+D produces speed equal to W alone (within float tolerance).
- Sprint multiplier is exactly 1.6×.
- Animation switches direction within 22.5° of bucket center.
- All three existing player tests pass.
- New diagonal-normalisation test passes.

**Output artifact.** Diff of `player.gd` + new test.

---

## 5. Pixellab canon — PROMPT.txt convention + README

**Model: Gemini 2.5 Flash**

**Goal.** Most of this is retroactively done — every character folder under `godot/art/sprites/` has a compressed `PROMPT.txt` with Pixellab Character ID, template, view, size, and the canonical Polish komiks anchor. The remaining deliverable is `godot/art/sprites/README.md` describing the regen protocol and the canon rules so future Pixellab sessions don't re-introduce the problems we've already fixed.

**Required reading.**
- All 8 character folders under `godot/art/sprites/`
- A sample of 3-4 `PROMPT.txt` files to understand the format
- `godot/CONVENTIONS.md` § Sprite generation rules

**Allowed writes.**
- `godot/art/sprites/README.md` (new)
- Tweaks to individual `PROMPT.txt` files only if they're inconsistent with the canon — flag, don't rewrite.

**Forbidden.**
- Generating, modifying, or deleting any image.
- Adding any new character folder.
- Touching scene files or scripts.

**Acceptance.** `README.md` describes:
- One Pixellab session per character per generation pass; lock seed; save Pixellab Character ID in `PROMPT.txt`.
- All directions and frames of one character generated together.
- Re-generations must visually match canon, not match each other across sessions.
- HARD RULE: no held objects, no raised-hand gestures, no facial expression descriptors, no caricature. Pixellab walking/running animations break with held things or stuck poses.
- Style anchor (canonical, copy verbatim into every prompt): "Polish komiks illustration, clean ink-line outlines, flat warm earth-tone colors, PRL-era mood, pixel-art, full body, hands at sides."
- Negative anchor (canonical, copy verbatim): "held objects, facial expressions, caricature, gradients, anime."
- Character-specific negatives added only where needed (e.g. "raised hands" for Whimsy; "four-legged pig, human in pig mask" for Mr Pig and Mr Swine).
- Each prompt is ONE sentence of distinguishing features + the shared anchors + palette (5–6 hex codes drawn from the cast palette).
- Pixellab tends to ignore size in prompt text; set size in the Pixellab UI directly. Current canon is 112×112.

**Output artifact.** The new README.

---

## 6. NPC AnimatedSprite2D wiring — 8-dir idle, 4-cardinal walk

**Model: Gemini 3 Pro**

**Goal.** Wire each NPC's AnimatedSprite2D against the 112×112 sprite set. NPCs use 8-dir idle but 4-cardinal walk; Cula keeps 8-dir walk (already wired via `cula_sprite_frames.tres`). Diagonal-walk states map at runtime to the nearest cardinal walk animation. Generate a `<char>_sprite_frames.tres` for each NPC that has its sprites in place, modeled on `cula_sprite_frames.tres`. Build an `AnimatedSprite2D` setup template (`npc_walking_canon.tscn`) that any NPC scene can inherit.

Walks are currently incomplete for most NPCs: Asia has full walks; Murrow has south-only; Whimsy / Crab / Mr Pig / Mr Swine / Halina have idles only. Generate the .tres files with whatever animations are available; missing-direction animations fall back to idle.

**Required reading.**
- Every directory under `godot/art/sprites/`
- `godot/art/sprites/cula/cula_sprite_frames.tres` (template — copy structure)
- `godot/art/sprites/asia/asia_sprite_frames.tres` (existing NPC example)
- `godot/scripts/actors/npc.gd`, `asia.gd`, `pig_idle_zone.gd`
- `godot/scripts/actors/player.gd` (Cula's 8-dir walk wiring)
- `godot/tests/test_npc.gd`, `test_player_animation.gd`, `test_sprite_frames.gd`

**Allowed writes.**
- `godot/scenes/components/npc_walking_canon.tscn` (new)
- `godot/scripts/actors/npc.gd` — update animation logic only.
- `godot/art/sprites/<char>/<char>_sprite_frames.tres` (new — one per NPC).
- Per-NPC scenes — wire AnimatedSprite2D to use the canon template.
- `godot/tests/test_npc_animation_canon.gd` (new)

**Forbidden.**
- Regenerating any sprite or modifying any image.
- Touching `cula_sprite_frames.tres` or `asia_sprite_frames.tres`.
- Adding new characters or removing characters.

**Acceptance.**
- Every NPC scene loads with no missing-frame warnings.
- Idle in any of the 8 directions plays the matching 8-dir idle frame.
- Walking direction maps to the nearest available cardinal walk (or idle, if no walks for that NPC).
- All existing NPC and sprite tests still pass; new test enumerates each NPC × each direction.

**Output artifact.** New template + script diffs + per-NPC `.tres` files + per-scene diffs + new test.

**Re-run note.** This prompt is expected to be re-run multiple times as the NPC sprite set fills in. The canonical NPC animation schema is:
- 8-dir idle (already have for everyone)
- 4-cardinal walk (Asia complete; Murrow south-only; others pending)
- 4-cardinal run (none generated yet — open decision whether NPCs even get runs, currently only Cula has them)

Each future Pixellab pass that adds new directions or new animation states triggers a re-run. The agent should generate the `.tres` with whatever frames exist on disk at the time, and gracefully fall back (walk → idle, run → walk → idle) for missing animations.

---

## 7. Tile-style brief — marble floor and wood-paneling walls

**Model: Gemini 3 Pro**

**Goal.** Produce a written brief, NOT the implementation, for the office tileset and (subsequent) tilesets per room. The first office tileset is already partly generated (cream marble floor, 6-color Aseprite-normalized — see `godot/art/tiles/marble_floor/`). This prompt formalizes the brief for the remaining room styles so future Pixellab sessions are guided.

Output `godot/art/tilesets/TILESET_BRIEF.md` with one section per room type (`pig_swine_office`, `archive_room`, `cafe_paragraf`, `office_street`). Each section gives:

- Floor description (material, color register, wear level).
- Wall description (material, color register, 3/4-perspective convention — wall face visible plus thin top edge).
- 5–6-color hex palette drawn from the cast palette.
- 2–3 mood adjectives from the design bible.
- Pixellab prompt(s) — separate one for floor, one for wall face.
- Post-processing notes: indexed-mode conversion in Aseprite to N colors (currently 6 for office floor) to unify color drift; pick best 3-5 variants from each generation batch.
- Tile dimensions: source 32×32 or 64×64 (specify per tileset; office uses 64×64 native).

**Office tileset values to record (already decided):**
- Floor: cream marble with subtle gray veining, slightly worn. Palette: #e8e4d8, #d4b878, #9a9088, #1a1410 + 1-2 accents. Source: 64×64.
- Wall: warm honey wood paneling, vertical planks, dark trim at top, 3/4 perspective. Palette: #c8a868, #d4b878, #6a4a30, #1a1410, #e8e4d8. Source: 64×64.

**Required reading.**
- `_legacy/design/design_bible.md` § room moods
- `godot/CONVENTIONS.md` § Sprite generation rules (style anchor — reuse the Polish komiks anchor for tiles too, but stripped: drop "full body" and "hands at sides")
- `godot/art/tiles/` (anything already generated)

**Allowed writes.**
- `godot/art/tilesets/TILESET_BRIEF.md` (new)

**Forbidden.**
- Generating any image.
- Modifying any existing sprite, scene, or script.

**Acceptance.**
- Brief covers all 4 room types.
- Each section has floor + wall description, palette, mood, Pixellab prompts, post-processing notes.
- Distinctness check: no two rooms share more than 2 palette colors. Office (warm cream/wood) vs Archive (cool stone/dust) vs Cafe (warm wood/brick) vs Street (cool brick/concrete).

**Output artifact.** The brief.

---

## 8. Author the Godot TileSet from Aseprite-prepared tiles

**Model: Claude Sonnet 4.6**

**Manual prep status (2026-05-11): tiles exist on disk.**
- Floor: `godot/art/tiles/office_marble_tiles.png` — cream marble, 6-color Aseprite-normalized. Contains multiple variants (~25) of the same marble pattern; treat each as a usable floor tile.
- Wall: `godot/art/tiles/office_wall.png` — warm honey wood paneling, vertical planks, dark trim at top, 3/4 wall-face perspective. **Horizontal STRIP of multiple wall tiles, structured as:**
  - Leftmost slice = left-edge wall piece (used at the leftmost cell of any wall row)
  - Rightmost slice = right-edge wall piece (used at the rightmost cell of any wall row)
  - Middle slices = repeating wall body (used for cells in between)

The TileSet must slice both sheets correctly and tag the wall tiles by role (left-edge / middle / right-edge) so Prompt 9's painting logic can pick the right tile per cell.

**Goal.** Build a Godot `TileSet` resource for the Pig & Swine office from the prepared tile PNGs (marble floor, wood walls). Configure source images, tile slicing, collision shapes for walls, and terrain sets for auto-tiling.

The TileSet resource is the bridge between the art (PNGs the user prepared in Aseprite) and the in-game TileMap. Once this exists, painting a room is trivial.

**Required reading.**
- `godot/art/tiles/` (whatever floor/wall PNGs exist by the time this runs)
- `godot/CONVENTIONS.md` § Floor system, § Sprite generation rules
- A Godot 4 TileSet authoring reference (the agent should know this; if uncertain, web-search Godot 4 TileSet documentation)

**Allowed writes.**
- `godot/art/tilesets/office_tileset.tres` (new) — the TileSet resource.
- `godot/art/tilesets/README.md` (new, optional) — documenting which source PNG maps to which tile category.

**Forbidden.**
- Generating or editing any PNG art.
- Modifying existing scenes (TileSet is referenced but not instantiated in this prompt).
- Adding tiles for rooms other than the office.

**Acceptance.**
- `office_tileset.tres` loads without errors.
- TileSet contains at least: a floor terrain (marble tile + any prepared variants) and a wall terrain (wood paneling with corner/edge auto-tile if user prepared corner pieces; else single wall tile flagged as such).
- Wall tiles have collision shapes attached (rectangular collision the size of the tile).
- Floor tiles have no collision.
- The TileSet's `tile_size` matches the source PNG dimensions (64×64 if user prepared 64-source tiles; 32×32 if user prepared 32-source tiles).
- A note in `CONVENTIONS.md` references where the TileSet lives and which rooms use it.

**Output artifact.** The new TileSet resource + optional README + conventions note.

**Re-run note.** If/when wall corner pieces and edge variants are added later, re-run to update auto-tile terrain set.

---

## 9. Rebuild pig_swine_office.tscn as a TileMap room

**Model: Claude Sonnet 4.6** (downgraded from Gemini 3 Pro — Gemini was too creative with tile placement; Sonnet's literalness handles spatial grid work better)

**Goal.** Build a new `pig_swine_office.tscn` from scratch using the `office_tileset.tres` (Prompt 8). The room is a TileMap-based interior with placed sprite props (desks, printer, fern, etc.) on top. Preserve the conceptual zones from the existing scene's `FloorZones` (hall, meeting room, partner offices, bullpen) but rebuild geometry against the 1280×720 viewport with room to scroll.

Target dimensions: 24×16 tiles minimum (1536×1024 px at 64-px tile size). Adjust as needed for the cast roster (6 lawyer desks + Asia's reception + Pig and Swine partner offices + meeting room + printer corner).

**TILE-PAINTING CONTRACT (load-bearing — previous run failed by violating these):**

- **DO NOT PRESERVE EXISTING tile_data.** If the existing `pig_swine_office.tscn` has a `tile_data` field on its TileMap node, IGNORE it entirely. Discard it. The existing tile_data is the broken sparse-painting state from a prior failed run; preserving it preserves the failure. The phrase "rebuild from scratch" means painting every floor cell freshly via `tilemap.set_cell()` calls (or generating fresh `tile_data` PackedInt32Array bytes), NOT copying the old `tile_data` and editing prop nodes around it. If you find yourself extracting tile_data from the legacy scene "to preserve it," STOP — that's the failure mode this contract exists to prevent.

- **Floor fill rule.** Every cell inside the room's floor rectangle gets a marble tile. NO empty cells. If the marble source has multiple variants (e.g., 25 variants from the Aseprite-prepared sheet), distribute them randomly across cells using a deterministic seed — every cell gets ONE marble tile, no gaps. The "scattered patches with grey gaps" pattern from the previous run is the failure mode to avoid: that's `set_cell()` called on some cells but not all. Iterate over EVERY (x, y) in the floor rectangle and assign a marble tile.

- **Wall tile sheet structure.** The wall tile source (`office_wall.png`) is a horizontal strip of tiles, NOT a single seamless tile. The structure is:
  - **Leftmost tile** = left-edge wall piece (the end-cap when a wall row starts on the left)
  - **Rightmost tile** = right-edge wall piece (the end-cap when a wall row ends on the right)
  - **Middle tiles** = repeating wall body (use any of them for the cells between the end-caps)

- **Wall painting rule — TOP WALL ONLY.** Paint a SINGLE ROW of wall tiles across the TOP edge of the floor rectangle. Do NOT paint walls on the bottom, left, or right sides — Pokemon-Yellow convention is that only the top wall is visible (the wall the player walks toward); the other edges fade off-screen or are bounded invisibly. For the top wall row:
  - Place the **leftmost-source** wall tile at the leftmost cell of the top row.
  - Place the **rightmost-source** wall tile at the rightmost cell of the top row.
  - Fill cells in between with **middle** wall tiles.
  - The top wall row occupies the row immediately above the floor's top edge — i.e., if the floor rectangle is rows 1–15, the top wall is row 0.

- **Invisible collision boundaries.** Since only the top wall is visually painted, the bottom, left, and right floor edges need invisible collision to prevent the player from walking off. Add three `StaticBody2D` nodes with `CollisionShape2D` children — one at the left edge, one at the right edge, one at the bottom edge of the floor — each forming a thin invisible wall the height/width of the floor side. The bottom collision has a gap at the door location.

- **Door cutout.** The south edge (bottom of the room) has a door opening leading to `office_street`. The bottom collision wall has a gap at the door location (2 tiles wide, centered horizontally — adjust to match existing door sprite). Place the existing `office_door.png` sprite there as a Sprite2D + Area2D trigger pointing at the `room_transition` system.

Preserve all interactive elements: doors with room_transition triggers, NPC spawn points, behind_desk_zone for the y-sort hide trick, pig_idle_zone, minigame_trigger (coffee machine), interaction prompts on furniture.

**Required reading.**
- `godot/scenes/interiors/pig_swine_office.tscn` (OLD — for zone layout reference)
- `godot/art/tilesets/office_tileset.tres` (from Prompt 8)
- `godot/art/props/office/` (all furniture PNGs)
- `godot/scripts/actors/door.gd`, `pickup.gd`, `behind_desk_zone.gd`, `pig_idle_zone.gd`, `minigame_trigger.gd`, `wall_occluder.gd`, `room_fog.gd`
- `godot/scripts/systems/room_transition.gd`
- `godot/scenes/world/routes/office_street.tscn` (for the door pairing)
- `godot/CONVENTIONS.md` § canonical numbers

**Allowed writes.**
- `godot/scenes/interiors/pig_swine_office.tscn` — **rebuild from scratch**.
- The OLD scene file is archived: rename to `pig_swine_office.tscn.legacy` first as backup; do NOT delete.
- `godot/CONVENTIONS.md` — short room-layout note.

**Forbidden.**
- Touching any other room scene.
- Modifying art assets, scripts, or autoloads.
- Changing the door/transition destination (still goes to `office_street`).

**Acceptance.**
- New scene loads in Godot without errors.
- **Floor: every cell inside the floor rectangle has a marble tile. Zero empty/grey cells.** Verify by counting filled cells vs floor area — must equal `width × height`.
- **Walls: TOP WALL ONLY**, single row, using leftmost-source for the leftmost cell, rightmost-source for the rightmost cell, middle tiles between. No bottom wall, no side walls.
- Bottom / left / right floor edges have invisible `StaticBody2D` collision walls preventing the player from walking off-floor.
- Bottom collision has a gap at the door location; the `office_door.png` sprite sits there as an Area2D transition trigger to `office_street`.
- Top wall tiles carry their own collision automatically (from the TileSet's wall tile collision shapes).
- All canonical furniture (6 lawyer desks + reception + 2 partner offices + meeting table + printer + coffee machine + bookshelf + fern + filing cabinets + clock + calendar + window) placed as Sprite2D children of the room with Y-sort enabled and correct origin offsets.
- All canonical triggers (door to office_street, behind_desk_zone for Asia, pig_idle_zone, coffee minigame trigger) present and wired.
- Camera bounds set via the RoomCamera component from Prompt 3.
- Visual smoke test (Prompt 12) renders the room without missing-texture errors.
- The legacy `.tscn.legacy` exists as a backup.

**Output artifact.** New scene file + legacy backup + brief layout note in CONVENTIONS.md.

---

## 10. TileMap discipline — what is a tile, what is a placed sprite

**Model: Claude Sonnet 4.6**

**Goal.** Document and enforce the rule for migrated TileMap-based rooms: **tilemap layers handle floors, wall faces, and any other surface that repeats across many cells**; **placed Sprite2D nodes handle unique furniture and props** (desks, printer, fern, filing cabinets, the typewriter save point, doors, windows). Walls have their own tilemap layer with auto-tiling terrain set; collision shapes are baked into wall tiles (not separate CollisionShape2D nodes).

Audit the new `pig_swine_office.tscn` (built in Prompt 9) against this rule and write the convention.

**Required reading.**
- `godot/scenes/interiors/pig_swine_office.tscn` (new TileMap version, from Prompt 9)
- `godot/scripts/actors/wall_occluder.gd`, `room_fog.gd`, `behind_desk_zone.gd`
- `godot/CONVENTIONS.md`

**Allowed writes.**
- `godot/CONVENTIONS.md` — new section "TileMap vs Sprite2D placement".
- Flag (do not fix) any rule violations in `pig_swine_office.tscn` — surface as a follow-up task.

**Forbidden.**
- Refactoring scenes in this pass.
- Touching any art assets.

**Acceptance.**
- CONVENTIONS section documents the rule with concrete examples from `pig_swine_office`.
- Violations are listed but not fixed.

**Output artifact.** Conventions update + violations list (if any).

---

## 11. Flag-keyed NPC presence in the office

**Model: Claude Opus 4.6**

**Goal.** NPC presence in `pig_swine_office` keys off the existing `State.data.chapter1` flag bag — NOT a new beat enum. Add a `presence_flags: Array[String]` export on `npc.gd` that lists chapter1 flag keys this NPC's visibility depends on, plus an optional `presence_logic: String` (default `"any"`) that lets a scene declare whether the NPC appears when ANY listed flag is true or when ALL are true. NPC visibility is set on `_ready()` and re-evaluated when a new signal `Signals.chapter1_flag_changed` fires (add the signal — that's NOT a schema rewrite, just an event channel).

**Scope discipline (load-bearing):**
- DO NOT add `current_beat` or any new field to `State.data`. The chapter1 flag bag is canon.
- DO NOT invent a beat enum. Beats exist in narrative docs (`narrative_revision/beats/`, V1.x packs) as story-content references, NOT as runtime state. Mapping beats → flag combinations is fine in dialogue tree code, not as a State field.
- Asia is exempt from this system — she's the constant receptionist, present from chapter 1 start. Her `asia.gd` does not need `presence_flags`.
- Halina has no node in `pig_swine_office.tscn` yet. Adding her is a SEPARATE prompt (future task), not part of this one. Skip her in the backfill.

**Required reading.**
- `_legacy/design/chapters/1.md` (canonical chapter 1 outline — read for flag-to-moment mapping, not to invent a beat enum)
- `_legacy/design/design_bible.md` § 3 (character roster, presence rationale)
- `narrative_revision/beats/chapter_1.md` (reference for what the flags MEAN narratively)
- `godot/scripts/actors/npc.gd`, `asia.gd`, `pig_idle_zone.gd`
- `godot/scripts/autoload/state.gd` (chapter1 flag definitions)
- `godot/scripts/autoload/signals.gd` (add the new signal here)
- `godot/scripts/autoload/casebook.gd`, `dialogue_runner.gd` (for context only — don't modify)
- `godot/scenes/interiors/pig_swine_office.tscn`
- `godot/tests/test_asia_progression.gd`, `test_npc.gd`

**Allowed writes.**
- `godot/scripts/actors/npc.gd` — add `presence_flags: Array[String]` + `presence_logic: String` exports, visibility logic on `_ready()`, signal connection.
- `godot/scripts/autoload/signals.gd` — add `chapter1_flag_changed(flag_name: String, new_value: bool)` signal.
- Per-NPC scene exports — set `presence_flags` on each NPC in `pig_swine_office`. Excluding Asia and the not-yet-existing Halina.
- `godot/tests/test_npc_presence.gd` (new) — enumerate (flag-state, expected visible NPCs) tuples.

**Forbidden.**
- Schema changes to `State.data` (no `current_beat`, no new top-level keys).
- Modifying dialogue tree contents.
- Touching `casebook.gd` logic.
- Modifying `asia.gd` (Asia is exempt).
- Adding new NPC scenes (no Halina-creation in this pass).

**Acceptance.**
- `npc.gd` exports `presence_flags: Array[String]` and `presence_logic: String` (`"any"` or `"all"`, default `"any"`).
- Setting `State.data.chapter1.<flag>` to each declared value updates the correct NPC's visibility.
- `Signals.chapter1_flag_changed` re-runs presence on every NPC.
- New test enumerates representative (flag-state, expected visible NPC roster) tuples and asserts all pass.
- Existing NPC and asia-progression tests still pass.
- A short note in `CONVENTIONS.md` explains: "NPC presence keys off chapter1 flags; beats are narrative concepts in `narrative_revision/`, not runtime state."

**Output artifact.** `npc.gd` + `signals.gd` diffs + per-NPC scene diffs + new test + a one-line note in `CONVENTIONS.md`.

**Required reading.**
- `_legacy/design/chapters/1.md` through `5.md` (canonical beat structure)
- `_legacy/design/design_bible.md` § 3 (character roster, who's where when)
- `narrative_revision/bibles/halina_sikorska.md` (Halina's per-beat presence)
- `godot/scripts/actors/npc.gd`, `asia.gd`, `pig_idle_zone.gd`
- `godot/scripts/autoload/state.gd`, `signals.gd`, `casebook.gd`, `dialogue_runner.gd`
- `godot/scenes/interiors/pig_swine_office.tscn` (new TileMap version)
- `godot/tests/test_asia_progression.gd`, `test_npc.gd`

**Allowed writes.**
- `godot/scripts/actors/npc.gd`
- Per-NPC scene exports (set `presence_by_beat` on each).
- `godot/tests/test_npc_presence.gd` (new) — enumerate (beat, room, expected NPC roster).

**Forbidden.**
- Restructuring `State` (add a beat-changed signal if not already present, but no schema rewrite).
- Modifying dialogue tree contents.
- Touching `casebook.gd` logic.

**Acceptance.**
- Setting `State.current_beat` to each declared value spawns the correct cast in `pig_swine_office`.
- `Signals.beat_changed` (add if missing) re-runs presence on every NPC.
- New test enumerates every (beat, room, expected NPCs) tuple and asserts all pass.
- Existing NPC and asia-progression tests still pass.

**Output artifact.** `npc.gd` diff + per-NPC scene diffs + new test + a one-line note in `CONVENTIONS.md` referencing the presence schema.

---

## 12. Visual smoke harness — regression baseline

**Model: Claude Sonnet 4.6**

**Goal.** A single test scene that, for each interior, sets `State.current_beat` to each declared beat, walks the player through every direction, and saves screenshots to `godot/test_output/visual_smoke/<room>/<beat>/<direction>.png`. Used as a regression baseline — diff future runs against committed reference images.

**Required reading.**
- `godot/tests/test_visual_capture.gd` (existing capture harness — extend, don't replace)
- Every interior `.tscn`
- `godot/scripts/autoload/state.gd`
- `godot/CONVENTIONS.md`

**Allowed writes.**
- `godot/tests/test_visual_smoke.gd` (new)
- `godot/test_output/visual_smoke/.gitkeep`
- A `.gitignore` entry for non-reference outputs.

**Forbidden.**
- Modifying any production code (only test code and gitignore).
- Adding any new visual asset.
- Modifying existing tests.

**Acceptance.**
- Running the test produces N PNGs where N = (interior_rooms × declared_beats × 8 directions).
- Each PNG is named deterministically and sorted into the right folder.
- All existing tests still pass.
- The first run's outputs become the reference set, committed under `godot/test_output/visual_smoke/reference/` once visually approved.

**Output artifact.** New test + `.gitkeep` + the first reference PNG set.

---

## Notes on running these

**Run in numerical order.** The list is the order. Prompts 2, 3, and 4 are independent and can be run in parallel sessions if Antigravity supports it; otherwise run sequentially.

**The critical-path bottleneck** is prompts 7 → 8 → 9 (tile brief → TileSet → office rebuild). Everything after 9 depends on the office existing as a TileMap.

**For subsequent rooms** (archive, cafe, street): repeat Prompts 8 + 9 with the respective tileset and room scene. Each round is one tileset + one rebuilt scene. Once all four are migrated, the project is uniformly TileMap.

**Out of scope for this pass** (future prompt sets): courtroom scene transitions, the hearing minigame UI, the casebook journal, save-typewriter system, dialogue dual-mode (overworld bubble vs Ace Attorney full-screen).

**Each prompt's "Forbidden" section is load-bearing** — the agent should refuse to make out-of-scope changes and surface them as follow-ups instead of silently expanding scope.

---

## Follow-up backlog (surfaced by agent runs, not yet written as prompts)

Tasks that prompt runs have explicitly left dangling. Each is small enough to be its own follow-up prompt or a hand edit.

- **Wire flag writers to emit `Signals.chapter1_flag_changed`** (surfaced by Prompt 11 agent). The signal exists and NPCs subscribe to it, but no existing code emits it. Writers are in `dialogue_runner.gd` and any on_dismiss handlers that set `State.data.chapter1.<flag>`. After every write, emit `Signals.chapter1_flag_changed.emit(flag_name, new_value)`. Without this, NPC presence only refreshes on scene reload, not mid-scene. Easy fix; multi-file find-and-add.

- **Add Halina's NPC node to `pig_swine_office.tscn`** (surfaced by Prompt 11 agent). Halina is the chapter-1 client; her bible exists at `narrative_revision/bibles/halina_sikorska.md` and her `halina_sprite_frames.tres` was generated by Prompt 6. She belongs in the office for Beat 8 (the meeting) and should be absent before/after. Add as a child of `pig_swine_office` root with the canonical NPC structure: AnimatedSprite2D (using halina_sprite_frames), Area2D dialogue trigger, `presence_flags` keyed appropriately (likely something like `["met_pig"]` plus a flag for "Halina meeting in progress" that needs adding to chapter1 flags).

- **Iterate marble floor tile aesthetic** (deferred by user). Current cream-marble-with-cracks reads more "abandoned cathedral" than "working law firm." Regenerate or hand-paint in Aseprite with fewer cracks if the firm should feel functional rather than half-collapsed. Drop replacement PNG into `godot/art/tiles/`, the TileSet picks it up.

- **Generate office wall side-pieces** if you want vertical perimeter walls. Current `office_wall.png` is horizontal-perspective only (top wall). The Pokemon-Yellow convention is top-wall-only with invisible collision on the other sides, which Prompt 9 produces — fine as-is unless you want visible left/right walls. If so, separate Pixellab pass for vertical-wall art.

- **Repeat Prompts 8 + 9 for archive, cafe, street** rooms. Each room is one tileset (matching its mood per the design bible) and one rebuilt scene. After all four are migrated, the project is uniformly TileMap.
