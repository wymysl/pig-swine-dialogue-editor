# Pixellab Catalogue — Pig & Swine Office Interior

Coherent prop catalogue for the Pig & Swine main office in Warsaw. Prompts follow the same grammar as the existing character `_pixellab_metadata.json` files: descriptor, then `16-bit JRPG`, then `pallette:` hex list. Reuse the cast palette so props sit next to existing sprites without color clash.

## Generation parameters (apply to all entries unless overridden)

- View: `low top-down` (matches existing cast)
- Directions: `1` (static props, no rotations)
- Template: none (Pixellab freeform sprite, not the mannequin template)
- Outline: thin dark
- Shading: basic
- Detail: medium

## Master palette (extended from cast files)

```
#1a1410  near-black (deep shadow)
#0d0a08  deepest black (outline)
#e8e4d8  off-white (paper, shirts, walls)
#1c2a40  navy (suit, ledger spines)
#7a1f2a  oxblood (ties, ribbon, accents)
#6a4a30  warm wood (medium)
#d4b878  light wood / pale oak
#c8a868  mustard / brass / dying foliage
#5a2a4a  eggplant (Wymysl accent, occasional upholstery)
#e6b08a  warm cream (skin / paper highlight)
#f0c8c0  pig pink (decorative texture, never on furniture)
```

When a prop needs a color outside this list (e.g. faded green for the fern), I add it explicitly in the per-prompt palette and keep the addition minimal.

---

## Tier A — Canonical visual jokes (Design Bible §6)

These five must look unmistakable. Each is tagged in canon and has narrative weight.

### A1. The unwatered fern

```
Sad neglected office fern in a chipped terracotta pot, half the fronds curled brown and crispy, the rest a tired faded green, soil dry and cracked, single yellowed leaf hanging limp over the rim, slightly dusty, NOT a healthy plant, comic decay, isolated prop on transparent background, 16-bit JRPG, pallette: #6a4a30, #c8a868, #4a5a3a, #2a3a2a, #1a1410, #0d0a08
```
Size: 64×80. View: low top-down.

### A2. The calendar two years out of date

```
Cheap office wall calendar hanging slightly crooked from a single nail, large month header reading "MARZEC 2024", small grid of date squares below, one date circled in red ballpoint pen, slightly yellowed paper, dog-eared lower corner, faded photo of a generic Warsaw skyline above the date grid, the year clearly outdated, isolated prop on transparent background, 16-bit JRPG, pallette: #e8e4d8, #c8a868, #7a1f2a, #1c2a40, #6a4a30, #1a1410, #0d0a08
```
Size: 48×64. View: front (wall-mounted, no top-down distortion).

### A3. The creaky chair (Mr. Pig's office chair)

```
Worn dark-stained wooden swivel office chair with cracked oxblood leather seat cushion sagging in the middle, one armrest slightly lower than the other, brass tack trim coming loose along the back, scuffed wooden legs, visibly tired furniture that would creak under any weight, comic age, NOT pristine, isolated prop on transparent background, 16-bit JRPG, pallette: #7a1f2a, #6a4a30, #d4b878, #c8a868, #1a1410, #0d0a08
```
Size: 64×96. View: low top-down.

### A4. The sentient resentful coffee machine

```
Old battered chrome-and-black countertop espresso machine with cracked plastic drip tray, single dirty glass carafe stained with old coffee rings, an amber indicator light glowing slightly too brightly, faint coffee stains around the base, one button missing its label, vaguely menacing presence, the kind of appliance that judges you, isolated prop on transparent background, 16-bit JRPG, pallette: #1a1410, #6a4a30, #d4b878, #c8a868, #e8e4d8, #7a1f2a, #0d0a08
```
Size: 64×80. View: low top-down.

### A5. The aggrieved office printer (NOT the Ch. 5 industrial printer)

```
Beige cream-colored mid-1990s laser office printer (small desktop unit, NOT industrial), paper tray slightly ajar with one crumpled sheet sticking out at a wrong angle, blinking amber error light, tiny LCD panel showing two cryptic characters, dust along the top edge, faintly yellowed casing, comic resignation, the printer has feelings and they are bad, isolated prop on transparent background, 16-bit JRPG, pallette: #e8e4d8, #c8a868, #1a1410, #7a1f2a, #d4b878, #0d0a08
```
Size: 80×64. View: low top-down.

---

## Tier B — Cast desks and structural furniture

Every desk should read as the person who works there. Use the cast member's accent color where it would plausibly migrate onto their workspace.

### B1. Mr. Pig's desk (panic-cluttered)

```
Dark walnut partner's desk piled with overlapping legal folders, three coffee mugs in various states of fullness, a brass banker's lamp tilted at an angle, an open accounts ledger with red ink visible in the margins, a half-eaten kanapka on a small plate, scattered yellow Post-it notes around a tilted desktop calendar, the chaos of a man currently in the pre-paperwork screaming phase, full prop on transparent background, 16-bit JRPG, pallette: #6a4a30, #d4b878, #e8e4d8, #1c2a40, #7a1f2a, #c8a868, #1a1410, #0d0a08
```
Size: 128×96. View: low top-down.

### B2. Mr. Swine's desk (mostly empty, ostentatious)

```
Polished dark mahogany desk with almost nothing on it, a single crystal-cut tumbler, a leather-bound desk pad, an expensive fountain pen resting in a brass holder, one foreign-looking postcard placed deliberately at the corner, suspiciously clean compared to the rest of the office, the desk of a partner who is rarely here, full prop on transparent background, 16-bit JRPG, pallette: #1a1410, #6a4a30, #c8a868, #e8e4d8, #7a1f2a, #d4b878, #0d0a08
```
Size: 128×96. View: low top-down.

### B3. Muraś's archival desk (paper-organized)

```
Plain warm-brown wooden desk neatly stacked with three vertical piles of cream-colored case folders tied with thin string, a small green-shaded lamp, a wooden index-card box with handwritten tabs visible, a single open ledger with neat ink columns, fountain pen resting in an ink stain, no clutter, the desk of an archivist who knows where everything is, full prop on transparent background, 16-bit JRPG, pallette: #6a4a30, #d4b878, #e8e4d8, #4a5a3a, #1c2a40, #1a1410, #0d0a08
```
Size: 128×96. View: low top-down.

### B4. Rak's corner desk (minimalist investigator)

```
Small spartan dark-wood desk with only a closed black notebook, a sharpened pencil, a half-drunk glass of water, and a single manila envelope placed face-down, no decoration, no photographs, faint scuff marks where the same elbow has rested for years, full prop on transparent background, 16-bit JRPG, pallette: #1a1410, #6a4a30, #e8e4d8, #c8a868, #0d0a08
```
Size: 96×80. View: low top-down.

### B5. Wymysl's desk (theatrical clutter)

```
Eggplant-velvet-draped wooden desk strewn with loose handwritten pages covered in elaborate flourishes, an ornate brass inkwell with a quill resting beside it (alongside a perfectly ordinary modern ballpoint), a single dramatic candlestick (unlit), a small leather-bound book of quotations open to a marked page, a coffee cup with a saucer, a mustard-yellow silk pocket square draped carelessly over one corner, full prop on transparent background, 16-bit JRPG, pallette: #5a2a4a, #c8a868, #6a4a30, #e8e4d8, #1a1410, #7a1f2a, #0d0a08
```
Size: 128×96. View: low top-down.

### B6. Dr. Kula's desk (new junior, sparse)

```
Plain light-oak desk with a freshly-issued bar association handbook still in its plastic wrapper, a brand-new black notebook with one pen clipped to it, a single small framed photograph turned face-down, a glass of water, a folded copy of Dziennik Ustaw, the desk of someone who started this week, full prop on transparent background, 16-bit JRPG, pallette: #d4b878, #e8e4d8, #1c2a40, #1a1410, #7a1f2a, #0d0a08
```
Size: 112×80. View: low top-down.

### B7. Asia's reception desk

```
Light-oak reception counter with a beige rotary-style office telephone, a stack of incoming mail in a wire tray, a small mustard knit cardigan draped over the chair back, an open appointment book with handwritten entries, a desktop calendar (correct year), a small ceramic mug of tea with a teabag tag hanging out, the workstation of an overworked but cheerful secretary, full prop on transparent background, 16-bit JRPG, pallette: #d4b878, #c8a868, #e8e4d8, #1c2a40, #6a4a30, #1a1410, #0d0a08
```
Size: 144×96. View: low top-down.

### B8. Battered metal filing cabinet

```
Tall four-drawer beige metal office filing cabinet with chipped paint along the edges, one drawer slightly ajar with manila folder tabs poking out, a small dent above the lower drawer, a faded handwritten paper label slipped into the second drawer's label holder, slightly yellowed with age, isolated prop on transparent background, 16-bit JRPG, pallette: #e8e4d8, #c8a868, #6a4a30, #1a1410, #0d0a08
```
Size: 64×112. View: low top-down.

### B9. Wooden bookshelf of legal codes

```
Tall dark-stained oak bookshelf packed tightly with cloth-bound legal volumes, navy and oxblood and dark-green spines with gold lettering reading abbreviations like KPC KPK KPA KC, several volumes leaning, two cream-colored case folders wedged horizontally on top of an upright row, a small empty space on one shelf where a volume is missing, isolated prop on transparent background, 16-bit JRPG, pallette: #6a4a30, #1c2a40, #7a1f2a, #4a5a3a, #c8a868, #d4b878, #e8e4d8, #1a1410, #0d0a08
```
Size: 96×144. View: low top-down.

### B10. Stack of archive boxes

```
Three cardboard archive boxes stacked unevenly, each with a handwritten Polish label in faded ink (the topmost reading "AKTA 2018-2019"), brown packing twine still tied around the middle box, slightly dusty, one corner crumpled, the kind of stack nobody has touched in three years, isolated prop on transparent background, 16-bit JRPG, pallette: #c8a868, #6a4a30, #e8e4d8, #1a1410, #0d0a08
```
Size: 80×96. View: low top-down.

---

## Tier C — Supporting clutter

Smaller props for set dressing. Each is generic enough to repeat across rooms.

### C1. Manila case folder (closed, tied)

```
Single cream-colored manila legal case folder closed and tied shut with thin oxblood string, slightly bulging with papers inside, faint coffee ring stain on the cover, a handwritten case reference number in the upper right, isolated prop on transparent background, 16-bit JRPG, pallette: #e8e4d8, #c8a868, #7a1f2a, #1a1410, #0d0a08
```
Size: 48×32. View: low top-down.

### C2. Stack of loose papers

```
Loose untidy stack of typed legal-size pages slightly fanned, a few sheets out of alignment, top page showing dense paragraphs of Polish text and a stamped impression in the corner, isolated prop on transparent background, 16-bit JRPG, pallette: #e8e4d8, #1a1410, #7a1f2a, #0d0a08
```
Size: 48×40. View: low top-down.

### C3. Chipped oxblood ceramic mug

```
Chipped deep-oxblood ceramic coffee mug with a faded gold rim, one chip missing from the lip, faint stain visible inside, half-full of dark coffee, isolated prop on transparent background, 16-bit JRPG, pallette: #7a1f2a, #1a1410, #c8a868, #6a4a30, #0d0a08
```
Size: 32×40. View: low top-down.

### C4. Wooden coat stand

```
Tall dark-walnut coat stand with brass hooks, one rumpled navy suit jacket hanging slightly askew, a forgotten scarf draped over a lower hook, a single black umbrella leaning at the base, isolated prop on transparent background, 16-bit JRPG, pallette: #6a4a30, #1c2a40, #c8a868, #1a1410, #0d0a08
```
Size: 48×128. View: low top-down.

### C5. Office door with frosted-glass panel

```
Dark wooden interior office door with a large frosted-glass upper panel, the words "PIG & SWINE — KANCELARIA ADWOKACKA" painted in faded gold serif lettering on the glass, a brass doorknob slightly tarnished, a small brass nameplate slot below the lettering, slightly worn around the handle, isolated prop on transparent background, 16-bit JRPG, pallette: #6a4a30, #d4b878, #c8a868, #e8e4d8, #1a1410, #0d0a08
```
Size: 80×144. View: front.

### C6. Tilted framed bar-admission certificate

```
Framed certificate hanging slightly crooked on the wall, ornate cream parchment with elaborate Polish legal-association lettering and a red wax seal, dark wooden frame with one corner chipped, slightly dusty glass, isolated prop on transparent background, 16-bit JRPG, pallette: #e8e4d8, #c8a868, #7a1f2a, #6a4a30, #1a1410, #0d0a08
```
Size: 56×72. View: front.

### C7. Wall clock (slightly off time)

```
Round dark-wood-rimmed wall clock with a cream face, black Roman numerals, brass hands pointing to a slightly improbable time, a faint hairline crack across the glass, the second hand visibly tilted, isolated prop on transparent background, 16-bit JRPG, pallette: #6a4a30, #e8e4d8, #1a1410, #c8a868, #0d0a08
```
Size: 56×56. View: front.

### C8. Brass banker's desk lamp

```
Classic banker's-style desk lamp with a green glass shade, brass column and pull-chain, a small dent in one side of the shade, casting a warm pool of yellow light, isolated prop on transparent background, 16-bit JRPG, pallette: #4a5a3a, #c8a868, #6a4a30, #e8e4d8, #1a1410, #0d0a08
```
Size: 48×64. View: low top-down.

### C9. Overflowing paper trash bin

```
Small dark metal office trash bin overflowing with crumpled cream-colored paper sheets, one balled-up draft visibly stamped "ODRZUCONO" peeking from the top, a coffee-stained envelope wedged down one side, isolated prop on transparent background, 16-bit JRPG, pallette: #1a1410, #e8e4d8, #c8a868, #7a1f2a, #0d0a08
```
Size: 48×56. View: low top-down.

### C10. Window with Warsaw skyline

```
Tall sash office window with peeling cream-painted wooden frame, a small condensation streak in one corner, a forgotten dust-coated potted geranium on the sill, glimpse beyond of grey-brown communist-era apartment block silhouettes against a flat overcast sky, isolated prop on transparent background, 16-bit JRPG, pallette: #e8e4d8, #c8a868, #6a4a30, #1c2a40, #7a1f2a, #1a1410, #0d0a08
```
Size: 96×144. View: front.

---

## Notes for placement

- The Tier A items must all be visible from the player's first overworld view of the office; they carry the room's identity.
- Mr. Swine's desk should sit visually furthest from the door — the partner who is rarely here. Mr. Pig's should be closest, intercepting clients.
- Muraś's desk should anchor the archive corner; pair with B9 (bookshelf) and B10 (archive boxes).
- Rak's corner is opposite the window. He prefers shadow.
- Wymysl's desk should be near the coat stand; he announces himself on entry.
- Asia's reception desk faces the door. The fern lives on its corner.
- The coffee machine and printer should be on opposite sides of the room. They are not friends.
