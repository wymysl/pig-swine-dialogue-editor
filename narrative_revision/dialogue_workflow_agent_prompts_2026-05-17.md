# Dialogue Workflow — Agent Prompts (2026-05-17)

Companion to `dialogue_workflow_assessment_2026-05-17.md`. Each task below maps to one `Agent` invocation. Prompts are self-contained so the agent does not need the parent conversation.

Model legend (Anthropic API strings — pass as the Agent `model` parameter using the shorthand `opus` / `sonnet` / `haiku`):

- `opus` (claude-opus-4-6) — taste-heavy, judgment-heavy work; per-line evaluation; voice nuance on Murrow/Halina/Crab.
- `sonnet` (claude-sonnet-4-6) — bulk drafting, voice passes, structural rewrites, code edits.
- `haiku` (claude-haiku-4-5) — quick mechanical scans, JSON validation, inventory diffs, schema checks.

Subagent legend:

- `Explore` — read-only search; use for inventory and audit passes that don't write.
- `general-purpose` — drafting, editing, multi-step writes.
- `Plan` — design planning before destructive changes (Phase 0 cleanup, Murrow split).

## Phase 0 — Stage cleanup (one-time)

### 0.1 — Draft inventory diff scan

Model: `haiku`. Subagent: `Explore`.

```
Scan godot/data/_drafts/ and godot/data/dialogues/_drafts/. For each file, determine
its status against the committed canonical file in godot/data/dialogues/. Output one
Markdown table with columns: draft_path, target_canonical_file, status, evidence,
recommendation.

Status values:
  ABSORBED      — content present in canonical file; draft can be deleted.
  PENDING       — content not present in canonical; promotion required.
  SUPERSEDED    — earlier version of an absorbed redesign; delete.
  STUB          — explicit inert stub; git rm.
  EXPLORATORY   — alternate architecture not selected; archive or delete.

Evidence: cite the specific state ids or content blocks that prove the status (e.g.
"crab.json::first_meeting_with_binder contains the line 'Postal theatre.' which
matches _drafts/crab_player_driven_final_2026-05-16.json line 47 — ABSORBED").

Do NOT modify any file. Output only the table.

Files to consult for canonical content:
  godot/data/dialogues/{pig,murrow,crab,whimsy,asia,asia_hint_states_ch1,
    halina,judge_district_ch1,postcard_swine_ch1,barista}.json

Report length cap: under 800 words.
```

### 0.2 — Cleanup execution

Model: `sonnet`. Subagent: `general-purpose`. Run AFTER 0.1 returns and the human
approves the recommendations.

```
Execute the deletions and renames listed in the approved inventory table at
narrative_revision/draft_inventory_<date>.md (artifact from task 0.1).

Rules:
- For STUB and SUPERSEDED files: use git rm.
- For ABSORBED files: confirm with diff -q against the cited canonical state ids;
  if identical content present in canonical, use git rm. If content differs, STOP
  and report the diff.
- For EXPLORATORY files: move to godot/data/_drafts/_archive/<date>/.
- For PENDING files: leave in place; add a _status field if missing.

Do NOT touch godot/data/dialogues/*.json or godot/data/*.json (canonical) — this
task only mutates the staging area.

End by appending a one-paragraph entry to godot/SPRINT_LOG.md describing what was
deleted/moved.

Required reading before starting:
  AGENTS.md (root), godot/AGENTS.md, godot/data/dialogues/_schema.md.
```

## Phase 1 — Beat brief (human-authored, Claude reviews)

### 1.1 — Beat brief sanity check

Model: `sonnet`. Subagent: `Explore`. Run after the human writes
`narrative_revision/beats/<beatN>_<topic>.md`.

```
Review the beat brief at narrative_revision/beats/<BEAT_FILE>.md against the canon
sources. Verify each item is present and correct. Report only mismatches; do not
restate what is correct.

Checks:
1. Story-spec quote matches story.txt §Beat <N> verbatim.
2. Cast list matches AGENTS.md §Cast — canonical names.
3. Address forms for each cast member match AGENTS.md §Address forms for the
   chapter beat context.
4. Incoming flags exist in state.gd reset_state() (godot/scripts/autoload/state.gd).
5. Outgoing flags exist in state.gd reset_state() OR are flagged as new flags
   requiring a Code task.
6. Doctrinal anchor maps to a real KPC / KPK / KPA / institutional fact (parody
   real procedure or halt — godot/AGENTS.md §Humor rules).
7. Length budget is present: target lines per state, hard cap, max NPC lines
   before Cula interject.

Output format: one "MISMATCH: <field> — <evidence> — <fix>" line per finding, plus
a final "READY TO DRAFT" or "NEEDS REVISION" verdict. Under 400 words.

Required reading: AGENTS.md (root), godot/AGENTS.md, story.txt, state.gd.
```

## Phase 2 — Draft

### 2.1 — Per-beat NPC draft

Model: `sonnet` (default) or `opus` (for emotionally complex beats — client
meetings, refusals, court-room reveals). Subagent: `general-purpose`.

```
Draft a Chapter <N> Beat <N> dialogue file for <NPC>. Output to
godot/data/_drafts/beat<N>_<npc>_<YYYY-MM-DD>.json. The file is NOT loaded by the
dialogue runner (subdirectory and date-suffix conventions both keep it inert);
draft freely.

Read first, in this order:
  1. AGENTS.md (root) and godot/AGENTS.md — operating constitution.
  2. godot/data/dialogues/_schema.md — JSON shape and trigger grammar.
  3. story.txt §Beat <N> — canonical spec.
  4. narrative_revision/beats/<beatN>_<topic>.md — the beat brief.
  5. narrative_revision/voice_agents/<npc>.md — voice bible.
  6. narrative_revision/ai_voice_constraints.md — anti-AI-voice discipline.
  7. godot/data/voice_references/<npc>.jsonl — voice reference lines.
  8. godot/data/dialogues/<npc>.json — current canonical (to avoid id collisions
     and to match in-place patterns).

Drafting rules (load-bearing):
  A. Each state body MUST cap at 8 NPC lines before a Cula interject. If more
     content is needed, split the state. Cula's interjects are
     {"speaker": "cula", "text": "..."} lines.
  B. Every Cula option must trigger a player-visible change within two beats.
     No "Right." / "Understood." options unless they enable chain:true to a
     meaningfully different state.
  C. Each multi-line state lands at least two jokes. Use the character's pet
     idiom — Pig=maritime, Crab=gear-shift closer, Whimsy=declamation, Murrow=
     single archival adjective load-bearing, Asia=domestic-admin observation,
     Halina=plain dignified factuality.
  D. Address forms verified inline in each state's _comment with the AGENTS.md
     rule cited.
  E. State ids globally unique across the entire dialogues directory. Prefix
     with the npc when collision risk exists.
  F. No contrastive antithesis. No em-dashes outside characters whose voice
     authorises one per line. No scrub-list vocabulary (see ai_voice_constraints).

Required fields per state:
  id, trigger, lines (or silent:true), and a _comment that names the source
  spec, the voice anchor, and the address-form rule.

Optional fields used in this corpus:
  options (with write_path, choices[], optional trust_path, optional chain),
  on_dismiss, once, tags.

Output a complete JSON file with a top-level _draft_note, _beat_ref, _flags_used,
and a states[] array. Do not output prose outside the file. Validate JSON before
returning.
```

### 2.2 — Per-beat multi-NPC choreography draft

Model: `opus`. Subagent: `general-purpose`. Use for beats where multiple NPCs
share a state (Halina client meeting, court readiness check, Beat 13 celebration).

```
Same as 2.1, plus:

This beat has multiple speakers in one state. Use per-line {"speaker": "<id>",
"text": "..."} blocks for every line in the multi-speaker state. The state-level
"speaker" field sets the default speaker for plain-string lines; mixed states
must use explicit per-line speakers to remove ambiguity.

Turn-taking rule: no NPC speaks more than 3 consecutive lines in a multi-speaker
state. If the spec requires a longer monologue, break the state in two with a
chain:true Cula interject between them.

If the beat carries a trust meter, mirror halina.json's pattern: an `options`
block with both write_path (the carrier flag) and trust_path (the integer
counter), and trust_delta per choice. Tier-gated response states follow,
ordered specific-trigger-first.
```

## Phase 3 — Voice pass

### 3.1 — Per-character voice pass

Model: `opus` (Murrow, Halina, Crab — voice is delicate) or `sonnet` (Pig,
Whimsy, Asia, judge). Subagent: `general-purpose`.

```
Voice-pass the dialogue draft at <DRAFT_PATH> for <NPC>. Modify only <NPC>'s
lines; leave other speakers' lines untouched.

Read first:
  1. narrative_revision/voice_agents/<npc>.md — the voice bible. This is the
     authority for register, calibration anchors, and forbidden moves.
  2. narrative_revision/ai_voice_constraints.md — anti-AI-voice discipline.
  3. godot/data/voice_references/<npc>.jsonl — voice reference lines (not
     committed game text; calibration only).
  4. style_canon.txt §<NPC> if present.

Two cuts to apply:

CUT 1 — remove redundancy. If a fact appears in this NPC's lines that another
NPC owns (Murrow=docket, Crab=envelope, Whimsy=civic records, Halina=her own
paperwork), remove it here. If two of this NPC's own lines say the same thing
in different words, keep the sharper one and cut the other.

CUT 2 — restore voice. For each multi-line state, ensure at least one line lands
the character's pet idiom (Pig=maritime, Crab=gear-shift closer, Whimsy=
declamation, Murrow=single load-bearing adjective, Asia=domestic-admin, Halina=
plain dignified factuality). If absent, insert one. If two-clause sentence
rhythms are flat, vary.

CUT 3 — anti-AI scan. Strip any contrastive antithesis ("X, not Y" / "A, but B"
constructions used for rhetorical balance). Strip em-dashes beyond the voice
bible's quota. Strip scrub-list vocabulary (the ai_voice_constraints document
lists these).

Do NOT change state ids, triggers, on_dismiss writes, or option write_paths.
Do NOT change other characters' lines. Do NOT add or remove states.

Append a _voice_pass_<YYYY-MM-DD> field to the file's top-level object
summarising in 3-6 bullets: lines cut, lines added, idioms restored, AI-voice
slips fixed.

Output the full updated JSON file (in place). No prose response outside the file.
```

## Phase 4 — Choice audit

### 4.1 — Cross-file choice payoff audit

Model: `opus`. Subagent: `Explore`. Read-only.

```
Audit every `options` block in godot/data/dialogues/*.json (canonical files,
not drafts). For each choice in each block, produce a one-line entry:

  <file>::<state_id>::"<choice_text>" → writes <write_path>=<value>; visible
  downstream payoff: <yes|no>; evidence: <state_id where payoff is visible>.

A "visible downstream payoff" means at least one of:
  - An NPC line that conditionally fires based on this write_path/value, AND
    that line references the choice or its consequence in fiction (not just
    a flag flip the courtroom system reads).
  - A Casebook system reaction the player sees (battle modifier text, judge
    remedy text, Asia hint).
  - A flavor change two beats later that the player can perceive.

For each choice marked NO, give a one-sentence diagnosis: is the choice fake
(should be removed), cosmetic (should add a downstream beat), or already
mechanically wired but invisible in dialogue (needs an Asia hint or NPC reaction
line).

Also audit each option block holistically: does the WORST option still have
voice? (It should sound like a tempting wrong call, not an obvious-do-not-click
checklist false.) If not, name which option needs rewriting.

Output: one Markdown report at narrative_revision/audit/choice_payoff_<YYYY-MM-DD>.md.
Group by file. Verdict line at top of each file's section: "READY", "REVISE",
or "CUT CHOICES".

Required reading: AGENTS.md, godot/data/dialogues/_schema.md. Walk every
canonical .json in godot/data/dialogues/ (skip the _drafts/ subdirectory).
```

## Phase 5 — Taste Standard 5/5

### 5.1 — Per-state Taste Standard scoring

Model: `opus`. Subagent: `general-purpose`. Run AFTER the voice pass.

```
Score every NPC line in the draft at <DRAFT_PATH> against the Taste Standard
from godot/AGENTS.md §The Taste Standard:

  1. Laugh    — there is something funny in it.
  2. Clever   — the funny thing has a real referent (procedural rule, Polish
                legal absurdity, recurring office detail). Not random absurdity.
  3. Alive    — sounds like a person, not a system message.
  4. Clear    — player understands meaning and next step.
  5. Future-proof — does not break when later chapters add context.

Pass = 5/5. 4/5 revise. 3/5 cut. "Clear" can be relaxed for deliberate confusion
the next NPC clears up.

For each STATE in the draft, output:

  state_id: <id>
  verdict: <SHIP | REVISE | CUT>
  per-line scores: array of {line_index, line_excerpt, L, C, A, Cl, FP, notes}
  state-level notes: <one paragraph if REVISE/CUT, naming the fix>

Skip Cula's interject lines (audited separately as Cula voice work — Cula's
lines are player mouthpiece, not subject to the Laugh criterion).

Output: append a top-level _taste_standard_<YYYY-MM-DD> field to the draft JSON
with the per-state structure above. Do NOT modify state content; this is a
review pass, not an edit pass.

Required reading: godot/AGENTS.md §Taste Standard and §Humor rules.
```

## Phase 6 — Promote draft to canonical

### 6.1 — Mechanical merge

Model: `sonnet`. Subagent: `general-purpose`.

```
Promote the draft at <DRAFT_PATH> into the canonical file at
godot/data/dialogues/<NPC>.json.

The draft contains a top-level "_merge_strategy" field describing what to append
vs. what to replace. Honor it exactly. If absent, default rules:
  - States with ids not present in the canonical: append at end of states[].
  - States with ids already present in the canonical: STOP and report; do not
    silently replace.

For each promoted state, fold the draft's _voice_pass / _taste_standard / _provenance
fields into the canonical state's _comment as a brief in-place note (under 400
chars). Do not drop authoring context entirely; do not keep multi-kilobyte
provenance blocks.

After merge:
  1. Run `node tools/verify_dialogue_roundtrip.js` (schema + round-trip check).
  2. Run `godot --headless --path godot --script tests/test_smoke.gd`.
  3. If both pass: git rm the draft and add a one-paragraph SPRINT_LOG.md entry.
  4. If either fails: revert the merge, report the failure, do NOT delete the
     draft.

Required reading: godot/data/dialogues/_schema.md, AGENTS.md §Save And State
Policy (if the draft introduces new flags).
```

## Phase 7 — Validate

### 7.1 — Dialogue corpus health check

Model: `haiku`. Subagent: `general-purpose`.

```
Run the full validation pass against godot/data/dialogues/:

  1. `node tools/verify_dialogue_roundtrip.js` — schema + round-trip.
  2. `python tools/voice_audit.py godot/data/voice_references/` — voice audit
     (currently only audits voice_references; extension to scan dialogues/ is
     a separate task — task 9.2 below).
  3. `godot --headless --path godot --script tests/test_smoke.gd --log-file
     /tmp/pig_swine_smoke.log` — loads project, parses every script, runs
     Main.tscn one frame.
  4. `godot --headless --path godot --script tests/test_runner.gd` — GUT.
  5. `godot --headless --path godot --export-release "Web" exports/web/index.html` —
     clean web export.

Report each as PASS / FAIL with stderr excerpt on FAIL. Do not attempt fixes;
this is a read-only health report.

If any test reports "Workspace still starting" or a Godot userdata permissions
crash (signal 11 in RotatedFileLogger), retry once with --log-file passed and
note the workaround in the report.
```

## Phase 8 — Playtest log analysis

### 8.1 — Cold-read the captured dialogue log

Model: `opus`. Subagent: `general-purpose`.

```
The human has played Chapter 1 in headed Godot and captured the dialogue log
at <LOG_PATH>. Read it cold (do not consult the source JSON files yet) and
produce three lists:

  TEDIUM — points where the prose drags. State ids if identifiable; quoted
    excerpts if not. One sentence per item naming the specific drag.
  REDUNDANCY — facts read aloud more than once by the same or different NPCs.
    Cite both occurrences.
  VOICE SLIPS — lines that broke character. Quote the line, name the NPC,
    name the slip (wrong register, AI-voice tell, scrub vocabulary, address
    form, contrastive antithesis).

Only AFTER producing those three lists from the log alone, consult the source
JSON to identify the exact state ids and propose targeted patches. Output
patches as a unified list at the bottom of the report: <file>::<state_id>::
<fix one-liner>.

Output: narrative_revision/audit/playtest_<YYYY-MM-DD>.md. Under 1500 words.

Required reading AFTER the cold-read: AGENTS.md (root), godot/AGENTS.md,
voice_agents/ for any character whose lines you patch.
```

## Tooling tasks

### 9.1 — Author `tools/draft_index.py`

Model: `sonnet`. Subagent: `general-purpose`. Code role.

```
Write a Python script at tools/draft_index.py. Behavior:

  - Walk godot/data/_drafts/ and godot/data/dialogues/_drafts/.
  - For each .json file: parse, extract npc_id, version, _status (if present),
    file mtime, file size in lines.
  - For each draft, compute a "absorbed?" heuristic: hash N representative
    state ids from the draft, search godot/data/dialogues/<npc_id>.json for the
    same ids; report match count and percentage.
  - Output a Markdown table to stdout with columns:
      path | npc_id | version | age_days | size_lines | absorbed_pct | status | flag
  - "flag" column: STUB (size_lines < 10), STALE (age_days > 14), ABSORBED
    (absorbed_pct > 80), PENDING (none of the above).

Conventions: typed function signatures where it costs nothing; standard library
only (no pip installs); fail loud on JSON parse errors. Add a --json output mode
so other scripts can consume.

Add a tests/test_draft_index.py with one fixture in tests/fixtures/draft_index/
containing one absorbed draft, one stub, one stale, one pending. Assert the
script returns the expected flag for each.

Required reading: AGENTS.md (root) §Repository Map, godot/AGENTS.md §File
ownership table (tools/ is repo-level helper scripts).
```

### 9.2 — Author `tools/choice_audit.py`

Model: `sonnet`. Subagent: `general-purpose`. Code role.

```
Write a Python script at tools/choice_audit.py. Behavior:

  - Walk godot/data/dialogues/*.json.
  - For each state with an `options` block: extract write_path and trust_path.
  - For each write_path: scan every other state's trigger expression in every
    .json under godot/data/dialogues/ for references to that path. Also scan
    godot/data/argument_opponents.json, godot/data/judgments.json, and
    godot/data/chapters/*.json for references.
  - Report:
      - "Fake choice": write_path is never referenced anywhere downstream.
        File, state_id, write_path.
      - "Cosmetic differentiation": write_path is referenced only by another
        option's write_path consumer (a flag that flips a flag, no in-fiction
        reader). Lower-priority flag.
      - "Mechanical only": write_path is referenced only by .gd files (Casebook
        battle controller) — no in-dialogue reader. Note as soft-flag.

Output: Markdown to stdout. Exit 0 if no Fake choices; exit 1 if any. Add
--json mode.

Add a test in tests/test_choice_audit.py with a fixture demonstrating each
category.

Required reading: godot/data/dialogues/_schema.md §Trigger grammar.
```

### 9.3 — Extend `tools/voice_audit.py` for dialogues

Model: `sonnet`. Subagent: `general-purpose`. Code role.

```
Extend tools/voice_audit.py to scan godot/data/dialogues/*.json in addition to
godot/data/voice_references/*.jsonl. Add a CLI flag --scope=dialogues,refs,both
(default: both).

For each line in each state, run the existing address-form rules (Rule A and
Rule B per the project memory: speaker field on JSONL is authoritative; lookbehind
excludes "Dr. Cula."; MURROW_PRIVATE_SCENE_HINTS controls bare-Cula scenes).

Add four new heuristics:
  - Adjective load per line (warn if > 3 adjectives in one sentence).
  - Em-dash count per line (warn if a line uses more em-dashes than the
    character's voice bible permits; load per-character allowances from
    narrative_revision/voice_agents/<npc>.md frontmatter).
  - Contrastive-antithesis detection: regex over "not <X>, but <Y>" and
    semicolon-bridged antitheses. Warn, not error — false positives are real.
  - Scrub-list vocabulary: load the list from narrative_revision/ai_voice_constraints.md
    and warn on any hit.

All new checks: warn, not fail, on first run; toggleable to error via
--strict.

Required reading: existing tools/voice_audit.py source; project memory entry
"reference_pig_swine_voice_audit.md" rules.
```

### 9.4 — Author `tests/test_dialogue_lengths.gd`

Model: `sonnet`. Subagent: `general-purpose`. QA role.

```
Write a GDScript test at godot/tests/test_dialogue_lengths.gd that fails if
any state in godot/data/dialogues/*.json violates the length budget:

  - Hard cap: a state has more than 8 consecutive NPC lines before a Cula
    interject. (Cula interject = a line whose speaker is "cula".)
  - Soft warn: a state has more than 12 total lines.

The test loads every .json in godot/data/dialogues/ (excluding the _drafts/
subdirectory, which the runner already skips). For each state with a lines[]
array, walk the array tracking consecutive-non-cula-line count; reset to 0
on a cula line.

Use the existing test_smoke.gd / test_runner.gd shape — GUT or the project's
test convention, whichever the existing tests use.

Required reading: godot/tests/test_smoke.gd, godot/AGENTS.md §Hard build
invariants, godot/data/dialogues/_schema.md.
```

### 9.5 — Author `tests/test_choice_payoff.gd`

Model: `sonnet`. Subagent: `general-purpose`. QA role.

```
Write a GDScript test at godot/tests/test_choice_payoff.gd that asserts: for
every state in godot/data/dialogues/*.json that has an `options` block with
choices, at least one other state's trigger expression references the
options.write_path.

Caveat: the courtroom controller reads write_paths from .gd files (see
godot/scripts/systems/battle/battle_controller.gd). If a write_path is read
ONLY by .gd code and not by any dialogue trigger, downgrade from FAIL to WARN
with a note that the path has Code-side readers but no in-dialogue reader.

Required reading: godot/data/dialogues/_schema.md §Trigger grammar.
```

## One-off tasks

### 10.1 — Split `murrow_first_meeting`

Model: `opus`. Subagent: `general-purpose`. Paired Code+Design.

```
godot/data/dialogues/murrow.json::murrow_first_meeting currently fires 8
NPC monologue lines before Cula's first interject. Per the length budget in
narrative_revision/dialogue_workflow_assessment_2026-05-17.md §3.6, this state
must be split.

Proposal:
  - State A "murrow_first_meeting_briefing" — lines 1-7 (the four file facts +
    the two doctrinal pointers + the binder pointer). on_dismiss writes
    met_murrow=false (still), surfaced_notice_timeline=true,
    surfaced_tenancy_act_window=true. NO friend-form invitation yet. chain:true.
  - State B "murrow_first_meeting_invitation" — the friend-invitation
    calibration (verbatim from current state lines 12-15: "It is Murrow, to
    friends. The 'Mister' I keep for invoices." / Cula's "Then it's Cula." /
    Murrow's reception-staff hedge / Cula's "She'll be relieved either way."
    / Murrow's binder-first-Crab-second closer). on_dismiss writes met_murrow
    =true, element_timely_actual_notice_motion=true, element_no_third_party_cure
    =true.

Between A and B: a chain:true via state-level chain flag on A, with B's
trigger reading the new flag A sets. Specifically: A sets a transient flag
murrow_briefing_done; B's trigger requires murrow_briefing_done && !met_murrow.

Cula's existing question "The resident at number seven. Does his accepting
the notice cure service?" + Murrow's "No. Express authority is required. He
had none." sits at the END of state A (before chain to B), not between the
binder-pointer and the friend-invitation. This is the deliberate Cula
interject the split creates.

Code task (paired): declare chapter1.murrow_briefing_done in State.reset_state(),
bump SAVE_VERSION (current is 13 per memory; raise to 14), add migration step
in scripts/systems/save.gd, add a migration test asserting SAVE_VERSION >= 14
on previous fixture.

Required reading: godot/AGENTS.md §Save migration policy, godot/AGENTS.md §First
meeting introductions (the murrow_first_meeting beat is one of the named
introductions; the split must not let an inventory-handoff line stand as
first word between Cula and Murrow — the briefing IS the first-meeting beat).

Output: edits to godot/data/dialogues/murrow.json (split + chain wiring),
godot/scripts/autoload/state.gd (flag declaration, version bump),
godot/scripts/systems/save.gd (migration), godot/tests/test_save_load.gd
(migration test using previous fixture). Run smoke + save-migration tests.
```

### 10.2 — Decoy option voice rewrite

Model: `opus`. Subagent: `general-purpose`.

```
The decoy option text in godot/data/dialogues/{murrow,crab,whimsy}.json reads
as checklist toggles ("Leave it out / Include it in the alternative"). Per the
assessment §3.2, each option must (a) carry voice, and (b) make the wrong
option sound tempting-but-misled rather than obviously-wrong.

Affected option blocks:
  - murrow.json::murrow_first_meeting_decoy_notice_period
  - murrow.json::murrow_archive_walkthrough_decoy_merits
  - whimsy.json::whimsy_before_meeting_decoy_standing
  - whimsy.json::whimsy_before_meeting_decoy_overbroad_remedy
  - crab.json::crab_post_halina_incapacity_offer
  - The three reply/setup states feeding into these.

For each option pair, rewrite:
  - The "do not include" choice carries Cula's procedural discipline in his
    voice. It should NOT be flavored as obviously correct; it should sound
    like a Cula who has done the math and is choosing the narrow ask.
  - The "include" choice carries the rhetorical or precautionary temptation
    that makes the wrong call legible. It should sound like the player has a
    real reason to click it. Use the offering NPC's pet idiom slightly tilted
    — Murrow's archival precaution; Whimsy's theatrical reach; Crab's
    insurance-via-completeness.

Do NOT change write_path or values. Do NOT change trust_delta if present.
Do NOT touch surrounding lines or other states.

After: append _voice_pass_decoys_<YYYY-MM-DD> to each file's top-level object.

Required reading: narrative_revision/voice_agents/{murrow,crab,whimsy}.md;
PROPOSAL_player_driven_argument.md (referenced in the existing _provenance
fields) for decoy-mechanic intent.
```

### 10.3 — Decoy refusal differentiation

Model: `opus`. Subagent: `general-purpose`.

```
The cold pushback states firing when chapter1.decoy_incapacity == true currently
sound similar across NPCs. Sharpen per-voice framings.

Affected states:
  - murrow.json::murrow_post_decoy_incapacity
  - crab.json::crab_post_halina_incapacity_refuses
  - whimsy.json::whimsy_post_decoy_incapacity
  - halina.json::halina_post_meeting_decoy_incapacity_cold
  - asia_hint_states_ch1.json::hint_decoy_incapacity_office_chill

Whimsy's "I sing for the case. I do not sing for that." is the strongest model
— a refusal that lands in the character's pet idiom rather than as a
generic ethical objection. Use that as the bar.

For each affected state:
  - Identify the character's pet idiom (archive/file/post/song/desk).
  - Rewrite the refusal so it refuses IN the idiom. Murrow refuses as
    archival fact ("the file does not support this"); Crab refuses as
    procedural inventory ("the elements do not stack that way"); Halina
    refuses as dignity ("I have lived in that flat since nineteen eighty-seven");
    Asia refuses as withheld warmth (a domestic-admin observation with the
    warmth temperature dropped a notch).
  - Each refusal under 80 words. Crab's current three-paragraph version trims.

Address forms: all refusals SUSPEND the friend-form (Murrow returns to
"Doctor Cula", Crab returns to "Dr. A. Cula"). Asia and Halina already use
"Dr. A. Cula" — keep.

Do not change triggers or on_dismiss writes. Append _voice_pass_refusals
notes.

Required reading: narrative_revision/voice_agents/<npc>.md for each;
ai_voice_constraints.md.
```

### 10.4 — Cula voice strengthening

Model: `sonnet`. Subagent: `general-purpose`.

```
Across godot/data/dialogues/{murrow,crab,whimsy,pig,asia}.json, audit every
{"speaker": "cula", "text": "..."} line. Replace placeholder Cula lines
("Right.", "Working on it.", "Understood.", "Hm.") with one-line questions
or observations that show the player Cula has read the room. Cula's voice
register: junior, sharp, neither sycophantic nor combative, with one beat
of dry humor permitted per scene.

Cap: each replaced line stays at one short sentence (under 12 words). Do
not turn Cula's interjects into monologues — interject is the function.

Halina meeting Cula lines are exempt — already strong.

Address forms for Cula's lines:
  - Cula to Murrow: "Mr. Murrow" before the friend-invitation; "Murrow" after.
  - Cula to Crab/Whimsy: "Crab" / "Whimsy" (no honorific, post-introductions).
  - Cula to Pig: "Mr. Pig" always.
  - Cula to Asia: no name needed for one-line interjects.
  - Cula to Halina: "Mrs. Sikorska" always.

Output: in-place edits. Append _cula_voice_pass_<YYYY-MM-DD> top-level field
listing the (file, state_id, line_index) tuples changed and the rationale.

Required reading: AGENTS.md §Address forms; narrative_revision/voice_agents/
cula.md if present (cula.md is in the directory).
```

## Orchestration notes

Run order for a single beat from scratch:
  1.1 → 2.1 (or 2.2) → 3.1 (per character) → 4.1 → 5.1 → 6.1 → 7.1

Run order for the current corpus (one-time):
  0.1 → 0.2 → 9.1 → 9.2 → 9.3 → 9.4 → 9.5 → 10.1 → 10.2 → 10.3 → 10.4 → 4.1 → 7.1

Parallelism: 3.1 per character can fan out — six parallel `general-purpose` agents
on six characters. 2.1 per beat similarly fans out by NPC. 0.1 and 5.1 are
single-threaded by file.

When in doubt about which model: pick `sonnet` for drafting and `opus` for
final-pass judgment. `haiku` only for inventory-shaped scans where the answer
is mostly file metadata.
