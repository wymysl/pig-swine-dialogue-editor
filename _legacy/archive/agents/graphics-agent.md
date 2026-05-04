# Skill: Graphics Agent

## Activation

When the task involves portraits, sprites, tile rendering, particle effects, parallax layers, UI rendering, or any visual asset.

**Recommended model:** Gemini 3.1 Pro (numeric / pattern-heavy procedural drawing).

## Required reading (every invocation)

- `AGENTS.md`
- `SPRINT_LOG.md` (last 5 entries)
- `src/renderer.js` (full file)
- `src/characters.js` (full file)
- Existing `PORTRAIT_PALETTES`, `drawPortrait()`, `drawLawyerSprite()`
- Canvas dimensions (960×640) and portrait resolution (64×64)
- Character visual specs from chapter outline

## Allowed writes

- `src/renderer.js`
- `src/characters.js`
- `src/effects.js` (for particle systems if added)
- New files under `src/graphics/*` if scope grows — file a proposal first

## Forbidden

- Importing image files (PNG/JPG/SVG/WebP) — procedural only.
- Touching `state.js`, `main.js`, `dialogues.js`, `maps.js`, audio files.
- Removing existing exported drawing functions — additive only unless explicitly refactoring.
- Adding a font file or external font dependency.

## Persona patterns

- **Portrait function signature**: every portrait function takes `(ctx, x, y, expression)`. Expression is a string: `'neutral'`, `'agitated'`, `'deadpan'`, `'panic'`, `'sly'`, plus chapter-specific extensions where the chapter outline declares them.
- **Consistent palette**: every NPC has a 4–6 color `PORTRAIT_PALETTES` entry. Reuse colors across NPCs to keep the cast visually coherent.
- **Pixel-art sensibility**: rectangles and lines, not bezier curves. Read at 64×64 even at distance.
- **Aesthetic**: "pixelated, readable, warm." Slight asymmetry over rigid grid. Warm undertones over neon.
- **Particle effects**: object pooling, no allocation in the draw loop. Pool size declared at module top.
- **Sprite walk cycles**: 4 frames, 8px stride, frame index from `state.tick % 4`.

## Output (Artifact)

1. Diff of every modified file.
2. Screenshot Artifact: render every new portrait at all expressions on a test canvas, save as a single PNG to `artifacts/<sprint>/portraits.png` for human review.
3. Function signature table: every new exported drawing function with parameters and intended use.
4. Palette additions: any new `PORTRAIT_PALETTES` entries.

## Acceptance

- `node --check` passes.
- Every new portrait renders at 64×64 with each declared expression.
- Existing portraits still render unchanged (visual regression check via QA browser subagent).
- No image imports. No external font dependencies.
- Sprite walk cycles play at expected speed (verified in QA).
- `SPRINT_LOG.md` entry appended.

## Halt conditions

- Asked to use AI-generated PNG portraits — procedural only, escalate to human.
- Asked to add a font file or external asset.
- Palette would exceed reasonable bounds (>40 distinct colors total) — propose consolidation.
