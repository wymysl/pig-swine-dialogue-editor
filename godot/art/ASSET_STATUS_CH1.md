# Chapter 1 Art Status

This is a working Art-role checklist for Chapter 1. It tracks what is already
usable and what should wait. It is intentionally scoped to the current playable
slice.

## Already Usable

| Area | Runtime Assets | Status |
| --- | --- | --- |
| Main cast portraits | `art/portraits/cula.png`, `pig.png`, `asia.png`, `murrow.png`, `crab.png`, `whimsy.png` | Single-expression runtime set present |
| Main cast sprites | `art/sprites/*/*_sprite_frames.tres` | Idle sets present; Cula has locomotion |
| Halina sprite | `art/sprites/halina/halina_sprite_frames.tres` | Idle set present for Chapter 1 |
| Office props | `art/props/office/*.png` | Strong reusable office set present |
| Office tiles | `art/tilesets/office_tileset.tres` | Present and referenced by `pig_swine_office.tscn` |
| Coffee mini-game | `art/minigames/coffee/*.png` and `audio/minigames/coffee/*.wav` | Shipping-size assets present |
| Global SFX | `audio/sfx/door_open.ogg`, `typewriter_tick.ogg` | Present |

## Cost-Saving Cuts For Chapter 1

- Do not generate full expression sets yet. The current dialogue runtime loads
  one flat portrait per character.
- Do not generate NPC walking cycles unless a scene makes the NPC visibly walk.
- Do not generate Chapter 2+ district art.
- Do not replace existing office props unless a playtest shows a prop is
  unreadable or misleading.
- Do not generate a court crowd. For Chapter 1 court, prioritize judge/opponent
  readability and staging props.

## Next Useful Art Tasks

1. Resolve the sprite-size documentation conflict with a Code/Art decision.
   Until this is settled, avoid regenerating full character sprite sets.
2. If court is next, add the smallest court staging pack:
   `judge_portrait`, `court_bench`, `evidence_table`, `court_floor_tile`,
   `court_wall_tile`.
3. If dialogue UI gains expression support, generate expression packs one
   character at a time, starting with Mr. Pig and Asia.
4. After human approval, archive or remove unused raw generator dumps listed in
   `ART_PRODUCTION_PLAN.md`.

## Files To Avoid Touching Without Approval

- `art/minigame_coffee/`: likely raw drafts, but do not delete without approval.
- Any `.import` file unless Godot regenerated it.
- Existing scene references under `scenes/`; Art may add decoration nodes only,
  but should not change gameplay nodes or scripts.
