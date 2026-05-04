# Tools

Project automation. Run from the repo root.

## `voice_audit.py` — voice-reference JSONL auditor

Mechanical audit for the per-character dialogue-sample JSONLs produced by
ChatGPT (or any source). Catches the regex-detectable defects in seconds;
flags the rest for human / LLM follow-up.

### What it catches

- **Text normalization** — curly quotes, curly apostrophes, ellipsis, `\r\n`,
  trailing whitespace, missing trailing newline, NFC.
- **JSON validity** per record.
- **Schema** — required fields present (`record_type`, `id`, `character_id`,
  `speaker`, `text`).
- **Rule A (canonical names)** — `Dr. Cula` (no A.), legacy `Kula`/`Muraś`/
  `Rak`/`Wymysl`, unknown speakers.
- **Rule B (address forms)** — `speaker`-aware. Inner-circle (Cula, Crab,
  Whimsy) say `Murrow`; everyone else says `Mr. Murrow`. Crab and Whimsy
  may say bare `Cula` (post-recruitment); everyone else says `Dr. A. Cula`.
  Cula in Chapter 1 with first-meeting-shaped scene context is flagged
  `POSSIBLE_FIRST_MEETING` for human review.
- **Out-of-scope content** — references to Scooter Racing or Ski Slalom;
  Final Printer mistagged as `minigame` instead of `casebook_battle`.
- **Duplicate file detection** by content hash (catches re-uploads like the
  `dr_a_cula-86d3cee4.jsonl` situation).

### What it does NOT catch

These need LLM judgment, not regex:

- Taste Standard pass/fail per line.
- Canon-fit on character voice profiles (e.g., "is Mr. Pig's maritime tic
  used at the right rate?").
- Whether a `POSSIBLE_FIRST_MEETING` flag is actually the canonical first
  meeting or just another Cula-Murrow scene.
- Voice drift across files (e.g., is Whimsy more theatrical in Chapter 5
  than Chapter 1 in a way that fits his arc?).

The script flags candidates; one focused Sonnet 4.5 invocation reviews
the ~10% that genuinely needs judgment. See "Suggested workflow" below.

### Usage

```bash
# Audit only — produces a markdown report on stdout.
python tools/voice_audit.py path/to/uploads/*.jsonl

# Audit + apply text normalization in place.
python tools/voice_audit.py --normalize-in-place path/to/uploads/*.jsonl

# Write the report to a file.
python tools/voice_audit.py \
    --output godot/VOICE_AUDIT.md \
    path/to/uploads/*.jsonl

# Audit a whole directory.
python tools/voice_audit.py path/to/uploads/

# JSON output (for piping into other tools).
python tools/voice_audit.py --report-format json path/to/uploads/*.jsonl
```

### Exit codes

- `0` — clean (no violations, no JSON errors).
- `1` — violations found.
- `2` — JSON errors or invocation problem.

Suitable for a pre-commit hook or CI step once the voice-references
directory exists.

### Suggested workflow

For each batch of new ChatGPT JSONLs:

1. Save them to `uploads/` (or wherever).
2. Run normalization + audit:
   ```bash
   python tools/voice_audit.py \
       --normalize-in-place \
       --output godot/VOICE_AUDIT.md \
       uploads/*.jsonl
   ```
3. Open `godot/VOICE_AUDIT.md`. Review violations.
4. **Fix the trivial ones** (Rule A "Dr. Cula" → "Dr. A. Cula", bare
   "Murrow" said by outer-circle, etc.) by hand or with `sed` per file.
   Re-run the audit.
5. **Triage the `POSSIBLE_FIRST_MEETING` flags**: usually 1–2 per Cula
   file. Open each, verify it's the Beat 3 first-meeting context, leave
   if so, fix if not.
6. **For canon-fit and Taste Standard checks** on what remains: fire
   one focused Sonnet 4.5 prompt per file, scoped to the violations the
   script couldn't decide. Template lives in
   `godot/.antigravity/skills/design.md` §Voice review.

### Adding new canonical names

Edit the `CANONICAL_SPEAKERS` set at the top of `voice_audit.py`. The
script flags any speaker not in the set so new chapter NPCs surface
loudly the first time their JSONL lands.

### Limitations / known false positives

- The first-meeting heuristic is regex over `scene` + `context`. If a
  Cula-says-Mr.-Murrow line lives in a scene named something the
  heuristic doesn't match, it surfaces as a hard violation rather than
  a soft `POSSIBLE_FIRST_MEETING`. Worth a manual scan of Cula's Chapter 1
  output.
- "Bare Murrow" inside a single string that *also* contains "Mr. Murrow"
  passes (the regex is line-level). If a single line has both forms,
  one of them is wrong; spot-check Cula's Chapter 1.
- The script doesn't validate the `expressions` field against the
  per-character profile — ChatGPT sometimes adds expressions like
  `concerned` for an NPC whose declared expression set is
  `[neutral, dry, stern]`. Add `--strict-expressions` later if this
  matters.
