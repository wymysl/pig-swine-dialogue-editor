# CONVENTIONS / AGENTS Sync Proposal — 2026-05-16

## Summary
- Tonight's cohort introduced the **v17 player-driven argument pivot**, which reshapes how Chapter 1 evidence is synthesized and presented.
- Key additions include seven new state flags (v17), a new directory for court-round data, and a formalised enum-validation contract in the dialogue editor.
- The following ten sections describe the governance updates required to bring the authoritative docs into sync with the landed implementation.

## §1 — CONVENTIONS.md §Chapter 1 state schema
For the seven v17 flags introduced by Agent 3 (commit `2f7a81b`) and scaffolding (commit `bc45550`):

- **v17 — Player-driven argument pivot (SAVE_VERSION 17).** Seven flags supporting the evidence-synthesis and court-round reshape.
    - `chapter1.binder_read_envelope` / bool / false / Owner: `crab.json` (on_dismiss) + v2 binder UI.
    - `chapter1.binder_read_renewal` / bool / false / Owner: `crab.json` (on_dismiss) + v2 binder UI.
    - `chapter1.binder_read_renumbering` / bool / false / Owner: `crab.json` (on_dismiss) + v2 binder UI.
    - `chapter1.proposed_frame` / string / "" / Owner: `crab.json` synthesis options.
    - `chapter1.whimsy_co_counsel_posture` / string / "" / Owner: `whimsy.json` recruitment options.
    - `chapter1.judicial_patience` / int / 5 / Owner: `battle_controller.gd`.
    - `chapter1.witness_cooperation` / int / 0 / Owner: `battle_controller.gd`.

- **Proposed insertion point:** After `CONVENTIONS.md:387` (following the "Routes unlocked" bullet).
- **Note on drift:** `chapter1.murrow_choice` (added in v16) is missing from the registry in `chapter1.json`; a catch-up entry should be added alongside v17.

## §2 — CONVENTIONS.md §Dialogue trigger syntax
- Tonight's drafts (Agents 4/5/6) use standard comparison predicates (e.g., `proposed_frame == 'merits_defence'`).
- **Proposed addition:** Document the "soft-fail" trigger pattern for NPCs reacting to "wrong" argument shapes. Example: gate a correction state on `proposed_frame != '' && proposed_frame != 'defective_service_135bis'` followed by the specific correction line.
- **Note:** The existing documentation for `&&` and `||` (OR-of-ANDs) remains sufficient.

## §3 — CONVENTIONS.md §Dialogue option schema
- Agent 8's editor work (commit `81f82ae`) formalises a contract between the registry and the authoring tool.
- **Proposed addition (at line ~422):**
  > **Enum Validation Contract.** When a `write_path` targets an enum-typed flag declared in `chapter1.json.new_state_flags` (e.g., `proposed_frame`), the Dialogue Editor validates that all choice `value` entries belong to the flag's `_enum` block. This contract is enforced authoring-side to prevent runtime logic errors; the Godot runtime remains fail-soft.

## §4 — AGENTS.md §File ownership table
Proposed additions to the table (insertion point: `AGENTS.md:143`):

| Path | Owner | Notes |
|---|---|---|
| `data/court_rounds/**` | Code (structure) + Design (text) | Two-pass authoring per `_schema.md`. Phase 1 (witnesses) and Phase 2 (closing) blocks. |
| `data/evidence_ch1.json` | Code (structure) + Design (text) | Evidence database for binder UI and court rounds. |
| `data/argument_frames_ch1.json` | Code (id/tags) + Design (text) | Canonical argument shapes for synthesis dialogues. |
| `data/_drafts/**` | Code + Design (writers) | Review artifacts only. DialogueRunner skips this directory (filename filter in `dialogue_runner.gd`). |
| `godot/scratch/**` | Workspace / Not-runtime | Experimental scripts moved by Agent 10 hygiene. Not for runtime use. |

## §5 — AGENTS.md §Save migration policy
- **Audit:** The v16→v17 migration (commit `bc45550`) strictly followed the policy: `SAVE_VERSION` bumped to 17, `migrate_save()` added to `save.gd`, and `test_save_migration_v16_v17.gd` added.
- **Conclusion:** No changes needed to the policy doc; the existing discipline held.

## §6 — AGENTS.md §Stack invariants or §Forbidden patterns
- **Audit:** No violations of invariants or forbidden patterns found in tonight's work.
- **Conclusion:** No changes needed.

## §7 — PROPOSALS.md status table updates
Proposed updates to the status table (`PROPOSALS.md:180+`):

- **Update §10:** "Implementation depth added 2026-05-16 (schema, v17 scaffolding, battle controller restoration). Design follow-on in `PROPOSAL_player_driven_argument.md`."
- **New Entry §12:** `PROPOSAL_player_driven_argument.md` | **DEVELOP** | "Design surface for the player-driven argument pivot (synthesis reshape)."

## §8 — Things that are NOT proposed for governance change
- **Trust meter:** Halina's trust mechanics (v11) remain the authoritative pattern for client meetings.
- **Cast names:** All agents adhered to "Dr. A. Cula", "Murrow", etc.
- **Address forms:** Post-recruitment "Cula" vs "Dr. A. Cula" logic (Agent 4) is consistent with §Address forms.
- **Tag taxonomy:** No new tags added; v17 consumes the existing आर्टिकल/प्रिंसिपल/कॉन्टेक्स्ट (APC) taxonomy.

## §9 — Recommended review order for Piotr
1. **CONVENTIONS.md §Chapter 1 state schema** additions — essential for state-aware agents starting their runs.
2. **AGENTS.md §File ownership table** — essential for clarity on who owns the new `court_rounds/` and `evidence` data.
3. **PROPOSALS.md updates** — for project bookkeeping.
4. **Dialogue option enum-contract** — documentation of existing tool-side enforcement.

## §10 — Per-agent cross-reference
- **Agent 2:** Landed `court_rounds` schema and data. (Ref: §4 Ownership).
- **Agent 3:** Landed `chapter1.json` registry catch-up. (Ref: §1 Schema).
- **Agent 4:** Landed Crab synthesis draft. Flagged `proposed_frame` enum usage. (Ref: §10).
- **Agent 8:** Landed Editor enum validator. (Ref: §3 Option schema).
- **Agent 10:** Landed hygiene/scratch relocation. (Ref: §4 Ownership).
- **Agent 12:** Landed battle controller restoration. Consumes `judicial_patience` and `proposed_frame`. (Ref: §1 Schema).
- **Agent 5/6:** Landed Murrow/Whimsy drafts (v17 integration). (Ref: §10).
