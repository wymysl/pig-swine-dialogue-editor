# Pig & Swine Curation Board

## Current Focus

Day One is complete. Polish the experience. Start planning Day Two.

## Current Build State

- Dr. A. Kula exists as player character.
- Mr. Pig, Muraś, Rak, Wymysl, Court Clerk, and Tram 17 Oracle exist.
- Main quest chain (6/6 steps) works end-to-end.
- **Quest tracking FIXED** — NPCs now update dialogue based on precise progress (court → rights → law → friends → guide).
- **Pixel portraits** — 32x32 pixel art portraits for all NPCs in dialogue boxes.
- Opening scene with Mr. Pig dialogue works.
- Court argument choice puzzle works with 3 options.
- **Court Result Screen** — shows argument quality, stat deltas, Mr. Pig reaction.
- **Day One Summary Screen** — narrative recap, final stats, Muraś epilogue.
- **Smooth movement** — visual interpolation, held-key walking, no more snapping.
- **Save/Load System** — auto-save after quests, manual save in Case Bag (S/L keys).
- **Touch controls** — d-pad + action buttons for mobile (PWA support).
- Interaction prompts, Docket (Q), Case Bag (I), Mini Map (M) all work.
- **Progression Badge System** — Pokémon-style badges unlock when completing quests, displayed in Case Bag with colored icons and flash notifications.
- **Random Office Incidents** — 10% chance per move, choices affect stress/reputation.
- **Expanded Map (24x24)** — Added The Archive, Court Hall, Coffee Shop with hidden items.
- **New NPCs** — Archivist, Judge, Barista with quest chains.
- **Hidden Items** — Ancient Case Files, Court Stamps, Specialty Coffee Beans (proximity-based visibility).

## Current Weaknesses

1. **True interiors still shallow** — current build has richer interior tiles/area state, but not yet separate door-transition rooms like Pokémon Yellow.
2. **Portraits improved but not final** — larger 64x64 busts read better, but still need hand-authored character silhouettes and expression poses.
3. **Random incidents reduced** — less spammy now, but need longer-term balancing after player testing.
4. **Day Two content missing** — after Day One ends, limited new content beyond Nowak setup.

## Next Best Task

Implement true Pokémon-style door transitions into separate interior room maps: Pig & Swine office, Court Hall, Cafe, Archive. Add furniture collision, decorative wall/floor tiles, and room-specific NPC/item placement.
Enhance sound effects with more varied tones for UI interactions (Docket/Case Bag open/close), add achievement sound for quest milestones, or continue with character portrait/dialogue polish to make NPCs more distinct and funny.

## Next Best Task
## Next Best Task

Enhance Ms. Nowak's post-quest dialogue with funny reactions (e.g., "Mr. Swine would be proud — if he were not skiing in Japan").
Or add Day Two map zone (court annex for eviction cases) to expand world.
Or enhance sound effects with evidence collection sounds (paper rustle for documents, poster unroll sound).

## Recent Improvements

- Progression Badge System (Pokémon-style) with 9 quest-linked badges.
- Random Office Incidents with choice-based stat impacts.
- Expanded map to 24x24 with three new zones and hidden items.
- New NPCs (Archivist, Judge, Barista) with quest chains.
- Floating interaction hints for nearby NPCs/items.
- Docket / quest log overlay on Q.
- Case Bag / inventory overlay on I.
- Mr. Pig opening scene and Muraś guide step.
- First court argument choice puzzle.
- Court Result Screen with stat deltas and Mr. Pig reaction.
- Day One Summary screen with narrative recap.
- Smooth tile-by-tile movement with visual interpolation.
- Choice menu layout fix (no more text overlap).
- Ms. Nowak NPC and eviction court puzzle with evidence collection and legal choice.
- Nowak evidence items correctly placed: Lease Agreement (office), Human Rights Poster (cafe), Landlord Notice (from Nowak on talk).

## Curation Warnings

- Do not add more NPCs until current NPCs have better function.
- Do not expand map before adding save/load.
- Polish Day One before starting Day Two content.
- Keep JS in a single index.html until file exceeds 800 lines.

## Playtest Findings Logged — 2026-05-03

- User found random events repetitive and annoying; fixed first pass with lower chance, cooldown, anti-repeat, and expanded incident pool.
- User found all correct answers were first options; fixed court and Nowak puzzles so correct answers vary.
- User found text overflow; fixed first pass with larger boxes and clipped wrapping.
- User found portraits too tiny; upgraded to larger dialogue busts, but more art direction needed.
- User wants Pokémon Yellow-style interiors and mobile/mac path; next sprint should focus on true separate room maps.
