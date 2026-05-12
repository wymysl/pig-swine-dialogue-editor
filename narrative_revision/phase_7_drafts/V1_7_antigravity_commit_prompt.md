# V1.7 commit prompt — for Antigravity

You are committing the V1.7 pass-5 final draft to the project's voice-reference and dialogue files, plus a manifest update and a voice-audit run. The pass-5 file is the canonical source for line text. Do **not** re-author lines, paraphrase, or "improve" them. Treat the draft text as exact.

## Inputs (read first)

1. **Pass-5 commit shape** (line text and self-check): `narrative_revision/phase_7_drafts/V1_7_draft_pass5.md`. The "Commit candidates (final — JSONL appends)" section lists every line to commit, by character, with quoted text. Use the quoted text verbatim.
2. **Pack** (for §K commit obligations and §M manifest obligations): `narrative_revision/phase_7_packs/V1.7_post_court_payoff.md`.
3. **Existing voice-reference directory:** `godot/data/voice_references/`. Inspect the existing `.jsonl` files to learn the schema before appending. The convention is one JSON object per line. Do not invent fields; use exactly the keys the existing files use. Example files to read for schema discovery: `dialogue_samples_crab.jsonl`, `dialogue_samples_whimsy.jsonl`, `dialogue_samples_dr_a_cula.jsonl`, `dialogue_samples_mr_murrow.jsonl`. The actual filename convention is `dialogue_samples_<character>.jsonl`, not the simplified `<character>.jsonl` shorthand the pack uses.
4. **Existing dialogue directory:** `godot/data/dialogues/`. Inspect `judge_district_ch1.json` to learn the dialogue-file schema before authoring the new postcard file.
5. **Manifest:** `narrative_revision/phase_7_packs/00_pack_manifest.md`. Read the V1.7 row in the chapter-1 table and the pack-index entry before editing.

## Filename mapping

The pack §K uses simplified character names. Map them to the actual files in `godot/data/voice_references/`:

| Pack §K name | Actual file |
| --- | --- |
| `pig.jsonl` | `dialogue_samples_mr_pig.jsonl` (verify; create if absent) |
| `asia.jsonl` | `dialogue_samples_asia.jsonl` (verify; create if absent) |
| `murrow.jsonl` | `dialogue_samples_mr_murrow.jsonl` |
| `crab.jsonl` | `dialogue_samples_crab.jsonl` |
| `whimsy.jsonl` | `dialogue_samples_whimsy.jsonl` |
| `cula.jsonl` | `dialogue_samples_dr_a_cula.jsonl` |
| `swine.jsonl` | `dialogue_samples_mr_swine.jsonl` (NEW; match the existing convention) |

If a target file does not exist (e.g., Pig, Asia, Swine — verify by `ls`), create it using the same schema and metadata-row conventions as the existing files. Do not introduce a new schema.

## Tasks

### Task 1 — Append voice-reference lines

For each speaker block in pass-5's "Commit candidates" section, append the quoted lines to the corresponding JSONL file. Use exact text — including the celebration paragraph's two em-dashes flanking *"yes, the client"*, and the retainer aside's em-dash in *"is still — somewhere"*. Do not collapse, paraphrase, or split lines.

Per-character commit list (transcribed from pass 5; cross-verify against the file):

- **Pig (`dialogue_samples_mr_pig.jsonl`)** — six lines:
  1. *"You are back. Good. Good."*
  2. *"We have come through another impossible thing. The client — yes, the client — also survived. The rent will breathe; the printer can wait; the 5,000 PLN Sikorska fee came through."*
  3. *"Mr. Swine's retainer is still — somewhere. Sea of Japan. Presumably alive."*
  4. *"Yes. Yes, the next thing."*
  5. *"Greetings from Sapporo. A very serious gentleman in the lobby has proposed a venture involving conference centers and a fisheries contact, and I have given him my card on principle. Keep Pig & Swine afloat in my absence."*
  6. *"The Sea of Japan, then."*
- **Asia (`dialogue_samples_asia.jsonl`)** — two lines:
  1. *"Good work, Dr. Cula. The blue file is back on your desk."*
  2. *"Mr. Pig. Postcard. The address says Sapporo."*
- **Murrow (`dialogue_samples_mr_murrow.jsonl`)** — one line:
  1. *"Cula. The Borowski file is on your desk for tomorrow."*
- **Crab (`dialogue_samples_crab.jsonl`)** — one line:
  1. *"The renumbering was the ground. The order does what the ground required."*
- **Whimsy (`dialogue_samples_whimsy.jsonl`)** — two lines:
  1. *"I propose the matter as a chamber operetta. The bailiff sings the renumbering from the wrong doorway."*
  2. *"Behold. The postcard."*
- **Cula (`dialogue_samples_dr_a_cula.jsonl`)** — two lines:
  1. *"Thank you, Asia."*
  2. *"Mr. Murrow."*
- **Swine (`dialogue_samples_mr_swine.jsonl`, NEW)** — postcard body and signature:
  1. Body: *"Greetings from Sapporo. A very serious gentleman in the lobby has proposed a venture involving conference centers and a fisheries contact, and I have given him my card on principle. Keep Pig & Swine afloat in my absence."*
  2. Signature: *"Yours, Swine."*

When the existing JSONL files include scene / chapter / beat / register / source-pack metadata fields, populate them. Each V1.7 line's metadata should reference: chapter 1; beat 13 or beat 14 as appropriate; pack `V1.7_post_court_payoff.md`; commit pass `V1_7_draft_pass5.md`. Pig's celebration paragraph is beat 13 H4 register; Pig's retainer aside is beat 13 maritime / sincere-panic; Pig's exit is beat 13 distractable-anxious; Pig's postcard read-aloud and Sea-of-Japan reaction are beat 14. Asia's congratulation is beat 13 warm-while-sorting; Asia's address-label is beat 14. Murrow's line is beat 13 dry-collegial. Crab's is beat 13 professional-indifference. Whimsy's musical proposal is beat 13 theatrical-cynic; *"Behold. The postcard."* is beat 14 archaic-deflection. Cula's two fragments are beat 13 acknowledgment-fragment. Swine's postcard is beat 14 cheerful-evasive.

If the existing schema does not have these fields, do not invent them — match what is already there.

### Task 2 — Create `data/dialogues/postcard_swine_ch1.json`

Author a new dialogue file at `godot/data/dialogues/postcard_swine_ch1.json` covering the Beat-14 final stinger. Schema-match `godot/data/dialogues/judge_district_ch1.json`. Include:

- The postcard body (Swine — three sentences as listed above; signature as separate field if the schema separates address-line / body / signature, otherwise body only).
- Asia's address-label line: *"Mr. Pig. Postcard. The address says Sapporo."*
- Pig's read-aloud cue: a stage-direction entry describing *"Pig turns the postcard over. The front shows a snowy building and a sign too small to read at this distance. Pig reads the body aloud."*
- Pig's body read-aloud line (same as the postcard body in Pig's voice file).
- Pig's reaction line: *"The Sea of Japan, then."*
- Whimsy's archaic-deflection: *"Behold. The postcard."*
- Trigger reference: Beat-14 final stinger; chapter-1 close cue; Day-One Survivor badge K-tag.
- Address line metadata if the schema supports it: *"To Mr. Pig, Pig & Swine, Warsaw"*.

If `judge_district_ch1.json` uses a particular ID convention, route convention, or speaker-id convention, follow it exactly. Do not introduce a new convention.

### Task 3 — Update the manifest

Edit `narrative_revision/phase_7_packs/00_pack_manifest.md`:

1. In the chapter-1 table row for V1.7: change the status indicator from ⏸ to ✅. Leave all other columns intact.
2. In the pack-index entry: change `⏸ **V1.7** — Post-court office payoff (`V1.7_post_court_payoff.md`)` to `✅ **V1.7** — Post-court office payoff (`V1.7_post_court_payoff.md`)`. Match the existing ✅-row formatting from earlier committed packs (V1.1 / V1.2 / V1.3 / V1.4 / V1.5 / V1.6).
3. Do not edit any other manifest content. Per pack §M: no row insertion required; no further renumber required; no bible / audit / beat-sheet edits required; chapter-1 vertical pack count summary unchanged.

### Task 4 — Run the voice audit

Run `tools/voice_audit.py` from the repo root. Capture the output. If the audit reports flags on any of the V1.7 commit lines, list each flag verbatim and stop — do not silently revise. If the audit is clean (or the only flags are pre-existing on lines V1.7 did not touch), report clean.

## Discipline checks (do not relax)

- **Exact text.** The line text in the pass-5 file is the committed text. Em-dash count, semicolons, quotation marks, capitalisation: preserve exactly. The two em-dashes flanking *"yes, the client"* are canonical and required. The em-dash in *"is still — somewhere"* is canonical and required.
- **Schema fidelity.** Match existing files. Do not add fields. Do not reorder fields. Do not change indentation conventions.
- **No re-authoring.** If a line looks "off" to you, do not adjust it. The arbitration trail is recorded in pass 1 / pass 2 / pass 3 / pass 4 / pass 5; the lines are committed.
- **Halina untouched.** Do not append anything to `dialogue_samples_halina_sikorska.jsonl`. Halina is absent in V1.7.
- **No stray staging-direction text in JSONL.** Voice-reference files hold spoken lines only. Stage directions belong only inside the dialogue file (`postcard_swine_ch1.json`) if its schema supports them, or omit.

## Output

When done, report:

1. Files modified or created, with paths.
2. Number of lines appended per JSONL file.
3. Manifest diff (the two changed entries).
4. Voice-audit result (clean / flags listed verbatim).

Do not summarise the V1.7 narrative content. The point of this run is the commit, not the literary work.
