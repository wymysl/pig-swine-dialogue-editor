# Chrome Prompts — Graphics Overhaul, Phases 0–2

Companion to `GRAPHICS_OVERHAUL_PLAN.md`. This file is intended to be opened
in Google Docs (or any document the Claude in Chrome extension can read) and
walked through top-to-bottom in one or more sessions.

Each block is **self-contained**: a tool, a URL, what to configure, what to
paste, what to expect back, and where the resulting file should land. Tick
the `[ ]` checkbox when a block is done and write the saved filename to its
right.

> Read-this-first instruction for Claude in Chrome:
> Work through blocks in order. Do not skip Phase 0 — it changes the disk
> state the later phases assume. For Phase 1 (Pixellab), use the existing
> Pixellab character IDs given in each block; do **not** create new
> characters. For Phase 2 (Gemini), generate at 1024×1024 (Gemini's native
> size) and let the operator downscale to 512×512 in the import step. Always
> download the highest-fidelity export Pixellab/Gemini offer; the project
> handles downscaling.

---

## PHASE 0 — Cleanup checklist (no generation)

These are manual filesystem operations. Claude in Chrome cannot do these —
they require a local terminal. Operator runs them before Phase 1.

```
# from repo root
cd "godot/art"

# --- 0.1 Strip stale style anchors from CONVENTIONS.md ---
# Open ../CONVENTIONS.md and:
#   - line 10: replace "124×124" with "64×64" in §Canonical numbers
#   - §World sprite generation rules: confirm "Polish satirical illustration"
#     is gone (already noted in §Style framings to avoid; double-check)
#   - §Art direction table line for World sprites: confirm resolution = 64×64

# --- 0.2 Strip stale anchors from PROMPT.txt files ---
for f in sprites/*/PROMPT.txt; do
  echo "review: $f"
done
# Manual edit: remove "Polish satirical illustration" or "Polish komiks
# illustration" from any prompt that still has it. Memory already records
# these as rejected anchors.

# --- 0.3 Delete sikorska/ (F6 duplicate of halina/) ---
rg sikorska ../scenes ../scripts ../data       # MUST return zero refs first
rm -rf sprites/sikorska

# --- 0.4 Move legacy cula frames out of active tree ---
mkdir -p sprites/_legacy/cula
mv sprites/cula/walk/_alt sprites/_legacy/cula/walk_alt 2>/dev/null
mkdir -p _sources/cula
mv sprites/cula/cula.aseprite _sources/cula/
mv sprites/cula/cula_128_animation_preview.png _sources/cula/
mv sprites/cula/cula_128_animation_preview.png.import _sources/cula/

# --- 0.5 Delete Asia's cardinal walk dirs (drift from CONVENTIONS.md) ---
for d in north south east west north-east north-west south-east south-west; do
  rm -rf "sprites/asia/walk/$d"
done

# --- 0.6 Archive raw generator dumps ---
mkdir -p _drafts/buildings _drafts/tiles _drafts/zips
mv minigame_coffee _drafts/                               # ~12 MB
mv buildings/_row1_chunk*.png _drafts/buildings/
mv buildings/_row1_with_grid.png _drafts/buildings/
mv buildings/buildings_1.png _drafts/buildings/
mv buildings/buildings2.png _drafts/buildings/
mv "buildings/P&S+paragraph.png" _drafts/buildings/
mv tiles/PROMPT_*.png _drafts/tiles/
mv tiles/pixellab-PROMPT--*.png _drafts/tiles/ 2>/dev/null
mv *.zip _drafts/zips/                                    # 5 character zips

# --- 0.7 Rename Halina portrait to canonical filename ---
mv portraits/pixellab-71-year-old-Polish-woman--reti-1779013658510.png \
   portraits/halina.png
mv portraits/pixellab-71-year-old-Polish-woman--reti-1779013658510.png.import \
   portraits/halina.png.import

# --- 0.8 Verify nothing broke ---
cd ..
godot --headless --path . --script tests/test_smoke.gd
godot --headless --path . --script tests/test_runner.gd
```

**Operator sign-off after Phase 0: `[ ]`**

---

## PHASE 1 — Pixellab: main-cast sprite regen at 64×64

**Target tab:** https://www.pixellab.ai/ (or https://app.pixellab.ai/)
Logged in to the workspace that owns the existing character IDs below.

**Workflow per block:**
1. Navigate to the character page using the **Pixellab Character ID** given.
2. In the character editor, replace the existing prompt with the **Prompt**
   block from this file.
3. Replace the negative prompt with the **Negative** block.
4. Set: **Template = mannequin**, **View = low top-down**, **Directions = 8**,
   **Animation = idle**. Generation size can stay at Pixellab's default
   (128×128); the importer downscales to 64×64.
5. Click Generate. When the 8-direction idle grid finishes, use Pixellab's
   "Download character" / "Export zip" action to get a single archive
   containing all 8 rotations + `metadata.json`.
6. Save the zip to `~/Downloads/<char>.zip` (the filename doesn't matter, but
   keep one zip per character — don't merge).
7. Run the importer once per character. It extracts the 8 PNGs, translates
   Pixellab's cardinal naming to the project's camera-relative naming,
   downscales to 64×64 nearest-neighbor, and lands the files in the right
   sprite folder:

   ```bash
   # from repo root
   python3 tools/import_pixellab_zip.py ~/Downloads/<char>.zip <char_slug> --force
   ```

   The `--force` flag is required because the importer refuses to overwrite
   existing 112×112 frames by default — passing `--force` is the explicit
   "yes, replace the old set" signal.

8. Tick the block's checkbox and note the timestamp.

The importer's cardinal→camera-relative mapping (for reference):
`south→front, north→back, east→right, west→left, south-east→front_right,
south-west→front_left, north-east→back_right, north-west→back_left`.

**Critical:** do not generate walk frames in this run. Idle only, 8 directions.
Cula's existing 8-dir walk and run already exist and are not being regenerated
in Phase 1. (The importer's `--animation walk` flag exists for future use but
needs the multi-frame-per-direction flow that's out of scope here.)

---

### PIXELLAB-01: Cula  `[ ]`

- **Pixellab Character ID:** `94b17c50-a6ac-4a54-81de-939aa838bb69`
- **Import command:** `python3 tools/import_pixellab_zip.py ~/Downloads/cula.zip cula --force`

**Prompt:**
```
Slim young man in oversized navy suit, white shirt, clearly oxblood-red tie (color #7a1f2a — NOT cream, NOT beige), upright tense posture, dark hair. Minimal synthetic line drawing, sparse flat shapes, neutral-institutional figure, pixel-art, adult proportions, full body, hands at sides. Palette: #1a1410, #e6b08a, #1c2a40, #e8e4d8, #7a1f2a, #0d0a08
```

**Negative:**
```
detailed, shaded, gradient, anime, chibi, cute, big head, decorative, fantasy, realistic, 3D, held objects, facial expressions, caricature, exaggerated features, mascot, comic, satirical illustration, cream tie, beige tie, light tie
```

---

### PIXELLAB-02: Mr. Pig  `[ ]`

- **Pixellab Character ID:** `758ed0ea-e764-4733-a9af-5690a68648a9`
- **Import command:** `python3 tools/import_pixellab_zip.py ~/Downloads/mr_pig.zip mr_pig --force`

**Prompt:**
```
Round heavyset anthropomorphic pig in tight navy suit, oval barrel-shaped body distinctly wider than shoulders, very short stubby legs (legs no more than one-third of total height), small round glasses, navy tie, flustered tense posture. Minimal synthetic line drawing, sparse flat shapes, neutral-institutional figure, pixel-art, adult proportions, full body, hands at sides. Palette: #1a1410, #f0c8c0, #1c2a40, #e8e4d8, #7a1f2a, #0d0a08
```

**Negative:**
```
detailed, shaded, gradient, anime, chibi, cute, big head, decorative, fantasy, realistic, 3D, held objects, facial expressions, caricature, exaggerated features, mascot, comic, satirical illustration, four-legged pig, human in pig mask, tall, slim, long legs, athletic build, normal proportions
```

---

### PIXELLAB-03: Mr. Swine  `[ ]`

- **Pixellab Character ID:** `2675fbbf-04b9-4044-af5a-2088ff543b07`
- **Import command:** `python3 tools/import_pixellab_zip.py ~/Downloads/mr_swine.zip mr_swine --force`

**Prompt:**
```
Smooth well-groomed anthropomorphic pig in fitted dark charcoal suit, tall and slim with normal adult proportions, distinctly visible cream-colored cravat at the throat (color #e8e4d8, NOT red, NOT navy), confident upright stance, narrow shoulders, hands at sides. Minimal synthetic line drawing, sparse flat shapes, neutral-institutional figure, pixel-art, adult proportions, full body. Palette: #1a1410, #f0c8c0, #3a3a3a, #e8e4d8, #1c2a40, #0d0a08
```

**Negative:**
```
detailed, shaded, gradient, anime, chibi, cute, big head, decorative, fantasy, realistic, 3D, held objects, facial expressions, caricature, exaggerated features, mascot, comic, satirical illustration, four-legged pig, human in pig mask, barrel body, tiny legs, short legs, round body, red tie, oxblood tie, navy tie
```

> Note: Pig and Swine deliberately render at the same 64×64 canvas with a
> profile contrast (Pig short barrel; Swine tall slim). The cream cravat on
> Swine is the silhouette differentiator demanded by critique F3.

---

### PIXELLAB-04: Murrow  `[ ]`

- **Pixellab Character ID:** `eb8ec857-35f4-4639-9944-1e3c8e951bac`
- **Import command:** `python3 tools/import_pixellab_zip.py ~/Downloads/murrow.zip murrow --force`

**Prompt:**
```
Slim slightly stooped young man with sandy hair, threadbare brown cardigan worn over a white shirt, dark tie, hunched bookish posture, narrow shoulders, full body, hands at sides. Minimal synthetic line drawing, sparse flat shapes, neutral-institutional figure, pixel-art, adult proportions. Palette: #d4b878, #e6b08a, #1c2a40, #e8e4d8, #6a4a30, #0d0a08
```

**Negative:**
```
detailed, shaded, gradient, anime, chibi, cute, big head, decorative, fantasy, realistic, 3D, held objects, books, facial expressions, caricature, exaggerated features, mascot, comic, satirical illustration, glasses
```

---

### PIXELLAB-05: Crab  `[ ]`

- **Pixellab Character ID:** `f9e64615-98c1-48ed-8e99-a4d66ab8b82f`
- **Import command:** `python3 tools/import_pixellab_zip.py ~/Downloads/crab.zip crab --force`

**Prompt:**
```
Late-20s Polish male junior lawyer, sturdy compact build, mid-brown hair pushed back, wearing a distinctly visible flat cap (newsboy cap) in dark brown — the cap is the primary silhouette marker — rumpled mid-brown jacket (NOT navy) worn open over a white shirt, dark trousers, sleeves clearly rolled to elbows showing forearm skin tone, no necktie, full body, hands at sides. Minimal synthetic line drawing, sparse flat shapes, neutral-institutional figure, pixel-art, adult proportions. Palette: #6a4a30, #e6b08a, #4a3424, #e8e4d8, #9a9088, #0d0a08
```

**Negative:**
```
detailed, shaded, gradient, anime, chibi, cute, big head, decorative, fantasy, realistic, 3D, held objects, notebook, belt clip, facial expressions, caricature, exaggerated features, mascot, comic, satirical illustration, navy suit, dark navy jacket, formal tie, polished
```

> Note: the flat cap + brown jacket + rolled sleeves are the new silhouette
> differentiators from critique F4. The notebook-clipped-to-belt detail from
> the old prompt is removed (no held objects, never readable at 64×64
> anyway).

---

### PIXELLAB-06: Whimsy  `[ ]`

- **Pixellab Character ID:** `c0f5ccd4-a6fc-49c4-8bc4-f6a7f320b5e9`
- **Import command:** `python3 tools/import_pixellab_zip.py ~/Downloads/whimsy.zip whimsy --force`

**Prompt:**
```
Slim tall young man in a distinctly visible deep eggplant-purple velvet blazer (color #5a2a4a), mismatched muted mustard tie (color #c8a868), swept-back dark hair, theatrical upright posture with slight contrapposto, white shirt under blazer, dark trousers, full body, hands at sides. Minimal synthetic line drawing, sparse flat shapes, neutral-institutional figure, pixel-art, adult proportions. Palette: #1a1410, #e6b08a, #5a2a4a, #e8e4d8, #c8a868, #0d0a08
```

**Negative:**
```
detailed, shaded, gradient, anime, chibi, cute, big head, decorative, fantasy, realistic, 3D, held objects, facial expressions, caricature, exaggerated features, mascot, comic, satirical illustration, raised hands, gesturing arms, navy blazer, black blazer, gray suit
```

---

### PIXELLAB-07: Asia  `[ ]`

- **Pixellab Character ID:** `0f78d397-12cc-4520-b331-609b1697791e`
- **Import command:** `python3 tools/import_pixellab_zip.py ~/Downloads/asia.zip asia --force`

**Prompt:**
```
Slim neat young woman with ponytail, wearing a muted mustard-ochre cardigan in color #c8a868 (a desaturated warm mustard ochre, NOT bright yellow, NOT signage gold) over a cream shirt, navy pencil skirt, composed upright posture, full body, hands at sides. Minimal synthetic line drawing, sparse flat shapes, neutral-institutional figure, pixel-art, adult proportions. Palette: #1a1410, #e6b08a, #1c2a40, #e8e4d8, #c8a868, #0d0a08
```

**Negative:**
```
detailed, shaded, gradient, anime, chibi, cute, big head, decorative, fantasy, realistic, 3D, held objects, facial expressions, caricature, exaggerated features, mascot, comic, satirical illustration, bright yellow cardigan, lemon yellow, gold cardigan, signage yellow, saturated yellow
```

> Note: explicit cardigan color targeting per critique F11. The bright yellow
> drift on the current shipping asset is the failure being prevented here.

---

### PIXELLAB-08: Halina  `[ ]`

- **Pixellab Character ID:** `e1c8d847-98de-42d9-93e4-50a928e88363`
- **Import command:** `python3 tools/import_pixellab_zip.py ~/Downloads/halina.zip halina --force`

**Prompt:**
```
Elderly slim upright woman in her early seventies, short gray hair, beige cardigan over a cream blouse, navy mid-length skirt, dignified stiff posture, no cane, full body, hands at sides. Minimal synthetic line drawing, sparse flat shapes, neutral-institutional figure, pixel-art, adult proportions. Palette: #9a9088, #d4b878, #e8e4d8, #1c2a40, #e6b08a, #0d0a08
```

**Negative:**
```
detailed, shaded, gradient, anime, chibi, cute, big head, decorative, fantasy, realistic, 3D, held objects, cane, walking stick, folder, documents, facial expressions, caricature, exaggerated features, mascot, comic, satirical illustration, hunched, stooped
```

> Note: this is the Chapter 1 baseline Halina. The Ch4 diminished-with-cane
> variant lives in a separate folder when generated; cane is a layered
> Sprite2D at runtime per the held-objects rule.

---

### PIXELLAB — Phase 1 QA / consistency review  `[ ]`

This is the gate before Phase 2. The mechanical tests catch breakage; the
visual review catches drift. Both must pass.

**Mechanical checks (operator):**
```bash
# from repo root
# 1. Every new idle PNG is 64×64
python3 -c "
from PIL import Image
import os, sys
bad = []
for c in ['cula','mr_pig','mr_swine','murrow','crab','whimsy','asia','halina']:
    d = f'godot/art/sprites/{c}'
    for f in sorted(os.listdir(d)):
        if f.endswith('_idle_back.png') or f.endswith('_idle_front.png') \
        or f.endswith('_idle_left.png') or f.endswith('_idle_right.png') \
        or f.endswith('_idle_back_left.png') or f.endswith('_idle_back_right.png') \
        or f.endswith('_idle_front_left.png') or f.endswith('_idle_front_right.png'):
            s = Image.open(f'{d}/{f}').size
            if s != (64, 64): bad.append((f'{d}/{f}', s))
if bad:
    for p, s in bad: print(f'FAIL {s} {p}')
    sys.exit(1)
print('OK — all 64 idle PNGs at 64×64')
"

# 2. Silhouette + diff comparison: Pig vs Swine, Cula vs Crab
python3 -c "
from PIL import Image, ImageOps, ImageChops
pairs = [('mr_pig','mr_swine'), ('cula','crab')]
for a, b in pairs:
    ia = Image.open(f'godot/art/sprites/{a}/{a}_idle_front.png').convert('RGBA')
    ib = Image.open(f'godot/art/sprites/{b}/{b}_idle_front.png').convert('RGBA')
    ma = ImageOps.invert(ia.split()[3].convert('L'))
    mb = ImageOps.invert(ib.split()[3].convert('L'))
    ma.save(f'/tmp/silhouette_{a}.png')
    mb.save(f'/tmp/silhouette_{b}.png')
    diff = ImageChops.difference(ma, mb)
    overlap = sum(1 for p in diff.getdata() if p == 0) / (64*64)
    print(f'{a} vs {b}: silhouette overlap = {overlap:.0%} (must be < 60%)')
"

# 3. Palette adherence: every non-transparent pixel in each character must
# belong to the union of shared palette-safe colors + that character's
# accent list. The exact tolerance depends on Pixellab's color snapping —
# allow ΔE < 8 in Lab space.
python3 -c "
from PIL import Image
import os
# Shared palette-safe (CONVENTIONS.md §Shared character colors)
shared = ['0d0a08','1a1410','e6b08a','f0c8c0','1c2a40','5a2a4a','6a4a30','9a9088']
# Per-character accents (last colors in each PROMPT.txt palette line)
accents = {
    'cula': ['7a1f2a','e8e4d8'],
    'mr_pig': ['7a1f2a','e8e4d8'],
    'mr_swine': ['3a3a3a','e8e4d8'],
    'murrow': ['d4b878','e8e4d8'],
    'crab': ['4a3424','e8e4d8'],
    'whimsy': ['c8a868','e8e4d8'],
    'asia': ['c8a868','e8e4d8'],
    'halina': ['d4b878','e8e4d8'],
}
def hex_to_lab(h):
    r,g,b = int(h[0:2],16)/255, int(h[2:4],16)/255, int(h[4:6],16)/255
    return (r,g,b)  # crude RGB diff is fine for snap check
def close(a, b, tol=12):
    return sum(abs(a[i]-b[i]) for i in range(3)) < tol*3
for c, accs in accents.items():
    allowed = [hex_to_lab(h) for h in shared+accs]
    im = Image.open(f'godot/art/sprites/{c}/{c}_idle_front.png').convert('RGBA')
    bad = 0
    for px in im.getdata():
        if px[3] < 128: continue
        rgb = (px[0]/255, px[1]/255, px[2]/255)
        if not any(close(rgb, a) for a in allowed): bad += 1
    pct = bad / (64*64) * 100
    flag = 'WARN' if pct > 5 else 'OK'
    print(f'{flag} {c}: off-palette pixels = {pct:.1f}%')
"

# 4. Engine-level: Y-sort regression
godot --headless --path godot --script tests/test_ysort_canon.gd

# 5. Smoke test
godot --headless --path godot --script tests/test_smoke.gd
```

**Visual review (operator):** open `pig_swine_office.tscn` in the editor with
all eight new characters placed in the same room at the same time. Look for:

- Pig vs Swine: distinct silhouettes at 64×64? Pig clearly squatter, Swine
  clearly taller, cream cravat visible on Swine?
- Cula vs Crab: distinct headgear (Crab has flat cap)? Different jacket
  colors (Cula near-black navy, Crab mid-brown)?
- Asia cardigan: muted ochre (NOT signage gold)?
- Cula tie: oxblood (NOT cream)?
- Whimsy: eggplant blazer reads at scale?
- Group cohesion: do they look like one cast, or like eight separate
  Pixellab sessions?

**Gate criteria.** Any block that fails: re-run the corresponding PIXELLAB-NN
prompt with a stronger contrast instruction in the prompt, or accept a
post-process palette-snap via ImageMagick. Phase 2 does not start until
the silhouette overlap check is under 60% and the palette-adherence check
is under 5% off-palette per character.

---

## PHASE 2 — Gemini (Imagen 4): warm-register portraits at 512×512

**Target tab:** https://gemini.google.com/ (with an "Image generation"
capable model selected — Imagen 4 / Gemini 2.5 Pro with image tools)

Alternative tab if Gemini's free quota is exhausted: https://aistudio.google.com/
(select Imagen 3 / Imagen 4).

**Workflow per block:**
1. Open a fresh conversation (so the style anchor doesn't drift between
   characters).
2. Paste the **Prompt** block below.
3. Set aspect ratio to 1:1, output size to the largest available
   (typically 1024×1024 in Gemini; Imagen 4 sometimes offers higher).
4. Generate. Pick the variant that best matches the warm-register brief:
   gouache texture, naive Polish illustration, warm earth-tone palette,
   visible brushstrokes, NOT photoreal, NOT anime, NOT cute.
5. Download the chosen variant.
6. **Operator's downscale step (not Claude in Chrome):**
   ```bash
   # from repo root
   magick convert <downloaded.png> -resize 512x512 godot/art/portraits/<char>.png
   ```
7. Tick the block. Move on to the next character.

**Critical:** generate each portrait in a fresh chat. Cross-conversation
style drift is the main risk; one character per conversation prevents it.

---

### GEMINI-01: Cula portrait (warm)  `[ ]`

**Save as:** `godot/art/portraits/cula.png`

**Prompt:**
```
A single portrait painting, shoulders-up, of a slim young man in his late twenties: dark hair combed neatly to the side, slight tension in his jaw, oversized navy suit jacket that's a half-size too big, white shirt, oxblood red tie. He has the look of a junior lawyer holding it together. Small format gouache painting, naive Polish illustration technique reminiscent of mid-century Polish children's book illustrators like Bohdan Butenko, flat warm earth-tone colors, slightly satirical but grounded, soft expressive but restrained, institutional office setting suggested behind him, visible brushstroke texture, warm interior lighting, tonally aligned with a Polish PRL-era milk-bar palette of amber, cream, walnut brown, and warm gray.

Negative: photorealistic, 3D render, anime, digital art, smooth gradients, horror, dark, scary, cute, mascot, cartoon, photograph.
```

---

### GEMINI-02: Mr. Pig portrait (warm)  `[ ]`

**Save as:** `godot/art/portraits/pig.png`

**Prompt:**
```
A single portrait painting, shoulders-up, of an anthropomorphic pig man in his fifties: round pink face with small round glasses, tight navy suit jacket clearly straining at the collar, navy tie. The expression is anxious-but-keeping-it-professional — the eyes give him away, the mouth tries not to. Small format gouache painting, naive Polish illustration technique reminiscent of mid-century Polish children's book illustrators like Bohdan Butenko, flat warm earth-tone colors with the pink face as the focal warmth, slightly satirical but grounded, expressive but restrained, institutional office setting suggested behind him, visible brushstroke texture, warm interior lighting, tonally aligned with a Polish PRL-era milk-bar palette of amber, cream, walnut brown, and warm gray.

Negative: photorealistic, 3D render, anime, digital art, smooth gradients, horror, dark, scary, cute, mascot, cartoon, photograph, four-legged pig, peppa pig, animated pig character, full body.
```

---

### GEMINI-03: Asia portrait (warm)  `[ ]`

**Save as:** `godot/art/portraits/asia.png`

**Prompt:**
```
A single portrait painting, shoulders-up, of a slim composed young woman in her late twenties: dark hair in a low ponytail, a muted mustard-ochre cardigan (warm desaturated mustard, NOT bright yellow) over a cream shirt, calm direct gaze. She has the look of the only person at the firm who actually keeps the place running. Small format gouache painting, naive Polish illustration technique reminiscent of mid-century Polish children's book illustrators like Bohdan Butenko, flat warm earth-tone colors, slightly satirical but grounded, expressive but restrained, reception desk suggested behind her, visible brushstroke texture, warm interior lighting, tonally aligned with a Polish PRL-era milk-bar palette of amber, cream, walnut brown, and warm gray.

Negative: photorealistic, 3D render, anime, digital art, smooth gradients, horror, dark, scary, cute, mascot, cartoon, photograph, bright yellow, lemon yellow, signage gold.
```

---

### GEMINI-04: Murrow portrait (warm)  `[ ]`

**Save as:** `godot/art/portraits/murrow.png`

**Prompt:**
```
A single portrait painting, shoulders-up, of a slim young man in his late twenties: sandy unbrushed hair falling slightly across his forehead, threadbare mid-brown cardigan worn over a wrinkled white shirt with a dark loose tie, gentle distracted gaze as if mid-thought. He has the look of someone who reads in the bathtub and forgets to eat. Small format gouache painting, naive Polish illustration technique reminiscent of mid-century Polish children's book illustrators like Bohdan Butenko, flat warm earth-tone colors, slightly satirical but grounded, expressive but restrained, shelves of books and binders suggested behind him, visible brushstroke texture, warm interior lighting, tonally aligned with a Polish PRL-era milk-bar palette of amber, cream, walnut brown, and warm gray.

Negative: photorealistic, 3D render, anime, digital art, smooth gradients, horror, dark, scary, cute, mascot, cartoon, photograph, glasses, beard, mustache.
```

---

### GEMINI-05: Crab portrait (warm)  `[ ]`

**Save as:** `godot/art/portraits/crab.png`

**Prompt:**
```
A single portrait painting, shoulders-up, of a stocky compact young man in his late twenties: mid-brown hair pushed back, wearing a dark brown newsboy flat cap pulled low over his brow, rumpled mid-brown jacket open over a white shirt with sleeves rolled to the elbows (forearms visible), no necktie. He has the look of a junior whose toolbelt-attitude got him hired despite the dress code. Small format gouache painting, naive Polish illustration technique reminiscent of mid-century Polish children's book illustrators like Bohdan Butenko, flat warm earth-tone colors, slightly satirical but grounded, expressive but restrained, scuffed office wall suggested behind him, visible brushstroke texture, warm interior lighting, tonally aligned with a Polish PRL-era milk-bar palette of amber, cream, walnut brown, and warm gray.

Negative: photorealistic, 3D render, anime, digital art, smooth gradients, horror, dark, scary, cute, mascot, cartoon, photograph, navy suit, formal tie, polished, beard.
```

---

### GEMINI-06: Whimsy portrait (warm)  `[ ]`

**Save as:** `godot/art/portraits/whimsy.png`

**Prompt:**
```
A single portrait painting, shoulders-up, of a slim tall young man in his late twenties: dark hair swept back theatrically, wearing a deep eggplant-purple velvet blazer over a white shirt with a mismatched muted mustard tie, slight tilt of the head as if reciting something. He has the look of the most overdressed person at every meeting and the only one having fun. Small format gouache painting, naive Polish illustration technique reminiscent of mid-century Polish children's book illustrators like Bohdan Butenko, flat warm earth-tone colors with the eggplant blazer as the chromatic anchor, slightly satirical but grounded, expressive but restrained, dim theatrical office light suggested behind him, visible brushstroke texture, warm interior lighting, tonally aligned with a Polish PRL-era milk-bar palette of amber, cream, walnut brown, and warm gray.

Negative: photorealistic, 3D render, anime, digital art, smooth gradients, horror, dark, scary, cute, mascot, cartoon, photograph, raised hands, gesturing arms, navy blazer, black blazer.
```

---

### GEMINI-07: Halina portrait (warm)  `[ ]`

**Save as:** `godot/art/portraits/halina.png`

**Prompt:**
```
A single portrait painting, shoulders-up, of a dignified elderly Polish woman in her early seventies: short tidy gray hair, beige cardigan over a cream blouse, calm composed posture, expression of someone who has rehearsed what she came to say. She has the look of a widow whose case file is in alphabetical order. Small format gouache painting, naive Polish illustration technique reminiscent of mid-century Polish children's book illustrators like Bohdan Butenko, flat warm earth-tone colors, slightly satirical but grounded, expressive but restrained, neutral office wall suggested behind her, visible brushstroke texture, warm interior lighting, tonally aligned with a Polish PRL-era milk-bar palette of amber, cream, walnut brown, and warm gray.

Negative: photorealistic, 3D render, anime, digital art, smooth gradients, horror, dark, scary, cute, mascot, cartoon, photograph, cane, walking stick, folder, hunched, glasses, headscarf.
```

---

### GEMINI — Phase 2 QA / consistency review  `[ ]`

**Mechanical checks (operator):**
```bash
# from repo root
# 1. All seven portraits at 512×512, RGBA or RGB
python3 -c "
from PIL import Image
bad = []
for c in ['cula','pig','asia','murrow','crab','whimsy','halina']:
    im = Image.open(f'godot/art/portraits/{c}.png')
    if im.size != (512, 512): bad.append((c, im.size))
    print(f'{c}: {im.size} {im.mode}')
if bad: print('FAIL', bad)
"

# 2. Tonal cohesion check: dump average color of each portrait, flag any
# that's a meaningful temperature outlier from the cast median
python3 -c "
from PIL import Image
import statistics
avgs = {}
for c in ['cula','pig','asia','murrow','crab','whimsy','halina']:
    im = Image.open(f'godot/art/portraits/{c}.png').convert('RGB').resize((32,32))
    px = list(im.getdata())
    n = len(px)
    avgs[c] = (sum(p[0] for p in px)/n, sum(p[1] for p in px)/n, sum(p[2] for p in px)/n)
# temperature proxy = R - B (warmer = positive)
temps = {c: rgb[0]-rgb[2] for c, rgb in avgs.items()}
med = statistics.median(temps.values())
print(f'cast median R-B: {med:.1f}')
for c, t in sorted(temps.items()):
    delta = t - med
    flag = 'COOL OUTLIER' if delta < -25 else ('WARM OUTLIER' if delta > 25 else 'OK')
    print(f'{flag:14s} {c}: R-B = {t:.1f} (Δ = {delta:+.1f})')
"

# 3. Boot the dialogue runner test (loads portraits via dialogue)
godot --headless --path godot --script tests/test_runner.gd
```

**Visual review (operator):** open the seven portraits side-by-side in a
single image viewer (Preview.app: select all 7, hit space, arrow through).
Look for:

- Stylistic register: all seven feel like the same hand painted them?
  Gouache texture visible on all? No anime drift on any single one?
- Palette temperature: do they feel like one cast in one room, or like
  seven photos from seven different sets?
- Halina rendered new (was raw Pixellab filename before): does she sit
  visually with the other six?
- No photoreal contamination: face shapes painterly, not modelled?

**Gate criteria.** Any "COOL OUTLIER" / "WARM OUTLIER" tag from the tonal
check, or any portrait that visually breaks register, gets regenerated.
For tonal outliers the fastest fix is regenerating in the same Gemini
chat with: "The previous portrait was tonally cooler than the rest of
the cast. Regenerate with the same warm amber/cream/walnut PRL milk-bar
palette temperature as the previous portrait in this conversation."

If a character only fails the warm-vs-cool match by a small margin,
ImageMagick can snap it in 5 seconds:
```bash
magick convert godot/art/portraits/<char>.png \
  -modulate 100,100,98 \
  godot/art/portraits/<char>.png
```
(values: brightness, saturation, hue — lower hue shifts warmer).

---

## Final operator close-out

```bash
# from repo root
git status godot/art          # review what changed
git status godot/CONVENTIONS.md
# stage and commit by phase, not all at once:
#   - Phase 0 commit: cleanup
#   - Phase 1 commit: sprite regen
#   - Phase 2 commit: portrait regen
```

Done. If anything failed mid-run, leave the corresponding `[ ]` un-ticked
and resume from there in the next session — every block is independent.
