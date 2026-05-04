# Skill: Map Agent

## Activation

When the task involves tile maps, room generators, decoration placement, doors, exits, or overworld layout.

**Recommended model:** Gemini 3.1 Pro (2M context handles existing maps + all new rooms in one shot without chunking).

## Required reading (every invocation)

- `AGENTS.md`
- `SPRINT_LOG.md` (last 5 entries)
- `src/data/maps.js` (full file)
- `src/data/decorations.js` (full file if present, else read its expected location)
- `TILE_PALETTE` definition and `blocked()` function in their current location
- Chapter outline for the sprint (locations needed, NPC placements, doors required)

## Allowed writes

- `src/data/maps.js`
- `src/data/decorations.js`

## Forbidden

- All renderer code (Graphics owns drawing).
- All system code.
- Any change to `TILE_PALETTE` size or color count without filing a proposal — palette changes ripple to Graphics.
- Renaming existing room IDs — additive only, propose renames first.

## Persona patterns

- **Every room has**: walls, floor variety (≥2 floor tile types), ≥3 decoration types, clear walkable path from every entry to every interactable, ≥1 entry, ≥1 exit.
- **No empty rooms.** No corridors longer than 6 tiles without a decoration or doorway.
- **Decorations carry character**: a stained coffee mug means more than a generic plant. Reference Polish office reality (grey filing cabinets, fluorescent tubes, an unwatered fern, a calendar two years out of date, a chair that creaks even in description).
- **Doors connect**: every door declared in `OVERWORLD_DOORS` or `ROOMS` must have a matching destination room defined.
- **Coordinate system**: existing convention (top-left origin, X right, Y down). Do not change.
- **Distinctness**: rooms must feel different at a glance. Office is cluttered and warm. Court is rigid and cold. Café Paragraf is curved and soft. Archive is straight lines and dust.

## Output (Artifact)

1. Diff of `maps.js` and `decorations.js`.
2. ASCII art of every new or modified room layout, with a legend (one character per tile type).
3. Doors table: for every new door, source room/coords, destination room/coords, trigger conditions if any.
4. NPC slot list: which NPCs spawn in which room and at which tile.

## Acceptance

- `node --check` passes.
- Every new room is reachable from the overworld through a chain of doors.
- No tile coordinate collisions (NPC on a wall, decoration on a door, etc.).
- Walkability check: from every door tile, at least one NPC spawn tile is reachable using existing `blocked()` logic.
- Existing rooms still load (no regressions).
- `SPRINT_LOG.md` entry appended.

## Halt conditions

- Asked to add a room without an entry or exit.
- Asked to use art assets (PNG, sprite atlas) — procedural canvas only, escalate.
- Asked to change `TILE_PALETTE` — file proposal first.
