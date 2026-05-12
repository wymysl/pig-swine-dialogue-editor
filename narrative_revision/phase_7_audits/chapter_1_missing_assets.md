# Chapter 1 — Missing assets + Pixellab prompts

**Goal:** complete asset inventory required to ship chapter 1 per the Tier 1 implementation plan (`chapter_1_tier1_implementation_plan.md`). Each asset includes a Pixellab-ready prompt matching the project convention from existing `_pixellab_metadata.json` files in `godot/art/sprites/<character>/`.

**Project style baseline** (from existing prompts):
- Characters: 92×92, `template_id: mannequin`, `directions: 8`, `view: low top-down`, `16-bit JRPG`, palette specified inline
- Props: smaller pixel sprites; convention not formalised in metadata; assume `~32×32` to `~96×96` depending on scale relative to the 92×92 character sprite
- Tiles: 16×16 or 32×32 tiling sprites; `office_tile.png` is the only existing reference
- Palette anchors used across the cast: `#1a1410` (deep brown-black outline), `#1c2a40` (dark navy), `#e8e4d8` (warm white/cream), `#0d0a08` (pure shadow); each character also has 1–3 distinct hue accents

**Methodology:** assets are bucketed by phase from the Tier 1 plan. Tier 1 is must-have to ship; Tier 2 is polish; Tier 3 is post-chapter content (declared in routes / unlocks but not yet implemented).

---

## Tier 1 — Must-have for chapter 1 ship

### Phase B (Beat 7-8 client meeting)

#### NPC: Halina Sikorska

Beat 8 client meeting carrier; gallery presence in Beat 12 court (silent); chapter-4 corridor sighting (out of scope for this asset list but the sprite is reusable).

**Path:** `godot/art/sprites/halina/halina_sprite_frames.tres` (idle 8-direction; walk 8-direction × 6 frames matches Asia's pattern)

**Pixellab prompt** (paste into character creation):

> Mid-70s Polish human female retired schoolteacher (taught Polish literature for 38 years), slim upright build with slight age-stiffness in posture but not stooped, silver-grey hair in a neat low chignon at the nape of the neck, grey wool jacket over a high-collared cream blouse, modest dark grey skirt below the knee, sensible low-heeled black leather shoes, holds a squared brown leather folder under one arm, small black leather handbag over the other shoulder, dignified composed bearing, slightly tired around the eyes from displacement worry but not weeping, NOT frail, NOT confused, the kind of pensioner who knew her father's railway colleagues by name, fully bipedal human, full body, 16-bit JRPG, pallette: #1a1410, #c8c4be, #4a4842, #e8e4d8, #6b5a48, #0d0a08

**Size:** 92×92. **Template:** mannequin. **Directions:** 8. **View:** low top-down.

**Required animations:** idle (8 dirs) + walk (8 dirs × 6 frames). Run animation NOT required (Halina never runs in-game).

**Notes:**
- The folder under one arm is character signature — keep it visible across all idle directions
- Slight age-stiffness in posture per `bibles/halina_sikorska.md`; do NOT request a stoop
- Palette: `#c8c4be` is the silver-grey hair / wool jacket; `#4a4842` is the darker grey skirt; `#6b5a48` is the leather folder/handbag

#### Prop: Meeting-room conference table

Phase B.2 Option 2a (sub-area within pig_swine_office.tscn). Existing scene already declares a `MeetingFloor` node; the table fills the visible space.

**Path:** `godot/art/props/office/meeting_table.png`

**Pixellab prompt:**

> 16-bit JRPG top-down pixel art prop, rectangular wooden meeting room conference table, mid-tone oak finish slightly worn from years of use, plain understated rim, no veneer or polish, suitable for a small Polish law firm meeting room circa late 2010s, top-down low-angle view matching pig_swine_office props, transparent background, pallette: #1a1410, #8a6a4a, #6b4a32, #c8a868, #0d0a08

**Size:** ~128×64 (matches the meeting-floor area in the existing scene; verify in editor). **Template:** prop / static object.

**Notes:** Match the existing `desk_pig.png` / `desk_murrow.png` style — same wood tone, same rim treatment.

#### Prop: Meeting-room chair

Reusable; ~5–6 instances around the conference table.

**Path:** `godot/art/props/office/meeting_chair.png`

**Pixellab prompt:**

> 16-bit JRPG top-down pixel art prop, single plain office meeting room chair with low padded back and four wooden legs, neutral dark grey upholstery, mid-tone oak frame, no armrests, the kind of chair a small Polish law firm orders in bulk for its meeting room, top-down low-angle view matching pig_swine_office props, transparent background, pallette: #1a1410, #4a4842, #8a6a4a, #6b6862, #0d0a08

**Size:** ~24×32. **Template:** prop. **Notes:** chair sprite must read as "chair" from low-top-down without ambiguity; may need 2 directions (facing the table from each long side) if the engine renders both.

### Phase C (Beat 11-12 walk + court rounds)

#### NPC: District Court Judge

Beat 12 carries three rounds of dry-surprise reactions per `judge_district_ch1.json`; only on-screen as a seated NPC behind the bench. Walk frames not required (judge enters and exits through the door behind the bench; staging can use a curtain/door open animation instead).

**Path:** `godot/art/sprites/judge_district_ch1/judge_sprite_frames.tres`

**Pixellab prompt:**

> Late-50s Polish human male district court judge, slim build, neat short grey hair receding at the temples, half-moon reading glasses worn low on the nose, traditional black judicial robe with white preacher-style collar tabs at the throat, expression composed and dryly observant rather than stern, the kind of judge who has read too many service-defect motions to be surprised by another, seated reading register dominant but full-body sprite required for direction set, fully bipedal human, full body, 16-bit JRPG, pallette: #1a1410, #c8c4be, #1c1812, #e8e4d8, #6b5a48, #0d0a08

**Size:** 92×92. **Template:** mannequin. **Directions:** 8 (only south / south-east / south-west needed in scene; full set for engine consistency). **Animations:** idle (8 dirs); page-turn animation (south only, 4 frames — judge consults bench file); NO walk required for chapter 1.

**Notes:**
- Robe must read as black (`#1c1812`); collar tabs cream (`#e8e4d8`)
- Expression: dry-surprise register per V1.6 pack §A canonical envelope (*"That argument lands, despite the manner of its arrival."*)

#### NPC: Landlord's Counsel

Beat 12; one functional response line per round per `dialogue_samples_landlord_counsel_ch1.jsonl`. Stands at respondent's table; brief inclination at close.

**Path:** `godot/art/sprites/landlord_counsel_ch1/landlord_counsel_sprite_frames.tres`

**Pixellab prompt:**

> 50-something Polish human male respondent's lawyer, average build, salt-and-pepper hair side-parted neat, no facial hair, plain dark grey two-piece suit slightly worn at the elbows, white dress shirt, narrow dark blue tie, holds a thin manila folder open in front of him, the blandness of a practitioner who has done this twice this week, no theatrical flair, no villain register, professionally functional, fully bipedal human, full body, 16-bit JRPG, pallette: #1a1410, #c8c4be, #4a4842, #e8e4d8, #1c2a40, #0d0a08

**Size:** 92×92. **Template:** mannequin. **Directions:** 8. **Animations:** idle (8 dirs); a brief "incline-head-and-leave" animation (south, 6 frames) for Beat 12 close. Walk not required.

**Notes:**
- Per V1.6 pack §B.6: functional adversary; no characterisation beyond appearance and folder; no villain register
- Palette is deliberately neutral — closer to the judge's grey register than the petitioner team's distinctive accents

#### NPC: Court Clerk

Optional; the clerk reads the cause list and rises with the bench but never speaks lines committed in V1.6. If sprite budget is tight, the clerk can be staged off-screen and replaced by a stage direction. Recommendation: skip for first ship, reuse the existing generic-blocker NPC if needed.

**Path:** *(skip for first ship; flag for polish pass)*

#### Tile: Court floor (wood parquet)

`district_court.tscn` interior floor.

**Path:** `godot/art/tiles/court_floor_tile.png`

**Pixellab prompt:**

> 16-bit JRPG seamless tiling pixel art texture, herringbone wood parquet floor pattern, dust-colour wood (warm neutral tan with subtle age-darkened seams), suitable for a Polish district courtroom interior, low top-down view, the floor must tile cleanly on a 32x32 grid, transparent edges where wood seams meet, pallette: #1a1410, #b89870, #8a6a4a, #c8a868, #0d0a08

**Size:** 32×32 seamless tile (or 64×64 if the project uses larger tiles; verify against `office_tile.png`). **Notes:** the V1.6 pack §A.6 specifies "dust-colour wood" matching the embankment trees outside — keep the warm neutral tan; do NOT go darker into mahogany.

#### Tile: Court wall paneling

Vertical wall surface; mid-height wood paneling above which plaster runs to the ceiling.

**Path:** `godot/art/tiles/court_wall_panel_tile.png`

**Pixellab prompt:**

> 16-bit JRPG seamless tiling pixel art texture, vertical wood-panel wainscoting wall surface, dust-colour oak with horizontal panel grooves every 16 pixels, suitable for a Polish district courtroom wall (lower half panel; upper half plaster transition above), low top-down side-view as a wall texture, the panel must tile cleanly horizontally and vertically, pallette: #1a1410, #b89870, #8a6a4a, #c8a868, #0d0a08

**Size:** 32×64 (taller than wide for vertical wall surface). **Notes:** if the engine uses ColorRect walls (as `pig_swine_office.tscn` does for `WallVisuals/TopOuter` etc.), this tile can be applied as a TextureRect overlay; otherwise wire as a TileSet.

#### Prop: Judge's bench (raised)

Large; central; raised platform with the state seal mounted on the wall directly above.

**Path:** `godot/art/props/court/bench.png`

**Pixellab prompt:**

> 16-bit JRPG top-down pixel art prop, raised wooden judge's bench for a Polish district courtroom, dust-colour oak matching the wall paneling, two-tier construction (lower clerk's level visible at the foot, raised judge's level above with a desk surface for the bench file), simple panelled face without ornate carving, modestly proportioned for a district court not a supreme court, top-down low-angle view, transparent background, pallette: #1a1410, #b89870, #8a6a4a, #c8a868, #0d0a08

**Size:** ~128×96 (large; spans the back of the courtroom). **Notes:** raised platform is structurally important — the judge sits visibly above counsel's tables; the bench should read as elevated even in low-top-down.

#### Prop: Bronze state seal

Mounts on the wall above the judge's bench. V1.6 pack §A.6 specifies "fresh bronze" — the recasting is the running joke that connects to the embankment statesman whose name has been recast three times.

**Path:** `godot/art/props/court/state_seal.png`

**Pixellab prompt:**

> 16-bit JRPG top-down pixel art prop, fresh bronze Polish state seal mounted as a wall plaque, circular form roughly 32x32 pixels with a stylised eagle motif at center, recently re-cast (the bronze still has a bright sheen, not yet aged to verdigris), wall-mounted at courtroom-bench height behind the judge's bench, low top-down side-view as a wall element, transparent background, pallette: #1a1410, #c8a868, #8a6a32, #e8c478, #0d0a08

**Size:** ~32×32. **Notes:** the brightness is the joke — a recently-installed seal in a very old courtroom. Keep the bronze hot (`#c8a868` / `#e8c478`); do NOT add patina.

#### Prop: Clerk's desk

Below the judge's bench to the bench's left. Smaller than the judge's bench.

**Path:** `godot/art/props/court/clerk_desk.png`

**Pixellab prompt:**

> 16-bit JRPG top-down pixel art prop, small wooden clerk's desk for a Polish district courtroom, set lower than the judge's bench, dust-colour oak matching court palette, plain undecorated front, holds the cause list and a small writing surface, top-down low-angle view, transparent background, pallette: #1a1410, #b89870, #8a6a4a, #c8a868, #0d0a08

**Size:** ~64×40. **Notes:** the desk should read as smaller and lower than the judge's bench from the same view angle.

#### Prop: Witness stand

Right of the bench; unoccupied across all of Beat 12 (V1.6 has no witnesses).

**Path:** `godot/art/props/court/witness_stand.png`

**Pixellab prompt:**

> 16-bit JRPG top-down pixel art prop, small enclosed wooden witness stand for a Polish district courtroom, three-sided railing around a single chair, dust-colour oak matching court palette, the kind of stand that holds one witness at a time but is empty in this scene, top-down low-angle view, transparent background, pallette: #1a1410, #b89870, #8a6a4a, #c8a868, #0d0a08

**Size:** ~48×48. **Notes:** unoccupied; chair visible inside the railing but empty.

#### Prop: Counsel table (reusable for petitioner and respondent sides)

Two instances: petitioner's left, respondent's right. Each holds a thin folder per side.

**Path:** `godot/art/props/court/counsel_table.png`

**Pixellab prompt:**

> 16-bit JRPG top-down pixel art prop, plain rectangular wooden counsel's table for a Polish district courtroom, four chairs arrangement (two per long side), dust-colour oak matching court palette, plain understated rim, no decoration, suitable for a district court not a supreme court, top-down low-angle view, transparent background, pallette: #1a1410, #b89870, #8a6a4a, #c8a868, #0d0a08

**Size:** ~96×56. **Notes:** the table is reused on both sides; mirror via TextureRect flip in the scene rather than producing two sprites.

#### Prop: Gallery seating row

Row behind the bar; 4–5 fixed seats. Murrow and Halina occupy two seats during Beat 12.

**Path:** `godot/art/props/court/gallery_row.png`

**Pixellab prompt:**

> 16-bit JRPG top-down pixel art prop, single long fixed wooden gallery bench for a Polish district courtroom public seating, dust-colour oak, simple panelled face, capacity for four to five seated persons across, no individual chair separators, top-down low-angle view, transparent background, pallette: #1a1410, #b89870, #8a6a4a, #c8a868, #0d0a08

**Size:** ~160×24 (wide, low). **Notes:** the gallery bench is one long unit, not separate chairs; matches the V1.6 pack §A.6 staging.

#### Prop: Court door (×2 — judge's rear and public entrance)

Same sprite reused for both; placement differs.

**Path:** `godot/art/props/court/court_door.png`

**Pixellab prompt:**

> 16-bit JRPG top-down pixel art prop, plain solid wooden door for a Polish district courtroom, dust-colour oak with a single brass handle on the right, modestly proportioned (a door, not a portal), suitable for both the judge's rear-of-bench entrance and the public courtroom entrance, top-down low-angle view, transparent background, pallette: #1a1410, #b89870, #8a6a4a, #c8a868, #0d0a08

**Size:** ~32×64. **Notes:** reuse the existing `office_door.png` if its style and palette already match; only commission a new sprite if the office door is too modern or too distinctively scaled. Verify in editor first.

### Phase D (Beat 13-14 office payoff)

#### Prop: Postcard (Sapporo)

Beat 14 final stinger. Asia hands it to Pig; Pig reads body aloud; the postcard rests on the desk through the chapter close. The picture-side faces the room briefly during the close.

**Path:** `godot/art/props/office/postcard_sapporo.png`

**Pixellab prompt:**

> 16-bit JRPG top-down pixel art prop, single picture postcard from Sapporo Japan, picture side shows a stylised blue harbour with a low snow-capped mountain in the background and a small scattering of harbour buildings, postcard format with white border, the kind of postcard a small business traveller would buy at a hotel gift shop, postcard size relative to a desk surface (small object), top-down low-angle view, transparent background, pallette: #1a1410, #4a78a8, #c8c4be, #e8e4d8, #4a4842, #0d0a08

**Size:** ~32×24. **Notes:** the picture is descriptive per V1.7 pass 5 stage direction (*"the front shows a snowy building and a sign too small to read at this distance"*) — keep the harbour and low mountain readable; do NOT add Japanese-language text (the sign is too small to read at this distance per stage direction). Could optionally produce a back-side variant showing the address label and stamp area, but for the existing draft staging only the picture-side and the desk presence are needed.

---

## Tier 2 — Polish (defer until after first playthrough)

### Walk animations for existing static-only NPCs

Currently Asia and Cula have full walk animations. Mr. Pig, Mr. Swine, Murrow, Whimsy, and Crab have idle frames only. None of them walk on-screen during chapter 1's playable beats (they're stationed at desks / archive room / café), so this is true polish. Required if Beat 11 walk scene is built (Phase C.1 Option 2 — currently recommended skipped).

For each NPC, the Pixellab prompt is the existing one in `_pixellab_metadata.json` with the walk animation added:
- Mr. Pig: walk (8 dirs × 6 frames)
- Mr. Swine: walk (deferred entirely; Swine never appears in chapter 1, only via postcard)
- Murrow: walk
- Whimsy: walk
- Crab: walk

**Effort note:** add one animation per character via Pixellab's "extend animations" workflow against the existing character ID rather than re-prompting from scratch.

### Portraits for new NPCs

Convention: `godot/art/portraits/<character>.png` for dialogue UI portrait. 6 existing portraits are 96×96 head-and-shoulders.

#### Halina portrait

**Path:** `godot/art/portraits/halina.png`

**Pixellab prompt:**

> Mid-70s Polish human female retired schoolteacher portrait, head and shoulders, silver-grey hair in low chignon, grey wool jacket over high-collared cream blouse, dignified composed expression, slightly tired around the eyes, looking forward, neutral background, 16-bit JRPG portrait style matching the existing cast portraits, pallette: #1a1410, #c8c4be, #4a4842, #e8e4d8, #6b5a48, #0d0a08

**Size:** 96×96.

#### Judge portrait

**Path:** `godot/art/portraits/judge_district_ch1.png`

**Pixellab prompt:**

> Late-50s Polish human male district court judge portrait, head and shoulders, neat short grey hair receding at temples, half-moon reading glasses low on nose, black judicial robe with white collar tabs visible at throat, dryly observant composed expression, looking forward, neutral background, 16-bit JRPG portrait style matching the existing cast portraits, pallette: #1a1410, #c8c4be, #1c1812, #e8e4d8, #6b5a48, #0d0a08

**Size:** 96×96.

#### Landlord-counsel portrait

**Path:** `godot/art/portraits/landlord_counsel_ch1.png`

**Pixellab prompt:**

> 50-something Polish human male respondent's lawyer portrait, head and shoulders, salt-and-pepper hair side-parted, dark grey suit slightly worn at elbows, white shirt, narrow dark blue tie, professionally bland expression, looking forward, neutral background, 16-bit JRPG portrait style matching the existing cast portraits, pallette: #1a1410, #c8c4be, #4a4842, #e8e4d8, #1c2a40, #0d0a08

**Size:** 96×96.

### Beat 13 character props (polish)

#### Pig's handkerchief (small overlay)

V1.7 pass 5 staging: Pig holds a handkerchief; it folds and unfolds in his hand. Could be a small overlay sprite drawn on top of Pig's idle frames, OR could be omitted (handkerchief is implied; staging note remains in the dialogue file as a comment but doesn't need to render). Recommendation: omit for first ship; pure polish.

**Path:** *(skip for first ship)*

#### Murrow's ledger (drawer animation)

V1.7 pass 5 Beat 13 stage direction: Murrow opens drawer, lifts ledger, makes notation, returns ledger, closes drawer. Could be:

- Option 1 (recommended): hide ledger inside a 4-frame drawer animation on the existing `desk_murrow.png` — a simple sprite swap on Murrow's desk
- Option 2: produce a separate ledger prop sprite that appears briefly on Murrow's blotter

**Path (if Option 2):** `godot/art/props/office/ledger_book.png`

**Pixellab prompt:**

> 16-bit JRPG top-down pixel art prop, single dark cloth-bound accounting ledger book lying flat open on a desk, dark navy or burgundy cover, plain ruled pages visible, the kind of ledger a small Polish law firm has been using for years, modestly worn, top-down low-angle view, transparent background, pallette: #1a1410, #4a2a32, #e8e4d8, #c8c4be, #0d0a08

**Size:** ~32×24. **Notes:** chapter-4 Beat 11 inflection plant requires the page to be angled away from Cula — sprite alone doesn't carry the angle, but the engine staging in `pig_swine_office.tscn` can place the prop oriented so the open page faces Murrow's reading direction.

### Evidence document props (Beat 8)

`halina.json` Beat 8 references three stance-aligned bonus evidence items + the always-present current tenancy paperwork + the defective notice + the court docket. If the engine treats these as inventory icons, only generic "document" sprites are needed; if as scene objects, each needs its own sprite. Recommendation: generic document sprite reused with item metadata; only the postcard gets a unique sprite (visible in the chapter close).

**Path:** `godot/art/props/office/document_generic.png`

**Pixellab prompt:**

> 16-bit JRPG top-down pixel art prop, single sheet of legal document paper with visible handwritten or typed text reduced to abstract horizontal lines (text not readable, just the visual texture of writing), plain white paper with a subtle stamp or signature mark in one corner, top-down low-angle view, transparent background, pallette: #1a1410, #e8e4d8, #c8c4be, #4a4842, #0d0a08

**Size:** ~24×32. **Notes:** reused for all six paper artefacts in Beat 8. Inventory metadata distinguishes them; sprite is generic.

---

## Tier 3 — Post-chapter-1 (declared but not yet implemented)

### Beat 11 walk-scene props (Phase C.1 Option 2 — currently recommended skipped)

If you later choose to build the walk scene per V1.5 pass 1 staging, these are the assets needed. The Tier 1 plan recommends Option 1 cut, deferring all of these.

- Embankment tile (`art/tiles/embankment_tile.png`) — riverside path stone tile, dust-colour stone matching the trees
- Vistula river tile (`art/tiles/river_tile.png`) — water tile, low brown tone (V1.5 specifies "low and brown")
- Embankment tree (`art/props/walk/tree_dust_colour.png`) — single tree with dust-colour leaves (late spring per V1.5)
- Statesman statue (`art/props/walk/statesman_statue.png`) — bronze figure on a stone pedestal; the running joke is the pedestal has been recast three times in 50 years (per V1.5 staging); chip the pedestal text sprite to read as recently overwritten
- Pigeon × 3 (`art/props/walk/pigeon.png`) — small pigeon sprite, judgmental expression possible only as a single posture facing the camera
- Courthouse pediment exterior (`art/props/walk/courthouse_pediment.png`) — sandstone facade with bronze state seal (recently recast — same fresh bronze as the bench seal)
- Public-works truck (`art/props/walk/works_truck.png`) — idling work vehicle (the workman in the cab is a small NPC, optional)
- Workman NPC (idle only) — small NPC sprite reading a folded newspaper
- Two clerk NPCs (idle only; pass-through) — generic clerks crossing the opposite pavement carrying folders

Pixellab prompts for each available on request; deferred per current Tier 1 plan recommendation.

### Court Plaza route (post-Beat-14 unlock)

Declared as a route unlock at chapter close. No scene exists. Tier 3.

### Residential / Business District routes (post-Beat-14 unlock)

Declared as route unlocks. No scenes exist. Tier 3.

---

## Effort summary

| Tier | Asset | Pixellab effort | Engine integration | Notes |
| --- | --- | --- | --- | --- |
| 1 | Halina sprite (idle + walk) | ~30 min generation + iteration | 1h tres + scene wiring | Highest priority |
| 1 | Judge sprite (idle + page-turn) | ~20 min | 30 min | No walk needed |
| 1 | Landlord-counsel sprite (idle + brief incline) | ~20 min | 30 min | No walk needed |
| 1 | Meeting-room table | ~10 min | 15 min | One sprite |
| 1 | Meeting-room chair | ~10 min | 30 min | Reused 5–6× |
| 1 | Court floor tile | ~10 min | 15 min | Seamless tile |
| 1 | Court wall panel tile | ~10 min | 15 min | Seamless tile |
| 1 | Bench (judge's) | ~15 min | 20 min | Large, central |
| 1 | Bronze state seal | ~10 min | 10 min | Wall-mounted |
| 1 | Clerk's desk | ~10 min | 15 min | |
| 1 | Witness stand | ~10 min | 15 min | Empty |
| 1 | Counsel table | ~15 min | 30 min | Reused × 2 (mirror) |
| 1 | Gallery row | ~10 min | 15 min | Long bench |
| 1 | Court door | ~10 min | 15 min | Reused × 2 (or skip if office_door.png matches) |
| 1 | Postcard (Sapporo) | ~10 min | 10 min | Beat 14 stinger |

**Tier 1 total: ~3 hours of asset generation + ~5–6 hours of engine integration. Halina is the longest single asset (full walk animation set).**

| Tier | Asset | Effort |
| --- | --- | --- |
| 2 | 4× walk animations for Pig/Murrow/Whimsy/Crab | ~1 hour each |
| 2 | 3× new portraits | ~30 min total |
| 2 | Murrow ledger drawer animation | ~30 min |
| 2 | Generic document prop | ~10 min |

| Tier | Asset | Effort |
| --- | --- | --- |
| 3 | Walk-scene props × ~8 | ~3 hours; deferred per Tier 1 plan |
| 3 | Route stub scenes × 3 | post-chapter-1 |

---

## Decisions to record before Pixellab generation

1. **Halina sprite walk animation: required or skipped?** Halina walks from the meeting-room entrance to the table in Beat 8 staging; she also crosses the gallery in Beat 12. Walk is technically required for both. However, both moves can be staged via an instant teleport / fade if walk is too expensive. Recommendation: produce walk animation; the Beat 8 entrance walk is short (~2 seconds of screen time) but it's the player's first impression of Halina.
2. **Judge sprite directions: full 8 or partial?** Judge only ever sits behind the bench facing south toward counsel. Producing 8 directions for engine consistency vs producing south + south-east + south-west only: recommendation full 8 for consistency with the project's `template_id: mannequin` convention; the unused directions cost 5 minutes of generation each.
3. **Landlord-counsel "incline-and-leave" animation: required?** V1.6 pack §B.6 staging has him incline briefly toward the petitioner's table at close and leave the room. Could be staged as: idle face → mirrored idle → off-screen exit, OR as a dedicated 6-frame animation. Recommendation: skip the animation; stage via existing idle frames flipped + a movement tween. Saves ~10 minutes of generation.
4. **Meeting-room table size**: needs to fit 5 seated characters (Cula, Crab, Whimsy, Halina, Murrow) per V1.4 staging. Verify the meeting-floor area in the existing pig_swine_office.tscn supports a 128×64 table; if not, either resize the meeting-floor area or commission a smaller table.
5. **Court floor tile parquet vs plain**: V1.6 pack §A.6 specifies "panelled in the same dust-colour wood as the embankment trees outside." Parquet pattern is a stylistic choice not specified in the pack; plain plank-orientation is also valid. Recommendation: parquet for visual variety against the office's plain office_tile.png; switch to plain if parquet reads too ornate for a district court.
6. **Postcard front-side picture**: V1.7 pass 5 stage direction is descriptive ("a snowy building and a sign too small to read at this distance"). The current Pixellab prompt foregrounds the harbour + low mountain per the Sapporo location. If the player is meant to see snow per the stage direction, swap "blue harbour" for "snow-covered street with low building" — but the Sapporo connection (Sea of Japan continuity from Pig's retainer aside) is most legible with the harbour. Pick one; record the choice.

---

## Order of operations

Per Tier 1 implementation plan dependencies:

1. **Generate Halina sprite** (longest asset; do first — Phase B.2 blocks on it)
2. **Generate court tiles** (floor + wall) — Phase C.2 needs these to even start the scene
3. **Generate judge + landlord-counsel sprites** — Phase C.2 / C.3 blocks
4. **Generate court interior props** (bench, seal, clerk desk, witness stand, counsel tables, gallery row, court door) — Phase C.2
5. **Generate meeting-room props** — Phase B.2 (parallel with court work)
6. **Generate postcard sprite** — Phase D.2 (last; lightest)

After Tier 1 ships and the chapter plays end-to-end, Tier 2 polish pass adds walk animations and portraits.

**Pixellab batching tip:** the four court-furniture props (clerk desk, witness stand, counsel table, gallery row) all use the same dust-colour oak palette. Generate them in one Pixellab session with a shared style reference for consistency.

---

## End of asset list

When generation begins, save Pixellab outputs to the paths specified above. Update each character's `_pixellab_metadata.json` with the new entry per the existing convention. Wire props into `pig_swine_office.tscn` (meeting-room sub-area) and the new `district_court.tscn` (Phase C.2). Wire postcard into `postcard_swine_ch1.json` Beat 14 staging.
