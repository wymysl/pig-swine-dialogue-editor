# Art Production Plan

This is the cost-efficient art plan for the current Godot build. It turns the
project's existing art direction into a production order: ship the smallest
useful set for the next playable chapter, reuse it aggressively, and avoid
large generation passes until the runtime can display the result.

## Cheapest Viable Strategy

1. Build art chapter-first, not game-wide.
   Chapter 1 owns the current art budget. Do not generate Chapter 2-6
   districts, portraits, case cards, or props until the chapter that needs them
   is the next shippable target.

2. Use the hybrid style where it saves work.
   Pixel art is for world traversal, props, item icons, tiles, and UI chrome.
   Illustrated art is for dialogue portraits and Casebook cards. This matches
   `style_canon.txt`: generators are better at expressive portrait paintings
   than at consistent pixel animation.

3. Only the player needs expensive movement animation by default.
   Dr. A. Cula needs 8-direction idle, walk, and run. Most NPCs can ship with
   8-direction idle only, and only receive 4-cardinal walk cycles if a scene
   actually makes them walk. Route blockers can be static.

4. Reuse rooms through decoration overlays.
   Pig & Swine Office is the permanent hub. Add chapter-state decoration packs
   to the same room rather than rebuilding it. New rooms get a tiny tile base
   plus 4-8 meaningful props, not dense visual clutter.

5. Keep generator drafts out of runtime paths.
   Commit only palette-cleaned, size-normalized exports that Godot scenes or
   scripts use. Raw 1024x1024 generator dumps and comparison previews should
   live outside runtime paths or be archived after human approval.

6. Use procedural/simple audio first.
   Short original SFX and one small office loop give better return than a full
   soundtrack pass. Add music per location only when that location is playable.

## Current Audit

- `godot/art` is about 21 MB and `godot/audio` is about 11 MB on disk, so the
  older "art under 5 MB" rule is already exceeded by current assets and imports.
  Treat size as an active risk until the human re-baselines or approves pruning.
- The runtime uses `State.TILE_SIZE = 64` and `State.CHAR_HEIGHT = 64`.
- Current committed character source frames are mixed: many canonical folders
  contain 112x112 PNGs, while `art/sprites/new/cula` contains 124x124 PNGs.
  `CONVENTIONS.md` also has an internal conflict between the 124x124 sprite
  note and the later 64x64 y-sort guidance. Do not start a full sprite
  regeneration pass until that is normalized.
- Current dialogue runtime loads one flat portrait path:
  `res://art/portraits/%s.png`. Expression folders in the portrait brief are a
  future target until Code adds expression-aware portrait selection.
- Office props are already a good cost-saving base. `art/props/office` has the
  fern, calendar, printer, coffee machine, desks, shelves, door, windows, and
  small clutter needed for the Chapter 1 office.
- Coffee mini-game shipping assets live in `art/minigames/coffee`. The older
  `art/minigame_coffee` folder appears to contain raw 1024x1024 generated
  drafts with `.png` extensions that `file` identifies as JPEG data. No runtime
  references to that folder were found in `godot/scenes`, `godot/scripts`, or
  `godot/data`.

## Production Order

### Chapter 1

Ship with existing assets unless a playtest proves an art gap blocks
understanding.

- Use existing single portraits: `cula.png`, `pig.png`, `asia.png`,
  `murrow.png`, `crab.png`, `whimsy.png`.
- Use existing NPC idle sprites and only Cula locomotion.
- Use existing office prop catalogue and tile set.
- Use existing coffee mini-game assets in `art/minigames/coffee`.
- Add only static missing assets for Chapter 1 court if court staging is the
  next playable gap: judge portrait, courtroom bench/table props, and 1-2
  court background tiles. Do not generate a full court crowd.

### After Chapter 1 Is Playable

Generate by need, in this order:

1. Expression portraits for the main cast, but only after Code supports
   expression-specific portrait paths.
2. Casebook card art for judgments that are actually collectable in the next
   chapter.
3. Chapter-specific NPC portraits and idle sprites.
4. District route props and blockers.
5. Location music.

## Asset-Class Rules

### Portraits

- Generate a 512x512 source for quality, then export the runtime size actually
  used by the UI.
- Keep one character per session and one register per session.
- Commit runtime PNGs only. Store prompts and generator seed/metadata in the
  character folder or a nearby brief.
- Do not create 5-expression packs until the dialogue UI can address them.

### Sprites

- Use the existing Pixellab metadata pattern: prompt, character ID, template,
  view, directions, size, palette, and date.
- Silhouette beats detail. At world scale, posture and palette matter more than
  face.
- Avoid held objects and raised hands in walking sprites. Put documents, canes,
  folders, and props in portraits or separate world Sprite2D layers.
- NPC walk cycles are opt-in. Static idle sprites are acceptable for stationary
  office, court, and route-blocker NPCs.

### Tiles And Props

- Prefer reusable 64x64 tiles and small prop PNGs over large illustrated
  backgrounds.
- One room should have 4-8 meaningful props, not a carpet of generic detail.
- Use existing palette swatches from `art/palettes/`; adding a color requires
  a short palette note explaining why the existing set is insufficient.

### Audio

- Ship short OGG SFX first: door, typewriter, printer, coffee machine, stamp.
- Keep music loops short and original. Add only for playable locations.
- Reuse the stamp/paper/shelf-creak vocabulary across SFX and music.

## Prune Candidates

Do not delete these without human approval, but they are the obvious budget
recovery candidates:

- `art/minigame_coffee/`: raw generated 1024x1024 drafts, apparently unused by
  runtime references, roughly 10 MB.
- `art/props/receptionL.png`: large 1448x1086 prop, apparently unused by runtime
  references, roughly 974 KB.
- `art/sprites/cula/cula_128_animation_preview.png`: preview image, apparently
  unused by runtime references, roughly 905 KB.

## Success Criteria

- A playable chapter gets only the art it needs to communicate navigation,
  interactables, and character identity.
- No large generated batch is started before the runtime path that will display
  it exists.
- Every committed runtime asset has a prompt or source note, a known palette,
  and a bounded file size.
- Playtest feedback drives polish priority. Decorative completeness does not.
