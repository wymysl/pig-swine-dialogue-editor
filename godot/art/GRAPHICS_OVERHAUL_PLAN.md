# Graphics Overhaul Plan — Chapter 1 Uniformity Pass

Scope chosen: **Phases 0–2 only.** Cleanup, main-cast sprite regen at canonical
64×64, warm-register portrait regen at 512×512. Casebook cards, dark-register
portraits, district art, and building re-passes are out of scope for this run.

Companion file: `CHROME_PROMPTS.md` — the copy-paste prompts intended for the
Claude in Chrome extension. The audit work that justified the scope lives in
`critiques/2026-05-20-art.md` (F1–F14). This document is the operating plan,
not a second audit.

---

## Decisions locked

1. **Canonical character sprite size: 64×64.** This retires the 124×124 line at
   `CONVENTIONS.md §Canonical numbers`. It matches every per-character
   `PROMPT.txt`, the `§Y-sort and Sprite2D origin convention` math
   (`offset.y = -32`), `State.CHAR_HEIGHT = 64`, and `critiques/2026-05-20-art.md`
   F1. Pixellab generation workflow: render at 128×128, downscale
   nearest-neighbor to 64×64. Do not commit 128 sources.

2. **Tool routing.** Pixellab → all world sprites. Google Gemini (Imagen 4
   via `gemini.google.com`) → warm-register portraits. ChatGPT (GPT-image-1
   via `chatgpt.com`) reserved for the next phase (dark-register portraits and
   Casebook cards), not used in this run.

3. **Style anchor for world sprites.** "Minimal synthetic line drawing, sparse
   flat shapes, neutral-institutional figure, pixel-art, adult proportions,
   full body, hands at sides." Drop "Polish satirical illustration" and
   "Polish komiks illustration" everywhere they still appear. Drop
   named-Polish-illustrator anchors (Sieńczyk / Hydriola). The premise is
   satirical; the rendering is neutral-institutional. Auto-memory already
   records both rejections; the PROMPT.txt corpus has not been swept yet.

4. **Portrait register for this phase.** Warm only. The dialogue runtime
   currently loads one flat portrait per character (`art/portraits/%s.png`),
   so expression sets are blocked on code anyway. Generate single-portrait
   warm-register replacements at 512×512 source.

---

## Phase 0 — Cleanup (manual, ~30 min)

These are file-system operations, not generations. Do them before running any
Chrome prompts so the regenerated assets land into a clean tree. Each is a
prune candidate from `ART_PRODUCTION_PLAN.md §Prune Candidates`, the F6/F10
items from the critique, or what the current audit surfaced.

1. **Strip stale anchors from `CONVENTIONS.md`.** Replace line 10's "124×124"
   with "64×64". Strip "Polish satirical illustration" from §World sprite
   generation rules. Same for "Polish komiks illustration" if present.
2. **Strip stale anchors from every `art/sprites/<char>/PROMPT.txt`** so the
   next Pixellab run isn't pulled toward the rejected style. The prompts in
   `CHROME_PROMPTS.md` are already clean; this step is to update the
   stored canon.
3. **Delete `art/sprites/sikorska/`** (F6 — duplicate of `halina/`, ships only
   a `.tres` referencing no PNGs). Grep first: `rg sikorska godot/scenes godot/scripts godot/data`.
4. **Move legacy frames out of active trees:**
   - `art/sprites/cula/walk/_alt/` → `art/sprites/_legacy/cula/walk_alt/`
   - `art/sprites/cula/cula.aseprite` and `cula_128_animation_preview.png`
     → `art/_sources/cula/` (create the directory)
   - Same hygiene for `asia/`, `crab/` if they hold `.aseprite` at top level
5. **Delete Asia's redundant cardinal walk folders:**
   `north/`, `south/`, `east/`, `west/`, `north-east/`, `north-west/`,
   `south-east/`, `south-west/`. Keep only the eight camera-relative folders
   (`front`, `back`, `left`, `right`, `front_left`, `front_right`,
   `back_left`, `back_right`). Per `CONVENTIONS.md §Walk-folder naming convention`.
6. **Archive raw generator dumps** (no `git rm` yet — move to `art/_drafts/`):
   - `art/minigame_coffee/` (~12 MB, JPEGs-as-PNG, unreferenced; shipping
     versions are already in `art/minigames/coffee/`)
   - `art/buildings/_row1_chunk0.png`, `_row1_chunk1.png`, `_row1_chunk2.png`,
     `_row1_with_grid.png`, `buildings_1.png`, `buildings2.png`,
     `P&S+paragraph.png` (~9 MB of unreferenced drafts)
   - `art/tiles/PROMPT_*.png` (5 files with raw-prompt filenames)
   - `art/tiles/pixellab-PROMPT--16-48-pixel-art-prop-o-1779096304605.png`
   - The five `.zip` files at `art/` root
     (`mail_charrier_ch1.zip`, `route_blocker_*.zip`, `smokers_lawyer_ch1.zip`,
     `tram_waiter_ch1.zip`) — extract if needed, then archive
7. **Rename `art/portraits/pixellab-71-year-old-Polish-woman--reti-1779013658510.png`
   to `art/portraits/halina.png`.** Confirms the canonical filename the
   DialogueRunner expects when `speaker == "halina"`.

When this is done, run the smoke + runner tests:
```bash
godot --headless --path godot --script tests/test_smoke.gd
godot --headless --path godot --script tests/test_runner.gd
```
to make sure nothing referenced what was moved.

---

## Phase 1 — Pixellab: main-cast sprite regen at 64×64

Eight characters, eight directions of idle each. Prompts pre-written in
`CHROME_PROMPTS.md §Pixellab`. Each prompt:

- targets the existing Pixellab character ID from `PROMPT.txt`
- uses the new style anchor (neutral-institutional, no "satirical")
- bakes in the silhouette differentiators the critique demanded
  (F3 — Pig wider body + shorter legs; Swine cream cravat;
  F4 — Crab flat cap or rolled-sleeves baked block;
  F11 — Asia cardigan explicitly `#c8a868`, not signage yellow;
  F12 — Cula tie explicitly `#7a1f2a` oxblood)
- generates at 128×128, downscales to 64×64 in Pixellab's export, idle 8-dir

NPC walk frames stay deferred — only Cula needs locomotion, per
`ART_PRODUCTION_PLAN §Cheapest Viable Strategy` rule 3. Asia walk frames
already exist at 112×112 and will need their own regen pass once the
core cast is done.

Save naming: `art/sprites/<char>/<char>_idle_<direction>.png`, replacing the
existing 112×112 or 124×124 files in place. Don't delete the old ones until
the new set imports clean in Godot.

---

## Phase 2 — Gemini: warm-register portrait regen at 512×512

Seven portraits: the six main cast (Cula, Mr. Pig, Asia, Murrow, Crab, Whimsy)
plus Halina. Prompts pre-written in `CHROME_PROMPTS.md §Gemini`. Each prompt:

- uses the warm-register style anchor from `CONVENTIONS.md §Portrait generation rules`
- references the character's per-PROMPT.txt palette swatches
- specifies "single portrait, neutral expression, shoulders-up framing"
  (since the runtime only loads one flat portrait per character)
- targets 512×512 source size

Save naming: `art/portraits/<char>.png`. Existing 200×200 portraits get
overwritten; the dialogue UI will scale at runtime.

---

## What this run does not touch

- **Building elevations.** F8 (archive_room and cafe_paragraf as flat
  rectangles) is a tilemap/scene-architecture problem, not a generation
  problem. Listed for the next sprint, not for Chrome to fix.
- **Dark-register portraits.** Pig panic, Judge, Halina memory — these need
  ChatGPT GPT-image with detailed Waliszewska briefing. Phase 3+.
- **Casebook cards.** Blocked on Casebook engine and per-judgment IDs being
  finalized.
- **Minor NPC sprites** (`mail_carrier_ch1`, `route_blocker_*`, `smokers_lawyer_ch1`,
  `tram_waiter_ch1`). Per F5 critique they need a held-objects audit and
  potentially Pixellab cannot satisfy the no-bag constraint — handle in a
  dedicated pass after the main cast lands.
- **Prop size audit** (F14). Wall calendar, clock, etc. are over-scaled
  relative to characters. Fixable in `.import` `size_override` without
  regeneration; do it once the 64×64 cast lands so the relative scale check
  works against real frames.

---

## How to run this with Claude in Chrome

1. Open `CHROME_PROMPTS.md` in Google Docs (or any tab Claude in Chrome can
   read).
2. Open three browser tabs in parallel: `pixellab.ai` (logged in),
   `gemini.google.com` (logged in to a workspace where Imagen image-gen is
   enabled), and a downloads window pinned to a folder you'll move files from.
3. Hand Claude in Chrome the prompts file and tell it: "Work through this top
   to bottom. Each block specifies which tab to act in, what to paste, what
   settings to configure, and where the downloaded file should land. When you
   hit a `[ ]` checkbox, run that prompt; when complete, write the resulting
   filename next to the checkbox."
4. Each prompt block is self-contained — you can stop and resume at any
   checkbox without losing context.

When the run finishes, do the import + verification pass yourself:

```bash
# from project root
godot --headless --path godot --script tests/test_smoke.gd
godot --headless --path godot --script tests/test_ysort_canon.gd
python tools/voice_audit.py godot/data/voice_references/   # unrelated; sanity
```

If `test_ysort_canon.gd` fails after the new 64×64 frames land, the offset
math in scenes still references the old 112×112 frames. Update offsets per
`CONVENTIONS.md §Y-sort` (`offset.y = -32` for 64×64 characters).

---

## Open follow-ups (not part of this run)

- Add `tests/test_sprite_dims.gd` per critique F1: assert every PNG under
  `art/sprites/<character>/` matches the declared 64×64.
- Add `tests/test_palette_snapped.gd` per critique F12: assert non-transparent
  pixels of each character sprite belong to the union of shared palette-safe
  colors plus that character's accent list.
- After the main-cast regen lands, do the minor-NPC audit and the building
  re-pass as a single chapter-1-environments sprint.
