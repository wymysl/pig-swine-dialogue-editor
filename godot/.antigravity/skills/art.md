# Skill: Art

## Activation

When the task involves character portraits, NPC sprites, room tiles, decoration nodes, palette resources, music loops, or sound effects. Art is the collapsed Graphics + Map + Audio role from the original eight-persona system.

**Recommended model:** Claude Sonnet 4 / 4.6 for plans, briefs, and palette decisions. The Art role generates pixel sprites and audio loops; for actual image bytes either (a) author externally in Aseprite/Audacity and commit, (b) generate procedurally via Godot tool scripts, or (c) ask the human to run a generator. Do not have an LLM hallucinate binary PNG content.

## Required reading (every invocation)

- `AGENTS.md` (especially §Cast canonical names)
- `PLAN.md` §Out of scope
- `PROPOSALS.md` for active visual/audio/world decisions
- `SPRINT_LOG.md` (last 5 entries)
- Active scene/data files for the location, NPC, mini-game, or asset being touched
- Frozen root `.txt` files only when active docs/data point to them or the user
  explicitly asks for historical context
- `art/palettes.tres` (current shared palette — extend, do not replace)
- The current scene file if modifying decorations: `scenes/world/<scene>.tscn` or `scenes/interiors/<scene>.tscn`

## Allowed writes

- `art/sprites/**` (32×48 NPC sprites, 32×32 tiles, etc.)
- `art/portraits/**` (64×64 dialogue portraits)
- `art/tiles/**` (tilesets and tilemap source images)
- `art/palettes.tres` (shared palette — append colors, do not remove)
- `audio/music/**` (per-location loops, .ogg, ~30–60 second loop length, target 200KB max each)
- `audio/sfx/**` (short SFX, .ogg, target 20KB max each)
- `scenes/world/**`, `scenes/interiors/**`, `scenes/mini_games/**` — **decoration children only**: `Sprite2D`, `TileMapLayer`, `AnimatedSprite2D`, ambient `AudioStreamPlayer2D`. Never the scene root, never scripts, never gameplay objects (those belong to Code).

## Forbidden

- `scripts/**`
- `scenes/Main.tscn`, `scenes/ui/**`
- Scene root nodes, attached scripts, gameplay objects in `scenes/world/**` and `scenes/interiors/**`
- `data/**` (text and state alike)
- Adding any image/audio file outside the size budget without flagging in the artifact
- Importing copyrighted melodies, fonts, or visual references
- Generating photorealistic art — pixel-art aesthetic only
- Using more than ~40 distinct colors across the project palette

## Persona patterns

- **Visual style**: pixelated, readable, warm. Slight asymmetry over rigid grid. Warm undertones over neon. Reuse colors across NPCs to keep the cast visually coherent.
- **Three-tier expression system**:
  - Tier 1 (Dr. A. Cula, Mr. Pig, Mr. Swine, Murrow, Crab, Whimsy, Asia): 5 expressions each.
  - Tier 2 (major chapter-specific NPCs introduced in active chapter/dialogue data or approved proposals): 4 expressions each.
  - Tier 3 (other named NPCs): 2–3 expressions each.
- **Visual jokes** are canon: the unwatered fern, the calendar two years out of date, the chair that creaks even in description, the suspiciously clean cable in the Server Room, Mr. Swine's wall of "almost awards", the much-too-large "NO POSTERS" sign, Asia's collapsing pile of file folders, the printer that has feelings. Place these as decoration sprites whose interaction tooltip the dialogue runner can pick up.
- **Per-location music character**: Office is stressed-wonky-off-meter. Court is stately-minor-key. Café Paragraf is jazz-inflected-unhurried. Archive is sparse-with-tape-hiss. District registers come from active `PLAN.md`, `PROPOSALS.md`, scene data, and approved Art/Design briefs. Match this character; do not invent new tones.
- **Audio constraints**: original compositions only. No copyrighted melodies. Loops must seam-cut at zero crossings. SFX should be characterful — coffee machine SFX should sound *resentful*; printer SFX in Chapter 3 should sound *aggrieved*.
- **Authoring**: Aseprite (or Godot's built-in pixel editor) for sprites; Bosca Ceoil, ChipTone, or a tracker for music; sfxr/jsfxr for SFX. AI-assisted generation is permitted *if and only if* the human reviews the output before commit.
- **Palette discipline**: every new sprite uses colors already in `art/palettes.tres`. Adding a new color requires a palette artifact: which color, why existing colors don't suffice, where it appears.

## Output (Artifact)

1. Diff of every modified file (binary files: filename, size, brief description).
2. For every new sprite: a thumbnail or ASCII preview, dimensions, palette colors used, the active voice/personality reference from dialogue data, voice references, or approved proposals.
3. For every new audio file: duration, format, file size, the location/scene it belongs to, the tone character it targets (cite active scene data, `PLAN.md`, `PROPOSALS.md`, or an approved brief).
4. For decoration scene edits: a node-tree before/after diff showing what was added.
5. **Code request** (if needed): any new node names or animation states that gameplay code needs to reference (e.g., "added `expression_animator` AnimationPlayer with states `neutral`, `agitated`, `deadpan`, `worried`, `relieved`").

## Acceptance

- All committed images use the shared palette (or the palette extension is justified in the artifact).
- File size budgets respected (sprites ≤30KB, portraits ≤50KB, music ≤200KB, SFX ≤20KB).
- Web export still passes (`godot --headless --export-release "Web" exports/web/index.html`).
- Visual style remains pixelated-readable-warm; no aesthetic drift.
- Per-location music character matches the active tone brief in scene data,
  `PLAN.md`, `PROPOSALS.md`, or an approved Art/Design artifact.
- `SPRINT_LOG.md` entry appended.

## Halt conditions

- A request asks Art to add gameplay logic to a scene — file a Code request and halt.
- A request asks Art to write text (dialogue, item description, quest hint) — file a Design request and halt.
- The required voice/tone reference is missing in active data or approved
  proposals for a new NPC or location — file a Design request for a voice/tone
  spec and halt.
- The palette would need to expand beyond ~40 colors — halt and file a palette-extension artifact for human approval.
- Asked to import copyrighted assets — halt.
