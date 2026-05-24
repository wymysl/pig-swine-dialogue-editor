# Workflow Analysis — 2026-05-22

> Reversibility snapshot SKIPPED. `.git/index.lock` (zero bytes, dated
> 2026-05-22 21:46) and `.git/HEAD.lock` (zero bytes, 2026-05-21 21:05) are
> both held by the host and the sandbox user cannot remove them
> (`Operation not permitted`). The `.git/index.lock.stale.1778947302694921369`
> from 2026-05-16 is also still present and still uncleanable from here.
> Five consecutive nightly runs (workflow 2026-05-15, data_consistency
> 2026-05-18, health 2026-05-20, data_consistency 2026-05-21, health
> 2026-05-22) have now flagged the same lock condition. Memo writes a single
> file under `godot/nightly/2026-05-22/`; no other tree changes.

## Velocity

104 dated entries in `SPRINT_LOG.md` (Session 1 → Session 47 plus
~57 sub-sessions and dated batch headings) across 19 calendar days
(2026-05-04 → 2026-05-22). The last full week (2026-05-16 → 2026-05-22) added
roughly 32 entries; the day of 2026-05-12 alone carried 36; week-on-week
cadence is stable in the 30–40/week band when measured by SPRINT_LOG headings.
Sustainable for an agent-led project, well above PLAN.md's original
"14–20 sessions for the vertical slice" budget — that budget collapsed when
"session" became "one autonomous agent pass" rather than "one human-supervised
sitting."

Output character: the past five days are critique-driven remediation. The
five hostile critiques filed 2026-05-19 (`tech`, `ui`, `design`, `narrative`,
`art`) produced commits `0ef1c64` (design F2/F4/F5/F10), `54b362e` (narrative
F1–F11), `4c421e8` (art F9), and the 2026-05-22 tech-critique remediation
(`test_save_roundtrip`, strict `_set_state_value`, `Facing` helper,
`MainController.instance` singleton). Productive but not feature work —
every commit since 2026-05-19 has been hardening on already-shipped surface,
not new chapter content. The vertical slice's steps 4 and 5 finished
2026-05-16; step 6 (Polish + writing) has not formally started, though most
of the critique remediation is doing exactly that work under another name.

Trend: throughput steady, the centre of gravity has rotated from
*system-shipping* to *system-hardening*. Healthy for the next playtest, but
Chapter 1's web-export-ready-for-a-stranger gate (CURATION_BOARD.md
Curation Warning) is the unambiguous next milestone, and no session
since 2026-05-16 has tried to walk it.

## Top Recurring Friction

1. **Headless Godot unreachable from the scheduled-task sandbox — 26
   sprint-log mentions of TCC/sandbox; 7 consecutive nightly `health.md`
   reports unable to run any tests** (2026-05-14 through 2026-05-22, no
   break). The 2026-05-21 plugin migration replaced `mcp__godot__*` (40
   tools) with `mcp__godot-ai__*` (different namespace), and the
   nightly-agent prompts that still reference the old namespace silently
   skip. The 2026-05-22 health.md tried `mcp__godot-ai__test_run` and found
   it discovers classes with `test_*` methods, not the project's
   `extends SceneTree` `--script` runners — so all 56 test files reported
   as "abstract or broken" (a false negative, not a failure).
   Mitigation: install `gdtoolkit` in the sandbox image
   (`pip3 install gdtoolkit --break-system-packages`) and have the nightly
   health agent run `gdparse godot/scripts/**/*.gd` as a parse-level
   substitute; replace the test-run step with
   `mcp__godot-ai__project_run` + `mcp__godot-ai__logs_read` grepping
   `push_error` (the working substitute that Session 39b already proved on
   2026-05-15, now under the new namespace).

2. **Visual ACs delegated to human and never re-confirmed — at least 16
   sprint-log lines explicitly use "delegated to human" / "AC Visual: human"
   / "visual confirm pending"; BUILD_NOTES.md Session 7 checklist (five
   bullets) has now sat unchecked since 2026-05-05 — 17 calendar days.**
   Sessions since (8.5–8.12 office sketch iteration, 9g–9i tile resize,
   sprint 8 pickups, Session 14 coffee minigame, Session 16 barista
   portraits, Session 18 reception desk, Session 30 Halina meeting room,
   Session 39 visual playtest) have stacked further visual debt on top.
   Mitigation: pair `mcp__Claude_in_Chrome__navigate` + `get_page_text` +
   the computer tool for a screenshot against the web export served from
   `localhost:8000/exports/web/`, scripted as a nightly agent (literal
   recipe in §Leverage Hunt below). This is the closer for the longest-
   running friction in the project.

3. **`.git` lockfile detritus blocking reversibility snapshots — 5+
   consecutive nightlies blocked.** `index.lock`, `HEAD.lock`, the
   `index.lock.stale.*` from 2026-05-16, plus accumulating `tmp_obj_*`
   files under `.git/objects/*/`. Every blocked snapshot means a nightly
   that does edit files has no rollback point. Mitigation: a `launchd`
   user-agent on the host running every five minutes:
   `find ~/Documents/Silly\ projects/pig-swine-rpg/.git -maxdepth 2 \( -name 'index.lock' -o -name 'HEAD.lock' -o -name 'index.lock.stale.*' \) -mmin +10 -delete`
   plus a weekly `find .git/objects -name 'tmp_obj_*' -mtime +1 -delete`.
   Zero-byte locks more than ten minutes old are by definition orphaned and
   safe to remove; current sandbox cannot do it, host can.

## Delegated-to-Human Backlog

Count: 17 items outstanding. Oldest from Session 1 (2026-05-04), still open.

1. BUILD_NOTES.md Session 7 checklist — 5 unchecked sub-items
   (NPC sprites, ProceduralBinder, RightsMemo, repeat-room suppression,
   coffee stub round-trip + save/load). 17 calendar days. Oldest visual
   debt in the project.
2. Visual confirm: office layout 16×9 tiles (Session 9i, 2026-05-12).
3. Visual confirm: coffee minigame 2-lane tutorial + 4-lane normal
   (Sessions 10 and 14, 2026-05-12).
4. Barista portrait placeholder swap (Session 16, 2026-05-12).
5. Halina meeting-room chain visual confirm (Session 30, 2026-05-13).
6. Office layout, reception desk orientation, café layout walk-through
   (Sessions 8.9–8.12, 2026-05-08).
7. Office Street v0 → v1 widened-canvas smoke/runner/export commands —
   noted as "human to run on macOS host" (Sessions 2026-05-18 art passes,
   five separate `human to run` blocks).
8. F1 DESIGN_TODO inventory clear in `chapter1_round_1.json` — every
   witness `display_name`, every statement `text`, every
   `press_options[].follow_up_text`, every `judge_counter_questions[].text`,
   every `available_citations[].flavor_line`, every defeat/partial line,
   every `victory_resolution.branches[].result_text`. Per the
   2026-05-20 design-critique entry, **no new mechanical surface lands
   until this hits zero**.
9. F4 trust meter rework (deferred from 2026-05-19 narrative critique) —
   coverage-of-distinct-register-classes reveal gate; needs Piotr's
   design call before code can land.
10. F4 Cula interior fan-out — `cula.json` Beat 1–14 chorus unreachable
    until a build-time script fans out per-NPC inline lines. Engineering
    artifact required.
11. F2 web-export decision — `_mcp_game_helper` autoload (dev tooling, see
    project memory) currently ships in every export preset including web.
    Need a choice between `OS.has_feature` gate or
    `addons/godot_ai/` exclude filter.
12. F4 large-script splits — `dialogue_runner.gd` (913 LOC),
    `battle_controller.gd` (723), `blue_binder.gd` (698) all above the
    300-LOC cap. Non-trivial refactor; pending Piotr's call.
13. F7 typed `Chapter1State` — touches every `State` consumer.
14. F9 stale-file purge — `.bak`, `.legacy`, `.pre_floor_fill`,
    `.pre_three_band`, `data/_drafts/`, `data/dialogues/_drafts/`.
    Concrete files visible in this run:
    `godot/scenes/world/routes/office_street.tscn.pre_floor_fill`,
    `office_street.tscn.pre_three_band`,
    `art/tilesets/office_tileset.tres.pre_herringbone_trim`,
    `data/dialogues/halina.json.bak`, four `.jsonl.bak` voice references,
    `data/asia_hints.json.bak`. Plus three root `.txt.pre_stage*.bak`
    files.
15. Scratch-script residue — 17 `*.gd` + 17 `*.gd.uid` under
    `godot/scratch/` (debug/check/inspect throwaways from the Session 30
    follow-on cleanup; tracked as "pending tidy" since then).
    Literal command:
    `cd ~/Documents/Silly\ projects/pig-swine-rpg && rm -rf godot/scratch && git add -A && git commit -m "Drop godot/scratch/ throwaways"`.
16. `.git/index.lock`, `.git/HEAD.lock`, `.git/index.lock.stale.1778947302694921369`
    cleanup (see §Top Recurring Friction). Literal command:
    `rm -f ~/Documents/Silly\ projects/pig-swine-rpg/.git/index.lock ~/Documents/Silly\ projects/pig-swine-rpg/.git/HEAD.lock ~/Documents/Silly\ projects/pig-swine-rpg/.git/index.lock.stale.*`.
17. `.git/objects/**/tmp_obj_*` cleanup — at least five files dating from
    2026-05-15 through today, accumulating across blocked-snapshot runs.
    `find ~/Documents/Silly\ projects/pig-swine-rpg/.git/objects -name 'tmp_obj_*' -mtime +1 -delete`.

Items 7, 12, 13, 14, 16, 17 collapse to a single missing capability —
"the agent cannot do this from the sandbox; it needs a host-side run." The
sandbox/host split is the structural cause of most of this list.

## Draft Promotion Gap

23 files in `godot/data/_drafts/` (was 14 on 2026-05-16, was 9 on
2026-05-15). Plus 3 in `data/dialogues/_drafts/` (`crab_decoys`,
`murrow_decoys`, `whimsy_decoys`, all 2026-05-16).

- Nightly-generated: 4 (`nightly_design_pig_2026-05-14.json`,
  `nightly_design_murrow_beat9_2026-05-15.json`,
  `nightly_dialogue_fixes_2026-05-15.json`,
  `nightly_design_beat13_close_2026-05-17.json`).
- Manual awaiting promotion: 19. Oldest by filename date:
  `asia_hints_player_driven_2026-05-16_v2.json` (6 days);
  oldest non-nightly stratum: same date.
- The 2026-05-17 stratum (12 files, `ch1_*_2026-05-17.json` plus
  `beat1_murrow_2026-05-17.json`) is a complete chapter-1 NPC voice-pass
  cohort that has been sitting for 5 days. The 2026-05-19 stratum
  (`mail_carrier_ch1`, `tram_waiter_ch1`, `route_blocker_business_ch1`,
  `route_blocker_residential_ch1`) is the dialogue stubs for the five new
  Office Street NPCs that ship as visual placeholders with no dialogue —
  promoting these closes the warning trio
  `Dialogue file not found: data/dialogues/<id>.json` documented in
  Session 2026-05-18 art passes.

Backlog is growing. The 2026-05-16 workflow recommended a Design session
specifically for draft promotion; it has not happened. Recommend the same,
sharpened: a single sitting that runs
`python3 tools/voice_audit.py godot/data/_drafts/` (the literal command
already proposed for the nightly health agent, see §Leverage Hunt),
promotes everything that passes voice-audit clean, and tombstones the rest
to `_legacy/snapshots/2026-05-22/`. Don't ship anything mechanical until
the canon-side authoring catches up.

## Stale Proposals

- **§9 — Thematic reframe (crisis-of-values spine): PENDING since
  2026-05-05, 17 days.** Methodology still in chat history only; no
  `.txt` edits. Every NPC dialogue authored in `_drafts/` since
  2026-05-16 will be a candidate for retroactive rewrite when §9 lands.
  Risk grows with each day of new voice work.
- **§6 — Chapter 5 beat list: DEFERRED.** Correctly deferred (the standing
  decision is "lock before Ch4 implementation begins").
- **Tech critique 2026-05-22 F2, F4, F7, F9 — open.** F10 closed in the
  same entry. F1 (test_save_roundtrip), F3 (strict `_set_state_value`),
  F5 (Casebook validation surface), F6 (`Facing` extraction), F8
  (`MainController.instance`) all landed; the five remaining items are
  Piotr-decision-blocked, not work-blocked.
- **Design critique 2026-05-19 F1 DESIGN_TODO inventory clear — open.**
  Repeated in §Delegated-to-Human Backlog. This is the gate-before-more-
  mechanical-surface decision; nothing else in Chapter 1 should start
  until it clears.
- **Design critique 2026-05-19 F5 trust meter rework — open.** Repeated
  from narrative critique. Same human-decision dependency as F4 fan-out.
- **§10 court-round two phases — DONE on 2026-05-16 and remains DONE.**
  The previous workflow.md noted the table-entry-predates-the-packet-model
  discrepancy; the packet model from Sessions 41–44 is now the established
  reality.

Highest unblocking value if actioned: the
F1 DESIGN_TODO inventory. Every other deferred mechanical item depends on
it. Second-highest: §9 thematic reframe — the longer it waits, the larger
the retroactive surface.

## Leverage Hunt

### Retrospective — tools we already had that would have saved past sessions

1. **`mcp__Claude_in_Chrome__navigate` + `get_page_text` against
   `exports/web/index.html` would have closed the BUILD_NOTES.md Session 7
   checklist on 2026-05-05.** Five bullets, 17 days open. The closer is:
   serve the export from the host (the Web export is already producing
   `index.html`/`index.wasm`/`index.pck` cleanly per every export ACline
   since Session 1), then call
   `mcp__Claude_in_Chrome__navigate(url="http://localhost:8000/")`,
   `mcp__Claude_in_Chrome__get_page_text()` to grep for "Pig & Swine RPG
   v0.1.0", and `mcp__Claude_in_Chrome__computer` for screenshots. The
   visual ACs that have been pending since May 5 are reachable from this
   loop; the macOS TCC barrier that blocked every prior attempt is
   irrelevant if Chrome is the runtime, not Godot. Estimated saving: 14
   "delegated to human" entries collapse to one nightly walk-through.

2. **`mcp__godot-ai__editor_screenshot` would have replaced 4 of the 8
   Session 8.5–8.12 sub-sessions (2026-05-08).** Each sub-session rebuilt
   the Pig & Swine office layout from a sketch and shipped a `--import
   --quit` PASS plus "AC visual: delegated to human." Editor screenshots
   per pass would have given the agent a self-checkable image to compare
   against the sketch before declaring done. Literal call:
   `mcp__godot-ai__scene_open(path="res://scenes/interiors/pig_swine_office.tscn")`
   then `mcp__godot-ai__editor_screenshot()`. (The plugin migration on
   2026-05-21 brought this into namespace; before that it would have been
   `mcp__godot__*` which was already capable per Session 39b's
   `run_project` pattern from 2026-05-15.)

3. **`mcp__godot-ai__project_run` + `mcp__godot-ai__logs_read` against the
   built-in macOS host would have caught the `trust_path: "asia"` error in
   `asia.json::cula_approach` on 2026-05-13, not 2026-05-15.** Session 39b
   used this pattern explicitly; the two days between commit `ba6c094`
   landing and Session 39b finding the error were dead weight. Promoted as
   permanent recipe in the nightly health agent: this catches push_errors
   at boot, which the headless `--script tests/*.gd` suite cannot reach.

### Prospective — single highest-leverage thing not yet in use

**A nightly browser-playtest agent using
`mcp__Claude_in_Chrome__*` against the served web export.**

Concrete recipe (paste this into a new scheduled-task SKILL.md, runs
nightly after `health.md`):

```bash
# On host, serve the export (needs COOP/COEP for SharedArrayBuffer):
cd ~/Documents/Silly\ projects/pig-swine-rpg/godot/exports/web
python3 -c "
import http.server, socketserver
class H(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cross-Origin-Opener-Policy','same-origin')
        self.send_header('Cross-Origin-Embedder-Policy','require-corp')
        super().end_headers()
socketserver.TCPServer.allow_reuse_address = True
socketserver.TCPServer(('',8765),H).serve_forever()
" &
```

```
mcp__Claude_in_Chrome__navigate(url="http://localhost:8765/")
mcp__Claude_in_Chrome__get_page_text()          # grep for "Pig & Swine RPG v0.1.0"
mcp__Claude_in_Chrome__read_console_messages()  # grep for push_error / red
mcp__Claude_in_Chrome__computer(action="screenshot")
# Drive WASD via the computer tool's keyboard input, screenshot each room.
```

The friction it closes:
(a) BUILD_NOTES.md Session 7 checklist (5 sub-items, 17 days open);
(b) 14 sprint-log "delegated to human" visual confirms;
(c) the structural test-suite gap for runtime issues that don't crash
the project but render incorrectly (Z-order, missing texture, off-canvas
positioning — exactly the issues that drove Sessions 1c, 11–17, and the
2026-05-18 z-index/Building-floats sequence). The headless test suite
cannot reach any of these; Chrome can.

Caveat: needs a host-side helper to serve `exports/web/` with the
COOP/COEP headers SharedArrayBuffer requires. A 15-line `launchd`
agent or a `make serve` target solves it.

### Self-modification: this skill's structural weakness

The scheduled-task prompts under `/Users/piotr/Library/.../uploads/` (and
their host-side counterparts) still hardcode the legacy `mcp__godot__*`
namespace in their guidance prose. The 2026-05-21 plugin migration
swapped to `mcp__godot-ai__*`. The 2026-05-22 health.md noticed this
mid-run and self-corrected; this workflow.md task spec's Stance section
also still references `mcp__godot__run_project` literally. Recommend a
search-and-replace pass on every `SKILL.md` for nightly agents:
`mcp__godot__` → `mcp__godot-ai__`, plus tool-name changes
(`get_project_info` → `editor_state`, `get_debug_output` → `logs_read`,
`run_project` → `project_run`). Without it, future agents will keep
catching the mismatch live and reporting it as an action item rather than
using the tool.

## Night Agent Assessment

This week's nightly cadence is uneven. 2026-05-19 produced nothing.
2026-05-20 produced `health.md` and `dialogue_audit.md`. 2026-05-21
produced only `data_consistency.md`. 2026-05-22 (today) has produced only
`health.md` before this memo lands. The intended four-agent cohort
(health, data_consistency, dialogue_audit, design_proposals) is no longer
running daily — three of the four agents have skipped at least one of the
last four nights.

**Health check pass rate: 2/3 reliable signal-bearing checks per run** —
JSON validity PASS, voice audit PASS, print scan PASS. Test runs SKIP
(7 consecutive nights, see §Top Recurring Friction). The git-snapshot
step is unreliable due to lock contention (the 2026-05-20 run got it
through; 2026-05-22 did not). Recommend the snapshot moves out of the
nightly agent entirely and into a host-side cron (literal command
under §Top Recurring Friction).

**Data consistency** (2026-05-21): PASS across all four checks (tag
closure, dialogue flag references, item flag references, door scene
references). The 23-draft inventory is the most actionable item the
report surfaces; promote-or-tombstone, see §Draft Promotion Gap.

**Dialogue audit** (2026-05-20): 4 borderline "Understood." flags, one
DRAFT placeholder still in `asia.json::hint_blue_folder`. None blocking;
the DRAFT placeholder is the one that should clear before next playtest.

**Design proposals** agent did not run 2026-05-20, 2026-05-21, or
2026-05-22. Either the agent was disabled or the prompt has been failing
silently. Worth checking the scheduled-task scheduler — three consecutive
no-shows is a state of the agent, not chance.

**Workflow agent**: this run is the only workflow.md since 2026-05-16
(six days). The 2026-05-15 / 2026-05-16 pattern of one workflow per day
has dropped to roughly once per week. Recommend setting the frequency
explicitly: weekly is fine if no critique-class events have happened in
between; daily during active feature-shipping sessions.

## Recommended Next Session Focus

**File:** new file `tools/serve_export.py` plus a nightly scheduled-task
`SKILL.md` for the Chrome-based playtest agent. Optionally also clean
up `godot/scratch/`, the `.bak`/`.pre_*` files, and the `.git` lockfile
detritus in the same human-led sitting (all literal commands listed in
§Delegated-to-Human Backlog items 14–17).

**Role: Code (for the serve script) + Orchestration (for the SKILL.md and
the launchd / cron wiring).**

**Why it unblocks the most subsequent work:**

The single oldest unresolved item in the project is the BUILD_NOTES.md
Session 7 visual checklist (2026-05-05, 17 days). The most-cited friction
in the SPRINT_LOG (26 mentions) is the same root cause — visual ACs that
the macOS TCC barrier blocks the headless suite from confirming. Every
session since 2026-05-05 has accreted further visual debt on top.

The Chrome-based playtest agent dissolves both. It does not require
solving the sandbox/host split (it runs against a host-served port from
the agent side), it does not require a Godot binary in the sandbox, and
it produces output (screenshots, console-text grep) that an autonomous
agent can self-check against an expected-output description in
`BUILD_NOTES.md`.

The downstream effect is that PLAN.md's "Chapter 1 ships in a web build a
stranger can play through" gate — the standing precondition for Chapter
2, Chapter 3, and the rest of the project — becomes verifiable by an
autonomous agent for the first time. Until that gate trips green, every
other "next session" recommendation is downstream of the same blocker.

After the agent ships, the natural follow-up sequence is: (1) one Design
session for draft promotion (clears the 23-file `_drafts/` backlog plus
the 5 ch1 NPC voice cohort); (2) the F1 DESIGN_TODO inventory clear
on `chapter1_round_1.json`; (3) the first end-to-end playthrough via the
new Chrome agent, with the canonical Chapter 1 win-state asserted
programmatically.
