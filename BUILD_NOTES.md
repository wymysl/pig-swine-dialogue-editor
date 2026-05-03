
## Build Note: 2026-05-03T09:09:00+00:00

Changed:
- Corrected Nowak evidence item placements (TDD: RED → GREEN).
- Moved Human Rights Poster to Coffee Shop (x:18,y:14) from office area.
- Removed Landlord Notice as world item; now given directly by Ms. Nowak on first talk.
- Updated Ms. Nowak's onTalk to grant Landlord Notice automatically with flashDialog.
- Added test_nowak_evidence_items_in_world to test_story.py (21 total checks).

Verified:
- `python3 test_story.py` passes with 21 checks (new evidence placement test passes).
- `node --check /tmp/pig_swine_game.js` passes (0 syntax errors).
- Nowak evidence items placed in correct map zones:
  - Lease Agreement in Pig & Swine office (x:11,y:4).
  - Human Rights Poster in Coffee Shop (x:18,y:14).
  - Landlord Notice given by Ms. Nowak on first interaction.
- Evidence tracking state (nowakEvidence) works correctly.

Observed:
- Evidence items now align with game world locations (office for legal docs, cafe for posters).
- Landlord Notice delivery via dialogue feels more natural (fits Ms. Nowak's role as client giving case materials).
- Player has clear evidence collection path: office → cafe → talk to Nowak.

Curated/Cut:
- Removed Landlord Notice as world item to avoid clutter; delivery via NPC dialogue is cleaner.
- Kept single HTML file structure (~1310 lines, still manageable).
- No new NPCs added; focused on improving existing Nowak case flow.

Next best task:
- Add Ms. Nowak's post-quest dialogue with funny reactions (e.g., "Mr. Swine would be proud — if he were not skiing in Japan").
- Or add Day Two map zone (court annex for eviction cases) to expand world.
- Or enhance sound effects with evidence collection sound (paper rustle for documents, poster unroll sound).

## Build Note: 2026-05-03T10:19:55+00:00

Changed:
- Playtest-driven polish pass based on Wymysl feedback.
- Random office incidents now trigger much less often: 3% per completed move, no immediate repeat, 18-move cooldown, and six incident types instead of three.
- Court and Nowak choice puzzles no longer make the first option correct; players must read the legal argument.
- Choice/dialogue text boxes enlarged; `writeWrapped` now supports max-line clipping with ellipsis so text does not spill outside allocated space.
- Dialogue portraits are now 64x64 scaled pixel busts instead of tiny 32x32 stamps.
- Interior state added: HUD shows current area and office/court/cafe/archive tiles have richer interior details.

Verified:
- `python3 test_story.py` → 23 checks passed.
- Extracted inline JavaScript passed `node --check /tmp/pig_inline.js`.
- Node runtime smoke test initialized the game with a stubbed canvas/DOM without errors.

Observed:
- Browser visual verification could not run in this environment because no Chrome/agent-browser binary is installed. This remains a verification gap; user should test via local HTTP server and report visual clipping/feel.

Curated/Cut:
- Did not switch programming language yet. For current scope, HTML/Canvas/PWA remains fastest for iteration and can later be packaged for iOS/Android/macOS with Capacitor/Tauri/Electron if the prototype earns it.

Next best task:
- True Pokémon-style interiors: explicit door transitions into separate room maps with furniture collision, richer wall/floor tiles, and room-specific NPC placement.
