# Workflow Analysis — 2026-05-16

> Automated run. Reversibility snapshot committed (`ab969b1`; no index.lock
> detected this run — the persistent three-night lock appears to have cleared).
> No source files modified by this agent.

---

## Velocity

**~70+ named session entries across 13 calendar days (2026-05-04 → 2026-05-16).**
The sprint log contains sessions 1 through 44 today, plus sub-sessions (9b–9r,
8.5–8.12, addenda for Sessions 30/34/36), totalling roughly 70–75 distinct
logged passes.

Git cadence by date, from `git log --oneline`:

| Date | Commits | Character |
|------|---------|-----------|
| 2026-05-04 | 4 | Bootstrap (autoloads, dialogue runner, room transition) |
| 2026-05-05 | 5 | NPC system, pickups, sprint, typewriter |
| 2026-05-08 | 8 | Office layout iteration (8 sub-sessions) |
| 2026-05-11–12 | ~36 | Sprite passes, coffee minigame, spec sessions, court-round proposal |
| 2026-05-13–14 | ~11 | Schema refactors, orphan cleanup, address-form fixes |
| 2026-05-15 | 3 | Registry catch-up, MCP visual playtest, Dialogue Editor hardening |
| 2026-05-16 | 9 | Full motion-packet pipeline (proposal → state → UI → court wiring), NPC draft rewrites, judge dialogue |

**Trend: output per session declining, structural value per session increasing.**
Sessions 1–10 produced core scaffolding. Sessions 28–38 produced maintenance and
data integrity. Sessions 39–44 produced the most concentrated feature-assembly
day in the project: `PROPOSAL_player_driven_argument.md` v3, SAVE_VERSION 17→18→19,
BlueBinder UI, `battle_controller.gd` restored and wired to packet, court scoring
complete — all in one calendar day. The overnight nightly cohort (agents 1, 3, 4, 7, 8)
added judge dialogue, NPC voice-pack rewrites, and the Asia hint surface.

The vertical-slice plan's steps 4 (Casebook Battle System v1) and 5 (Court + payoff)
have now been substantially assembled. PLAN.md's `store.session` budget was ~14–20;
actual count is at 70+ because the definition of "session" collapsed to "one
autonomous agent pass." Human-time investment is still in range.

---

## Top Recurring Friction

**1. macOS TCC blocking visual verification — 10+ sprint-log entries;
partially resolved 2026-05-15.** `mcp__godot__run_project` bypasses the TCC
crash and caught a real runtime startup error (`trust_path: "asia"` in
`asia.json::cula_approach`) that all 38+ headless tests missed. Session 39b
is the proof of concept. The BUILD_NOTES.md Session 7 visual checklist (five
bullets: NPC sprites, two pickups, repeat-room suppression, coffee stub
round-trip, save/load) has been outstanding for 11 days without a single
checkbox confirmed. This is the oldest open visual debt in the project.

Concrete mitigation: (a) add `mcp__godot__run_project` + debug-output grep to
the nightly health-check agent as a first-class check alongside JSON validity
and voice audit; (b) add to `godot/MANAGING_AGENTS.md` §Daily flow: *"Before
every sprint session, run `mcp__godot__run_project` and grep debug output for
`push_error`. If any found, fix before proceeding."*

**2. Godot binary absent from nightly sandbox — persistent across all 5 nightly
health runs.** Every nightly health report reads `godot: command not found`; all
44 (now 44+) test scripts are SKIPPED. `mcp__godot__run_project` provides a partial
substitute (catches parse errors and startup push_errors as a side effect of
booting), but it cannot run `--script tests/test_*.gd`. The test debt is now
substantial: 44 test files covering save migrations v7→v19, dialogue runner,
battle controller, motion-packet assembly, court scoring — none confirmed by
an automated runner since the last human-run acceptance block.

Literal install path if sandbox image can be extended:
```
wget https://github.com/godotengine/godot/releases/download/4.6.2-stable/Godot_v4.6.2-stable_linux.x86_64.zip
unzip Godot_v4.6.2-stable_linux.x86_64.zip -d /usr/local/bin/
mv /usr/local/bin/Godot_v4.6.2-stable_linux.x86_64 /usr/local/bin/godot
```
Alternatively: `gdtoolkit` (`pip3 install gdtoolkit --break-system-packages`) parses
GDScript syntax without a Godot binary and can replace the smoke-test half of the
missing runs (`gdparse godot/scripts/**/*.gd`). Not a substitute for behavioral
tests, but catches compile errors that currently require a human boot.

**3. Draft promotion queue growing as a structural bottleneck.** Yesterday's
workflow.md named the player-driven argument drafts as a risk. Today the
overnight cohort produced additional "final" variants: `crab_player_driven_final`,
`murrow_player_driven_final`, `whimsy_player_driven_final` (all 2026-05-16).
These are sitting adjacent to the runtime `crab.json`, `murrow.json`, `whimsy.json`
but have not been merged. The motion-packet state machine (Sessions 42–44)
is now fully wired through court, but the NPC dialogue that drives players into
that state machine lives in `_drafts/`, not in live files. Every day without
promotion is a day the code is ready and the content is not.

Mitigation: designate one Design-role session per 3–4 code sessions explicitly
for draft promotion. The promotion step is lower-risk than it feels (each "_final"
draft has passed Taste Standard 5/5 per its authoring agent; voice_audit.py
can confirm mechanically before merge).

---

## Delegated-to-Human Backlog

**Count: ~12 items outstanding** (down from ~17 in yesterday's memo; Sessions 39–44
and today's nightly cohort closed several code-side items).

Items in rough chronological order:

1. **BUILD_NOTES.md Session 7 checklist** (5 sub-items, unchecked since 2026-05-05):
   NPC sprites visible, ProceduralBinder pickup, RightsMemo pickup, repeat-room
   suppression, coffee-machine stub round-trip + save/load. Oldest visual debt.
2. **Visual confirm: office layout 16×9 tiles** (Session 9i, 2026-05-12).
3. **Visual confirm: coffee minigame 2-lane tutorial + 4-lane normal**
   (Session 14, 2026-05-12).
4. **Barista portrait placeholder swap** (Session 16, 2026-05-12).
5. **CONVENTIONS.md drift fix** (Sessions 34/37/38): runtime uses 120 px/s walk,
   112×112 sprites; CONVENTIONS still says 96 px/s and 64×64.
6. **Decide fate of orphan rewrite JSONs** in `godot/data/dialogues/`:
   `pig_rewrite.json`, `asia_rewrite.json`, `murrow_v2.json`,
   `asia_hint_states_ch1_rewrite.json` — flagged ≥5 sessions, blocked because
   `git rm` requires host. Literal command when ready:
   ```
   cd ~/Documents/Silly\ projects/pig-swine-rpg && git rm godot/data/dialogues/pig_rewrite.json godot/data/dialogues/asia_rewrite.json godot/data/dialogues/murrow_v2.json godot/data/dialogues/asia_hint_states_ch1_rewrite.json && git commit -m "Remove orphan dialogue rewrite stubs"
   ```
7. **Delete stale _drafts entries** (sandbox can't `rm` reliably from mount):
   `halina_with_trust_meter.json` (superseded by Session 29; 2 days old);
   three 7-line stub rewrites (`pig_rewrite_2026-05-14.json`,
   `asia_rewrite_2026-05-14.json`, `murrow_v2_2026-05-14.json`).
8. **Promote NPC "final" drafts** into runtime dialogue files — four files:
   `crab_player_driven_final_2026-05-16.json` → `crab.json`,
   `murrow_player_driven_final_2026-05-16.json` → `murrow.json`,
   `whimsy_player_driven_final_2026-05-16.json` → `whimsy.json`,
   `asia_hints_player_driven_2026-05-16.json` → `asia_hint_states_ch1.json`.
9. **Fix `murrow.json::court_readiness_check` "Mr. Cula" → "Dr. A. Cula"**
   and asia.json L33 "Dr. A Cula" period fix (dialogue audit 2026-05-15;
   draft fix in `nightly_dialogue_fixes_2026-05-15.json`).
10. **Fix `murrow.json::after_pig` speaker-attribution bug** — bracketed
    inner-monologue line tagged `speaker: murrow` instead of `speaker: cula`;
    confirm "Ionkionked" spelling/brand.
11. **Register `chapter1.murrow_choice`** in `data/chapters/chapter1.json`
    `new_state_flags` (flagged by Agent 3 today; flag exists in `state.gd`
    reset_state but has no registry entry). Literal JSON line to insert:
    ```json
    {"key": "chapter1.murrow_choice", "default": "", "set_by": "murrow.json options write_path (v16)"}
    ```
    No SAVE_VERSION bump needed — key already exists in runtime.
12. **Delete `test_write` file at repo root** (appeared in today's snapshot
    commit as a stale file; likely sandbox residue): `rm test_write && git rm test_write`.

---

## Draft Promotion Gap

**14 files in `godot/data/_drafts/`** — up from 9 yesterday, driven by today's
nightly cohort.

| File | Type | Age | Status |
|------|------|-----|--------|
| `nightly_design_pig_2026-05-14.json` | Nightly-generated | 2 days | Awaiting Design session |
| `nightly_design_murrow_beat9_2026-05-15.json` | Nightly-generated | 1 day | Ready to promote; no dependency |
| `nightly_dialogue_fixes_2026-05-15.json` | Nightly-generated | 1 day | Two objective fixes; promote immediately |
| `asia_hints_player_driven_2026-05-16.json` | Substantive draft | <1 day | 15 states, 5/5 TS; needs merge protocol |
| `crab_player_driven_final_2026-05-16.json` | Substantive draft | <1 day | Final variant, supersedes -2026-05-15 |
| `murrow_player_driven_final_2026-05-16.json` | Substantive draft | <1 day | Final variant, supersedes -2026-05-15 |
| `whimsy_player_driven_final_2026-05-16.json` | Substantive draft | <1 day | Final variant, supersedes -2026-05-15 |
| `crab_player_driven_2026-05-15.json` | Superseded | 1 day | Delete; _final replaces |
| `murrow_player_driven_2026-05-15.json` | Superseded | 1 day | Delete; _final replaces |
| `whimsy_player_driven_2026-05-15.json` | Superseded | 1 day | Delete; _final replaces |
| `halina_with_trust_meter.json` | Superseded | 2 days | Delete; content in halina.json since Session 29 |
| `pig_rewrite_2026-05-14.json` | 7-line stub | 2 days | Delete |
| `asia_rewrite_2026-05-14.json` | 7-line stub | 2 days | Delete |
| `murrow_v2_2026-05-14.json` | 7-line stub | 2 days | Delete |

**Recommendation:** one cleanup pass deletes 7 files (4 superseded + 3 stubs) and
leaves 7 substantive files awaiting promotion. The promotion of the NPC "final"
variants and Asia hints is the single highest-value Design action this week.
Run `python3 tools/voice_audit.py godot/data/_drafts/crab_player_driven_final_2026-05-16.json`
(and the Murrow/Whimsy/Asia equivalents) to pre-verify before merge.

---

## Stale Proposals

**§9 — Thematic reframe: PENDING, 11 days.** Unchanged. Methodology remains
in chat history only; no `.txt` edits. The overnight NPC voice-pack rewrites
(today's nightly) produce dialogue against character voices that the thematic
reframe will subsequently sharpen. Risk: the longer §9 waits, the larger the
retroactive rewrite surface. Every NPC draft promoted before §9 lands is
a candidate for a second pass.

**§10 — Court Round two phases: effectively DONE as of today.** Sessions 41–44
restored `battle_controller.gd` (643 lines), wired Phase 1/Phase 2, and had
the court consume the assembled motion packet. The PROPOSALS.md table still
shows DONE, which is now accurate — but the sprint log's own references to
"REVERTED stubs" from commit `c83feaa` have been superseded. No action needed
except confirming the PROPOSALS.md note reflects the v17/v18/v19 packet model
(the table entry predates those sessions).

**Player-driven argument synthesis: DRAFT → implementation complete.** Today's
session sequence (41 proposal v3 → 42 state/data → 43 BlueBinder UI → 44 court
scoring) moved this from a 430-line proposal to fully wired code in a single
day. Outstanding: NPC dialogue promotion (items 8–9 above) and §10 note update.

**§6 — Chapter 5 beat list: correctly deferred.** No action.

---

## Leverage Hunt

### Retrospective — tools we already had that would have saved past sessions

**1. `mcp__godot__run_project` in Sessions 8.5–8.12 (May 8, eight sub-sessions).**
The office room was rebuilt across eight passes — furniture placement, desk
orientation, wall depth — each verified only by headless `--import --quit` plus
visual delegation to human. `mcp__godot__run_project` followed by
`mcp__godot__get_debug_output` would have confirmed actual node positions,
Z-order, and door-gap misalignments after each pass. Literal call:
```
mcp__godot__run_project(project_path="godot/") 
mcp__godot__get_debug_output()  # grep for push_error, verify startup clean
```
Estimated saving: 4–5 of the 8 sub-sessions collapse to 2.

**2. `tools/voice_audit.py` against `_drafts/` before the overnight nightly
cohort runs.** The 2026-05-15 dialogue audit caught two objective violations in
committed runtime files. The same violations exist in the player-driven drafts
but are caught only after they ship to `_drafts/`. If `voice_audit.py` were run
against `_drafts/*.json` as part of draft authoring (or as a nightly step before
the design_proposals agent), objective violations would surface before promotion
rather than after. Literal command to add to nightly health agent:
```bash
python3 tools/voice_audit.py godot/data/_drafts/ 2>/dev/null || true
```

**3. `jq -e` JSON gate in Sessions 30–33 before each catalogue-cleanup commit.**
Several sessions (30, 35, 37) added orphan-catalogue fixes and later found
additional orphan files in the same pass. A one-liner pre-commit hook would
have caught them at commit time:
```bash
find godot/data/dialogues -name '*.json' -print0 | xargs -0 -n1 jq -e '.npc_id and (.states | length > 0)' > /dev/null || echo "Empty/invalid dialogue files present"
```
This would have surfaced the four inert rewrite stubs as a commit-time warning
in Sessions 30, 37, and 38, rather than deferring them to human action across
5+ sessions.

### Prospective — the single highest-leverage thing not yet in use

**`gdtoolkit` for GDScript syntax parsing in the nightly sandbox.**

The Godot binary is unavailable in the nightly sandbox and will likely remain so
without a sandbox image change (a logistical effort). `gdtoolkit` is a
pure-Python GDScript parser that runs without Godot, catches syntax errors and
parse failures, and is installable in the existing sandbox in ~10 seconds:
```bash
pip3 install gdtoolkit --break-system-packages
gdparse --version
find /sessions/wizardly-jolly-fermat/mnt/pig-swine-rpg/godot/scripts -name '*.gd' -print0 | xargs -0 gdparse 2>&1 | grep -v "^OK" || echo "All scripts parse clean"
```

The friction it closes: the nightly health agent currently reports `SKIP` for
all 44 test scripts. It cannot distinguish "tests SKIPPED, project is fine"
from "tests SKIPPED, a committed script has a syntax error that will crash on
boot." `gdtoolkit` restores the parse-level guarantee (equivalent to Godot's
`--check-only`) without needing the binary. The `push_error` / runtime-behavior
guarantee still requires `mcp__godot__run_project`, but syntax errors are
catchable immediately.

This is the single change that would make the nightly health report honestly
useful on the Code dimension rather than systematically hollow.

---

## Night Agent Assessment

**Agent cohort today: 5 agents ran (1, 3, 4, 7, 8).** Agent 1 restored
`battle_controller.gd` and confirmed headless acceptance from a host that has
Godot installed (EXIT 0 across smoke, runner, battle, save-migration, export).
Agent 3 registered v17 flags in `chapter1.json` and surfaced the
`murrow_choice` drift. Agent 7 authored 15 Asia hint states with Taste Standard
5/5 verdicts. Agents 4 and 8 contributed commits visible in today's git log
(NPC voice-pack rewrites, decoy data, judge dialogue) without leaving prose
done-files — the signal from those agents is recoverable from `git log` but
not from nightly reports.

**Action: request agents 4 and 8 to leave prose `*_done.md` files**, matching
the agent 1/3/7 pattern. Without them this workflow memo cannot assess what
those agents did or whether they found issues.

**Health check pass rate: 3/5 checks** (JSON validity PASS, voice audit PASS,
print statements PASS; headless tests SKIP, git snapshot now unblocked — this
run completed the snapshot). The test-SKIP condition has been persistent across
every health report and now represents a structural gap rather than a transient
one.

**Data consistency (2026-05-14): all 11 Tier-1 items closed by Session 39.**
No new data_consistency report ran on 2026-05-15 or 2026-05-16. Recommend
scheduling a fresh data_consistency run now that SAVE_VERSION is at 19 and
the motion-packet fields are in `chapter1.json` — there may be a new Tier-1
layer (packet slot flags, `murrow_choice`, `court_outcome` enum extension from
Session 44 vs. `state.gd`).

**Dialogue audit (2026-05-15): 2 objective violations found, draft fix in
`_drafts/nightly_dialogue_fixes_2026-05-15.json` awaiting promotion.** Neither
fix requires a SAVE_VERSION bump; both are single-line string changes.

**Workflow agent: this run is the first single-daily run (per yesterday's
recommendation).** The redundant double-run from 2026-05-15 (12:21 and 21:20)
is not repeated. Signal is materially higher without the stale-input duplication.

---

## Recommended Next Session Focus

**File:** `godot/data/dialogues/crab.json`, `murrow.json`, `whimsy.json`,
`godot/data/asia_hint_states_ch1.json`.

**Role: Design.**

**Task: promote the four NPC "final" drafts into runtime dialogue files and
apply the two dialogue-audit objective fixes.**

**Why it unblocks the most subsequent work:**

Sessions 42–44 today wired the full motion-packet pipeline: state declared,
BlueBinder UI reads surfaced evidence and writes packet slots, `battle_controller.gd`
grades the packet and sets `court_outcome`. The entire system works end-to-end
in code. What is missing is the NPC dialogue that drives the player through
Beat 4 → Beat 12 to produce a meaningful packet before they reach the court door.
Without the Crab synthesis options, the Murrow decoy-decision states, and the
Whimsy co-counsel posture states, a player who boots the current web export
can walk to court with an empty packet and receive a `procedural_reset_narrow`
by default — the mechanical system exists but the authored path through it
does not.

The "final" variants in `_drafts/` are the authored path. They have passed
Taste Standard audits. The merge step is the only remaining work between
"court system wired but unplayable" and "Chapter 1 investigation loop
playable end-to-end for the first time."

Promotion procedure per file:
1. Run `python3 tools/voice_audit.py godot/data/_drafts/<file>_final_2026-05-16.json`
   to confirm zero violations before touching the live file.
2. Merge the new state objects into the live `<npc>.json` per the insertion
   instructions in each agent's done file / draft header.
3. Run `jq empty godot/data/dialogues/<npc>.json` to confirm validity.
4. Run `godot --headless --path godot --script tests/test_dialogue_runner.gd`.

Once promoted, the natural next Code session is a visual playtest via
`mcp__godot__run_project` walking Beat 4 → court ready → court — the first
end-to-end motion-packet playthrough.
