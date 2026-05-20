# Pixellab — Street Pack 02 (targeted single-asset prompts)

Paste each prompt into Pixellab as its own session. One asset per generation. Lock the seed and save it along with the file. All player-facing text is English (per the English-first signage rule). Save each output into `godot/art/props/` (or `godot/art/sprites/<npc_id>/` for NPCs) under the `SAVE AS` filename.

## Section A — Signage (English-only)

### A1. Cafe Paragraf sign

```
128×40 pixel-art horizontal wall-mounted sign, hand-painted style,
photographed straight on. Dark walnut wood frame #3a2818. Tram-green
background panel #3a6848. Cream-parchment serif lettering #e8e4d8
reading "CAFÉ PARAGRAF" centred across the panel. To the left of the
text, a small typographic § ornament in matching cream. The sign has
a faint chip at the lower-right corner exposing pale wood. Transparent
background outside the sign itself.

NEGATIVE: no people, no decoration around the sign, no shading
gradient, no 3D, no perspective, no neon, no modern sans-serif, no
Polish words

SUCCESS: reads instantly as a small cafe sign above a door. Text
legible.

SAVE AS: cafe_paragraf_sign.png
```

### A2. Street notice board

```
64×80 pixel-art wall-mounted cork notice board in a dark wood frame,
photographed straight on. The cork interior #b89868 is visible. Pinned
to it are three small paper rectangles in slightly different sizes and
tilts: one parchment cream #e8e4d8, one mustard #c8a868, one neon red
#d84040. The papers are blank — no readable text (text is added per
state inside the game). The wood frame is #3a2818 with a faint grain.
Transparent background outside the board.

NEGATIVE: no people, no readable text, no Polish words, no shading
gradient, no 3D, no perspective, no ornament around the frame

SUCCESS: reads as a small public notice board with three pinned slips.

SAVE AS: street_notice_board.png
```

### A3. Court signpost

```
32×96 pixel-art vertical signpost, photographed straight on. A slim
dark steel pole #3a3838 runs the full height. At the top, a blue
rectangular plate #1c3a5a about 32×24 px with white serif lettering
#e8e4d8 reading "DISTRICT COURT" on one line and an arrow "→" on a
second line. The post has a small concrete base #888884 at the
bottom. Transparent background outside the post.

NEGATIVE: no people, no decoration, no street lamp, no Polish words,
no shading gradient, no 3D, no perspective, no flag

SUCCESS: reads as a small civic direction signpost. Text legible.

SAVE AS: court_signpost.png
```

### A4. Street-name plate — Office Street

```
80×32 pixel-art wall-mounted rectangular plate, photographed straight
on. Plate background blue #1c3a5a. Crisp white serif lettering #e8e4d8
reading "OFFICE STREET" centred horizontally. A thin white inset
border just inside the plate edge. Transparent background outside the
plate.

NEGATIVE: no people, no decoration, no Polish words, no shading
gradient, no 3D, no perspective, no ornament, no flag

SUCCESS: reads instantly as a Warsaw-style enamel street-name plate.

SAVE AS: street_name_office_street.png
```

### A5. Street-name plate — Counsel Row

```
80×32 pixel-art wall-mounted rectangular plate, photographed straight
on. Plate background blue #1c3a5a. Crisp white serif lettering #e8e4d8
reading "COUNSEL ROW" centred horizontally. A thin white inset border
just inside the plate edge. Transparent background outside the plate.

NEGATIVE: no people, no decoration, no Polish words, no shading
gradient, no 3D, no perspective, no ornament, no flag

SUCCESS: matches the visual style of street_name_office_street.png
exactly — same plate, same font, only the text differs.

SAVE AS: street_name_counsel_row.png
```

### A6. Tram stop sign — line 17

```
32×80 pixel-art vertical sign on a slim steel pole, photographed
straight on. Pole #3a3838 about 4 pixels wide runs the full height.
Near the top, a blue rectangular sign about 32×40 px #1c3a5a with
a large white capital "T" pictogram #e8e4d8 centred near the top and
a large white number "17" centred below it. Small concrete footing
#888884 at the bottom of the pole. Transparent background outside the
sign and pole.

NEGATIVE: no people, no decoration, no Polish words, no overhead wire,
no shading gradient, no 3D, no perspective

SUCCESS: reads as a public-transit stop pole. "T" and "17" legible.

SAVE AS: tram_stop_sign_17.png
```

## Section B — Furniture and street structure

### B1. Street bench

```
96×40 pixel-art horizontal wooden slat bench on cast-iron legs,
photographed at a slight 3/4 front angle so the seat surface is
visible. Four horizontal wooden slats #6a4a30, faded mustard paint
#c8a868 in worn patches. Two cast-iron legs #3a3838 at the ends. One
slat near the right end is missing — a visible gap. Transparent
background outside the bench itself.

NEGATIVE: no people, no animals, no objects on the bench, no shading
gradient, no 3D photoreal, no perspective beyond gentle 3/4, no
ornament

SUCCESS: reads as a public park-style bench. Slats and legs distinct.

SAVE AS: street_bench.png
```

### B2. Trash bin (public concrete)

```
32×56 pixel-art prop of a public street trash bin, photographed at a
slight 3/4 front angle. Cylindrical concrete body #888884 with a
darker rim #4a4a48 at the top. A dark metal liner edge #3a3838 just
inside the rim. A faded square city-crest stencil #5a5a60 on the
front face — abstract shape, no readable text. Small base shadow
#2a2624 along the bottom. Transparent background outside the bin.

NEGATIVE: no people, no garbage spilling out, no shading gradient,
no 3D photoreal, no readable text, no logo, no Polish words

SUCCESS: reads instantly as a public street rubbish bin.

SAVE AS: trash_bin_public.png
```

### B3. Fenced concrete planter

```
48×48 pixel-art top-down prop of a small square concrete planter with
a low wrought-iron fence around three sides, photographed from a
slight overhead angle. Concrete edge #888884 forms the planter rim.
Wrought-iron rail #2a2624 on three sides, ~3 px tall. Bare-soil
centre #4a3424 with one stubby sapling sticking up — thin dark trunk
#3a2818 with three or four small bare twigs. Transparent background
outside the planter.

NEGATIVE: no people, no flowers, no leaves, no shading gradient, no
3D photoreal, no ornament

SUCCESS: reads as a small fenced street tree-plot.

SAVE AS: fenced_planter.png
```

### B4. RUCH kiosk (Polish newspaper kiosk, English-only signage)

```
96×96 pixel-art prop of a traditional Polish newspaper kiosk, a small
wooden booth photographed at a slight 3/4 front angle. Walnut wood
body #6a4a30 with a steel-grille service window in the front centre
#3a3838. A horizontal warm-orange signage band #e87830 across the
top reading "PRESS · TICKETS" in cream serif lettering #f0e8d0.
Below the service window, a small shelf with a few stacked newspaper
silhouettes #e8e4d8 (no readable text). Sloped roof with slight
overhang. Transparent background outside the kiosk.

NEGATIVE: no people, no Polish words (no "RUCH", no "GAZETY", no
"PAPIEROSY"), no readable newspaper text, no shading gradient, no
3D photoreal, no modern glass-walled kiosk

SUCCESS: reads instantly as a small old-style newspaper kiosk, with
English signage.

SAVE AS: kiosk_press.png
```

### B5. Tram-stop platform segment

```
96×32 pixel-art top-down tile of a short concrete tram-stop platform
island, photographed from directly above. Concrete surface #888884
with subtle paving lines. Along the bottom edge (the road-facing side),
a single bright yellow tactile warning strip #e8c840 about 6 px tall
with a dotted pattern of darker bumps #b89028. The left and right
edges are flat so the tile is seamlessly tileable horizontally —
placing two or three side by side forms a longer platform.

NEGATIVE: no people, no signs (the stop sign is a separate prop), no
trees, no shading gradient, no 3D, no perspective other than top-down,
no Polish words

SUCCESS: tile-able horizontally; yellow tactile strip reads as a
warning edge.

SAVE AS: tram_stop_platform_segment.png
```

## Section C — Flavor and decoration

### C1. Judgmental pigeon (idle)

```
16×16 pixel-art prop of a single Warsaw pigeon, photographed at a
3/4 front angle, standing on the ground. Round grey body #888884
with subtle mint highlight #88b0a0 on the neck. Black head #2a2624
with a tiny orange beak #c8a040. Small dark feet #3a3838. The pigeon
is leaning very slightly forward as if judging something. Transparent
background.

NEGATIVE: no flying, no wings spread, no multiple pigeons, no shading
gradient, no 3D photoreal, no cute cartoon proportions, no human
expression

SUCCESS: reads instantly as a single grey city pigeon, slightly
disapproving silhouette.

SAVE AS: pigeon_idle.png
```

### C2. Parked sedan (top-down)

```
96×40 pixel-art top-down silhouette of a parked sedan, photographed
from directly above. Dark grey body #4a4848 with very subtle highlight
on the roof #5a5a5a. Four square windows visible from above #2a2624.
A small windshield wiper detail at the front #3a3838. The car is
oriented horizontally (left-right). Subtle pavement shadow #2a2624
under the car. Transparent background outside the car silhouette.

NEGATIVE: no people, no driver visible, no headlights on, no shading
gradient, no 3D, no perspective other than top-down, no Polish words,
no licence plate text

SUCCESS: reads instantly as a sedan seen from directly above, parked.

SAVE AS: parked_sedan.png
```

### C3. Parked hatchback (top-down)

```
80×40 pixel-art top-down silhouette of a parked hatchback, photographed
from directly above. Faded mint paint body #88b0a0 with very subtle
roof highlight #98c0b0. Three square windows visible from above
#2a2624 plus a small rear-hatch window at the back. The car is
oriented horizontally (left-right). Subtle pavement shadow #2a2624
under the car. Transparent background outside the car silhouette.

NEGATIVE: no people, no driver, no headlights on, no shading gradient,
no 3D, no perspective other than top-down, no Polish words, no
licence plate text

SUCCESS: reads instantly as a smaller hatchback (visibly shorter than
the sedan) seen from above.

SAVE AS: parked_hatchback.png
```

### C4. Graffiti decal 1 (transparent overlay)

```
64×32 pixel-art transparent overlay decal of a rough graffiti tag
shape, photographed straight on as if painted on a wall. The shape is
a single jagged black-ink scrawl #1a1410, no readable letters, just
abstract loops and angles. One small neon-red highlight #d84040
inside one of the loops. The rest of the tile is fully transparent —
no background, no border, no frame. The decal is meant to be
composited on top of facade wall tiles.

NEGATIVE: no readable text, no Polish words, no English words, no
people, no shading gradient, no 3D, no perspective, no border, no
frame, no decoration around the scrawl

SUCCESS: when composited on a beige wall, reads as a single graffiti
tag without language.

SAVE AS: graffiti_decal_01.png
```

### C5. Graffiti decal 2 (transparent overlay)

```
64×32 pixel-art transparent overlay decal of a different rough
graffiti shape, distinct in silhouette from decal_01. Where decal_01
was jagged with angles, this one is all rounded loops — three or
four bubble-shaped strokes in black ink #1a1410 with one cream
highlight #e8e4d8 along the top of one loop. No readable letters. The
rest of the tile is fully transparent — no background, no border, no
frame.

NEGATIVE: no readable text, no Polish or English words, no people, no
shading gradient, no 3D, no perspective, no border, no frame, no
decoration around the scrawl

SUCCESS: visually distinct from decal_01; reads as a different tagger.

SAVE AS: graffiti_decal_02.png
```

### C6. Abandoned coffee cup

```
16×16 pixel-art prop of a small paper takeaway coffee cup, photographed
at a slight 3/4 angle as if sitting on a bench. Parchment-cream body
#e8e4d8 with a faded brown sleeve band across the middle #6a4a30. A
small dark lid #3a3838 with a sip hole. The cup is slightly crumpled
on one side. Transparent background outside the cup itself.

NEGATIVE: no people, no brand text, no logo, no readable text, no
Polish or English words, no shading gradient, no 3D photoreal, no
steam

SUCCESS: reads instantly as an abandoned takeaway coffee cup.

SAVE AS: abandoned_coffee_cup.png
```

## Section D — NPC sprites (124×124, 8-direction idle)

**Shared style anchor** (use in every NPC prompt below — Pixellab default
size 124×124, 8-direction idle, hands at sides, no held objects, no facial
detail, adult 1:5 proportions):

```
STYLE: minimal synthetic line drawing, sparse flat shapes, institutional
mood, neutral observational rendering, pixel-art, adult 1:5 proportions,
full body, hands at sides, 124×124 character sprite, 8-direction idle.

NEGATIVE: detailed, shaded, gradient, anime, chibi, cute, big head,
decorative, fantasy, realistic, 3D, held objects, facial expressions,
satirical caricature
```

### D1. Smoking junior lawyer (`smokers_lawyer_ch1`)

```
USE SHARED STYLE + NEGATIVE.

Late-20s male, slim build, slightly slouched posture as if leaning
against an invisible wall. Off-the-rack navy suit #1c2a40, parchment
shirt #e8e4d8 with the collar slightly open, no tie. Dark short hair
#1a1410. Light skin #e6b08a. One thin grey vape pen attached to the
lower lip as a body prop — NOT held in hand. Hands tucked into
trouser pockets.

8-direction idle only (no walk).

SAVE AS folder: godot/art/sprites/smokers_lawyer_ch1/idle/
with camera-relative filenames: front.png, back.png, left.png,
right.png, front_left.png, front_right.png, back_left.png,
back_right.png. Save prompt + seed to PROMPT.txt in that folder.
```

### D2. Elderly tram-waiter (`tram_waiter_ch1`)

```
USE SHARED STYLE + NEGATIVE.

Late-60s female, wide build, slightly stooped posture with weight on
the left foot. Long winter coat in eggplant #5a2a4a. Plaster grey
hair #9a9088 pulled back under a faded mint headscarf #88b0a0. Warm
skin #e6b08a. A bulky tote bag #6a4a30 attached as a body prop hanging
from the right shoulder — NOT held in hand, just slung across the
body. Hands at sides.

8-direction idle only (no walk).

SAVE AS folder: godot/art/sprites/tram_waiter_ch1/idle/
with camera-relative filenames.
```

### D3. Mail carrier (`mail_carrier_ch1`) — idle + 4-cardinal walk

```
USE SHARED STYLE + NEGATIVE.

Mid-30s male, average build, brisk posture with slight forward lean.
Bright cheap-gold jacket #e8c840 with navy trim #1c2a40 on the cuffs
and collar — recognisably postal worker uniform but no readable logo
text. Navy trousers #1c2a40. Dark short hair #1a1410. Warm skin
#e6b08a. A walnut messenger bag #6a4a30 attached as a body prop
crossing the torso diagonally — NOT held in hand. Hands at sides.

Generate 8-direction idle. ALSO generate 4-cardinal walk
(front, back, left, right) — 6 frames each.

SAVE AS folders:
  godot/art/sprites/mail_carrier_ch1/idle/ (8 directions, 1 frame each)
  godot/art/sprites/mail_carrier_ch1/walk/front/ (6 frames: 00–05)
  godot/art/sprites/mail_carrier_ch1/walk/back/  (6 frames)
  godot/art/sprites/mail_carrier_ch1/walk/left/  (6 frames)
  godot/art/sprites/mail_carrier_ch1/walk/right/ (6 frames)
```

### D4. Residential-route blocker (`route_blocker_residential_ch1`)

```
USE SHARED STYLE + NEGATIVE.

Mid-50s male, slight gut, posture: arms crossed across the chest.
Faded mustard city-worker overalls #c8a868 over a grey under-shirt
#9a9088. Plaster grey cap #9a9088. Warm skin #e6b08a, weathered
features (no facial detail, just silhouette). A clipboard #b89868
tucked under the left arm as a body prop — NOT held in hand. Stance
is stationary, slightly weary.

8-direction idle only (no walk).

SAVE AS folder: godot/art/sprites/route_blocker_residential_ch1/idle/
with camera-relative filenames.
```

### D5. Business-district route blocker (`route_blocker_business_ch1`)

```
USE SHARED STYLE + NEGATIVE.

Late-30s male, broad build, rigid posture with slight chest-out.
Sharp dark suit #1a1410, white shirt #e8e4d8, oxblood tie #7a1f2a.
Dark short hair #1a1410. Light skin #e6b08a. Small earpiece coil
#3a3838 attached at the right ear as a body prop. Hands at sides,
slightly closed fists. The silhouette must read "private-sector
security" at a glance — broad shoulders, narrow waist, suit fits
tight.

8-direction idle only (no walk).

SAVE AS folder: godot/art/sprites/route_blocker_business_ch1/idle/
with camera-relative filenames.
```

---

## After every Pixellab session

1. Save the prompt and seed to `PROMPT.txt` next to the output PNG (project rule per CONVENTIONS §"World sprite generation rules").
2. Open the project in the Godot editor once so the .import sidecars generate automatically.
3. Verify the PNG dimensions match the spec (file → Get Info on macOS, or `file <path>` on the shell).
4. If a generation comes back wrong, retry with the same prompt and a different seed before rewriting the prompt — most failures are seed luck, not prompt problems.

## Already done — do NOT regenerate

These exist in canonical paths already and should not be redone:

- `art/props/pig_swine_sign.png` (was `P&S_logo_wooden_board.png`) — English subtitle ✓
- `art/props/17tram.png` — English destination "17 SĄD REJONOWY" → **needs an English re-roll** to read "17 DISTRICT COURT" once you confirm; the current carriage works as v0
- `art/props/bollard.png` — single sprite ✓
- `art/props/_street_split/tram_rails_*.png` (6 cells) — split from contact sheet
- `art/props/_street_split/catenary_pole_*.png` (16 cells) — pick the cleanest, delete the rest
- `art/props/_street_split/curb_edge_*.png` (16 cells) — pick the cleanest, delete the rest
- `art/tiles/Warsaw_city_street.png`, `Warsaw_city_sidewalk.png`, `Warsaw_city_sidewalk_tile.png` — used as TileSet sources
