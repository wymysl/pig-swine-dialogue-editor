# V1.A commit prompt — for Antigravity

You are committing the V1.A pass-3 final draft to the project's voice-reference and dialogue files, plus a manifest update and a voice-audit run. The pass-3 file is the canonical source for line text. Do **not** re-author lines, paraphrase, or "improve" them. Treat the draft text as exact.

## Inputs (read first)

1. **Pass-3 commit shape** (line text and self-check): `narrative_revision/phase_7_drafts/V1_A_draft_pass3.md`. The "Commit candidates" section lists every line to commit, by state, with the gating flag and quoted text. Use the quoted text verbatim.
2. **Pack** (for §K commit obligations and §M manifest obligations): `narrative_revision/phase_7_packs/V1.A_asia_hint_states.md`.
3. **Pseudo-logic source** (for the optional dialogue-file mapping): `story.txt` lines 1245–1288. The `get_asia_hint()` first-unmet-flag-wins priority order.
4. **Existing voice-reference file** (for schema discovery; the file already exists): `godot/data/voice_references/dialogue_samples_asia.jsonl`. Inspect existing records before appending. Do not invent fields.
5. **Existing dialogue file** (for schema discovery if you author the optional mapping file): `godot/data/dialogues/judge_district_ch1.json`. The schema and ID conventions established by V1.7 commit.
6. **Address-form reference** (only if needed): pack §A.6 + project address-form rule. *"Mr. Pig" / "Mr. Murrow" / "Mrs. Sikorska" / "Mr. Swine" formal-titled; "Crab" / "Whimsy" bare; no "Dr. Cula" address in hint-NPC register.* The 12 V1.A lines have already been authored against this rule; do not adjust.

## Tasks

### Task 1 — Append 12 hint-state lines to `dialogue_samples_asia.jsonl`

Append one JSON record per line, in the priority order from pass-3 (states 1 → 12). Schema-match the existing records in `dialogue_samples_asia.jsonl` exactly — `record_type`, `id`, `character_id`, `speaker`, `chapter`, `scene`, `context`, `line_type`, `expression`, `tags`, `text`, `notes`.

Per-record metadata:

- `record_type`: `dialogue_sample`
- `id`: `asia_ch01_v1_a_p3_hint_state_<flag>_001` — substitute the gating flag name (e.g., `pig_revealed_crisis`, `met_murrow`, `has_law_binder`, `recruited_crab`, `has_rights_memo`, `recruited_whimsy`, `halina_met`, `archive_research_complete`, `court_ready`, `won_court`, `received_swine_postcard`). For state 12 (default), use `asia_ch01_v1_a_p3_hint_state_default_001`.
- `character_id`: `asia`
- `speaker`: `Asia`
- `chapter`: `ch01`
- `scene`: `pig_swine_office`
- `context`: brief description naming the trigger and hint direction. Example for state 1: *"V1.A pass 3 — Beat 2 entry hint state; player has not yet seen Pig's Beat-2 panic line; hints toward Mr. Pig"*. Match the trigger phrasing in pass-3's per-state sections.
- `line_type`: `hint_state`
- `expression`: `cheerful_tired`
- `tags`: array including `phase7_v1_a_p3`, `hint_state`, the gating flag name (e.g., `pig_revealed_crisis`), and one register tag (`warm_direct` for most states; `briefly_conspiratorial` for states 9 and 12; `briskly_prioritising` for states 6 and 10 — match the register-note tags from pass-3 per-state sections).
- `text`: the line verbatim from pass-3. **Em-dash placement is load-bearing**: state 5's *"Try Café Paragraf — or wherever..."* is the only line with an em-dash. All other 11 lines have zero em-dashes. Preserve exactly.
- `notes`: for states 1–6 and 9–12 (legacy verbatim): *"Phase 7 V1.A pass 3 commit shape; hint-NPC repeat line; verbatim from `_legacy/dialogue_samples.txt` line <N>; not final."* For states 7 and 8 (phase-8 new): *"Phase 7 V1.A pass 3 commit shape; hint-NPC repeat line; phase-8 new line authored from §B.1 recommended sample shape; not final."*

The 12 lines (verbatim from pass 3):

1. *"You should talk to Mr. Pig first. He's the loudest crisis in the room."*
2. *"Mr. Murrow will know what the case is actually about. He's somewhere between the files and disappointment."*
3. *"You're looking for the procedural binder. I tried lifting it once and briefly saw another dimension."*
4. *"If it's a service problem, Crab will have an opinion. He always has an opinion."*
5. *"The rights memo may be near Whimsy. Try Café Paragraf — or wherever someone is talking too loudly about fairness."*
6. *"Whimsy is useful if pointed at the right legal issue. Try asking him about fair hearing."*
7. *"Mrs. Sikorska is in the meeting room. She brought her own folder."*
8. *"Mr. Murrow is in the archive with the binder. He's been making the disappointed-page-turn sound."*
9. *"Mr. Murrow should check the case before court. He has a special face for missing documents."*
10. *"If Mr. Murrow says you're ready, go north to the District Court. And maybe drink water."*
11. *"Something arrived from Mr. Swine. The stamp looks expensive and irresponsible."*
12. *"For the first time today, nothing is actively on fire. I give it twelve minutes."*

### Task 2 — (Optional) Author `data/dialogues/asia_hint_states_ch1.json`

Pseudo-logic mapping for `get_asia_hint()` per `story.txt` lines 1245–1288. Schema-match `godot/data/dialogues/judge_district_ch1.json`. Encode:

- The 12 hint-state branches in priority order (first-unmet-flag wins).
- Each branch: gating flag name + the line text.
- The default branch (post-postcard) at the end.

If the dialogue-file schema has fields the hint-state mapping does not need (e.g., turn structure, speaker IDs for multi-speaker exchanges), use sensible defaults — Asia is the only speaker; there is no turn structure beyond single-line repeatable hints. If unsure of the schema mapping, author this file only if the mapping fits naturally; otherwise skip and report the optional task as deferred.

### Task 3 — Update the manifest

Edit `narrative_revision/phase_7_packs/00_pack_manifest.md`:

1. V1.A row in the chapter-1 table: change ⏸ to ✅. Leave all other columns intact.
2. Pack index entry: `⏸ **V1.A** — Asia hint states` → `✅ **V1.A** — Asia hint states`. Match the formatting of earlier committed-pack entries (V1.1 / V1.2 / V1.3 / V1.4 / V1.5 / V1.6 / V1.7).
3. No further renumber required. No bible / audit / beat-sheet edits required.

### Task 4 — Run the voice audit

Run `tools/voice_audit.py` against the modified `dialogue_samples_asia.jsonl` (or the full set per the V1.7 commit pattern). Capture output. If the audit reports flags on any of the V1.A commit lines, list each flag verbatim and stop — do not silently revise. If the audit is clean (or the only flags are pre-existing on lines V1.A did not touch), report clean.

The audit's `MURROW_PRIVATE_SCENE_HINTS` tuple already includes `pig_swine_office` (added during V1.7 commit). Rule A and Rule B were tightened during V1.7 commit to handle "Dr. Cula" correctly. **V1.A lines do not contain "Dr. Cula" in any text** (the hint-NPC register is room-shaped per pack §A.6), so Rule A and Rule B should not fire on the new appends.

## Discipline checks (do not relax)

- **Exact text.** The 12 lines in the pass-3 file are the committed text. Em-dash placement (state 5 only), capitalisation, punctuation, semicolons, quotation marks: preserve exactly.
- **Schema fidelity.** Match existing records in `dialogue_samples_asia.jsonl` exactly. Do not add fields. Do not reorder fields. Do not change indentation conventions.
- **No re-authoring.** If a line looks "off" to you, do not adjust it. The arbitration trail is recorded in V1.A pass 1 / pass 2 / pass 3; the lines are committed.
- **Tag the gating flag.** Each record's `tags` array must include the gating flag name (e.g., `pig_revealed_crisis`). This is what lets the implementation's `get_asia_hint()` retrieve the line by flag.
- **Halina untouched.** Do not append anything to `dialogue_samples_halina_sikorska.jsonl`. Halina is referenced *by Asia* in state 7 (*"Mrs. Sikorska is in the meeting room"*) but Halina herself does not speak in V1.A.

## Output

When done, report:

1. Files modified or created, with paths.
2. Number of lines appended to `dialogue_samples_asia.jsonl` (expected: 12).
3. Whether `asia_hint_states_ch1.json` was authored or deferred.
4. Manifest diff (the two changed entries).
5. Voice-audit result (clean / flags listed verbatim).

Do not summarise the V1.A narrative content. The point of this run is the commit, not the literary work.
