# Workflow Analysis — 2026-05-15 (evening run)

> Supersedes the 2026-05-15 12:21 workflow.md. Reversibility snapshot skipped:
> stale `.git/index.lock` from a concurrent process; sandbox cannot remove. Same
> condition flagged by 2026-05-14 health.md and the 12:21 nightly today — three
> consecutive nightly runs now unable to snapshot. No source files modified in
> this pass.

---

## Velocity

**Total entries: 74 numbered sessions** (Session 1 through 39b plus eight
addenda) across 12 calendar days (2026-05-04 → 2026-05-15). The distribution
is heavily front-loaded: May 4 (4), May 5 (5), May 8 (8), May 11 (3),
**May 12 (36)**, May 13 (5), May 14 (11), May 15 (2 numbered + this nightly).
Roughly 43 entries per week if averaged, but the average is misleading — May 12
alone carried 36 sub-sessions (Sessions 9 through 9r plus Sessions 10–26), and
the cadence since then has compressed to a steadier 5–11 entries/day.

Output character has shifted measurably. Sessions 1–10 produced scaffolding and
load-bearing systems (autoloads, room transitions, dialogue runner, NPC system,
sprint, typewriter). Sessions 9-series ran iterative art passes. Sessions 28–38
look like maturation — schema refactors, migration tests, address-form fixes,
data audits. Session 39 (today) closed every Tier-1 item from yesterday's data
consistency audit. Session 39b (today, ~19:00) is the first session to use
Godot MCP `run_project` to bypass the macOS TCC visual-acceptance gap; it
caught a runtime startup error (`trust_path: "asia"` in asia.json) that
all prior headless tests missed.

Trend: **output per session decreasing, signal per session increasing.** This
is healthy maturation, but it also confirms the prior workflow.md's
observation: most of the recent throughput is autonomous maintenance, not
human-led feature development. The vertical-slice steps 4 and 5 (Casebook
Battle System v1, court rounds, payoff) remain unfinished.

---

## Top Recurring Friction

**1. macOS TCC blocking visual verification — appeared in 9+ sprint-log
entries and effectively every session since Session 1. Status: partially
resolved as of today.** Session 39b demonstrates that
`mcp__godot__run_project` bypasses the TCC crash that has gated every prior
attempt at a browser playtest by an agent — and immediately caught a real
startup error in asia.json that 38 headless tests did not. The macro
BUILD_NOTES.md entry from Session 7 (five playtest bullets) is still unchecked
after 10 days. Mitigation, escalated: write a one-paragraph "MCP playtest
recipe" into `godot/MANAGING_AGENTS.md` and into the nightly health-check
template — every nightly run should now also invoke `mcp__godot__run_project`,
read debug output, and report any `push_error` lines as a hard fail. The
sandbox/headless-test gap and the visual-acceptance gap collapse to a single
problem: "does the project actually start cleanly?" MCP answers that.

**2. Godot binary absent from nightly/autonomous-agent sandboxes — appeared in
8+ sprint-log sessions (28, 29, 30, 32, 33, 35) plus both nightly health checks
(2026-05-14, 2026-05-15).** Status: unchanged. The 2026-05-15 health.md
confirms `godot` is still not on PATH (`command not found`); all 38 test files
SKIPPED. Until host CI is set up or the sandbox image gains Godot 4.6.2,
nightly autonomous test status will continue to be SKIPPED. Concrete
mitigation already proposed in the 2026-05-15 health.md is reasonable: install
Godot in the sandbox image, or add an `mcp__godot__run_test_script` tool.
Interim measure: Session 39b's MCP-via-`run_project` pattern catches script
parse errors and runtime push_errors *as a side effect of booting*. That is
the cheapest near-term substitute for `--script tests/test_smoke.gd` and
should be folded into nightly until the binary lands.

**3. `.git/index.lock` blocking reversibility snapshots — three consecutive
nights now (2026-05-14 health.md, 2026-05-14 data_consistency.md, 2026-05-15
12:21 workflow, 2026-05-15 21:20 health, this run).** Sandbox cannot delete
the lock. Likely cause: Godot editor open on host, or a prior agent process
that exited without cleaning up. Effect: every nightly that modifies files
operates without a rollback point. Concrete mitigation: add a one-line guard
to `godot/MANAGING_AGENTS.md` §Daily flow — *"close the Godot editor before
agent sessions; if a nightly report flags index.lock, clear it next morning
with `rm .git/index.lock`."* The host-side `rm` is harmless when no `git`
operation is genuinely in flight.

---

## Delegated-to-Human Backlog

**Count: ~17 items outstanding**, oldest from Session 1 (2026-05-04). One
item closed since the 12:21 workflow.md (Session 39b confirmed visual playtest
of asia.json fix, partially discharging the long-standing "browser playtest
confirmation" debt).

Items in rough chronological order (session reference in parentheses):

1. Add `--log-file /tmp/...` to AGENTS.md acceptance commands, or open Godot
   editor once to pre-create `pig_swine_rpg` userdata dir (Session 1, May 4).
2. Walk the office, press E on Asia/MrPig/Murrow, confirm dialogue box appears
   (Session 3, May 4).
3. BUILD_NOTES.md Session 7 checklist — five items, all unchecked: NPC
   sprites visible, ProceduralBinder pickup, RightsMemo pickup, repeat-room
   suppression, coffee-machine stub round-trip, save/load preserves three
   flags (Session 7, May 5).
4. Browser playtest reception desk orientation and office layout
   (Sessions 8.9–8.12, May 8).
5. Visual confirm for 16×9 office room + zoom (Session 9i, May 12).
6. Visual confirm for coffee minigame: café 2-lane tutorial, office 4-lane
   normal (Session 14, May 12).
7. Replace barista portrait placeholders with AI-generated portraits from
   conversation (Session 16, May 12).
8. Play through Café Paragraf coffee machine with A/D+E, observe phase
   transitions and result panel (Session 10, May 12).
9. Confirm new INTRO phase overlay and key-hint row read clearly in motion
   (Session 26, May 12).
10. Walk Halina meeting-room chain: verify options on Cula's page, chain
    fires without dismissal, option font matches dialogue text (Session 30
    cont., May 13).
11. Run `test_smoke.gd` + `test_save_migration_v11_v12.gd` + web export sanity
    after Session 30 (May 13).
12. Run `test_smoke.gd` + `test_save_migration_v12_v13.gd` + dialogue_runner
    + Asia hint `hint_won_court` after Session 32 (May 14).
13. `git rm` the 17 scratch `.gd` files at project root (Session 33, May 14
    — blocked by sandbox filesystem permissions).
14. Run `test_effectiveness.gd`, smoke, runner, web export after Session 35
    (May 14).
15. Fix CONVENTIONS.md movement/sprite-dimension drift from runtime
    (Sessions 34 addendum and 37 follow-ups).
16. Decide fate of four orphan rewrite JSONs (`pig_rewrite.json`,
    `asia_rewrite.json`, `murrow_v2.json`, `asia_hint_states_ch1_rewrite.json`)
    — delete or archive (Sessions 35 and 38).
17. Run `test_save_migration_v14_v15.gd` and `test_save_migration_v16_v17.gd`
    on host (Sessions 39 and the SAVE_VERSION 17 commit `bc45550`).

Note: items 11, 12, 14, 17 are all variations of *"a tests-not-run debt
piling up."* They collapse to a single missing capability (Godot binary in
sandbox) and would clear at once if that gap closed.

---

## Draft Promotion Gap

**9 files in `godot/data/_drafts/`** — up from 2 yesterday. The growth is
concentrated in the player-driven-argument work (commit `ba6c094`, today):

Nightly-generated (3):
- `nightly_design_pig_2026-05-14.json` — Beat 13 Pig reaction draft.
- `nightly_design_murrow_beat9_2026-05-15.json` — Beat 9 archive narration
  draft (generated today; see 2026-05-15 design_proposals.md Proposal 1).
- `halina_with_trust_meter.json` — pre-Session-29 prototype, content already
  superseded by `halina.json` since 2026-05-13. Safe to delete.

Player-driven-argument Phase 2 drafts (3, committed today):
- `crab_player_driven_2026-05-15.json` (125 lines)
- `murrow_player_driven_2026-05-15.json` (106 lines)
- `whimsy_player_driven_2026-05-15.json` (87 lines)

Stub/placeholder rewrites (3, 7 lines each — committed structure, no content):
- `pig_rewrite_2026-05-14.json`
- `asia_rewrite_2026-05-14.json`
- `murrow_v2_2026-05-14.json`

Oldest non-nightly draft: `halina_with_trust_meter.json` (~2 days old,
trivially obsolete).

The growth is not generic backlog — it is the explicit Phase 2 output of
`godot/PROPOSAL_player_driven_argument.md` (260 lines, filed today). Three
NPC rewrite drafts plus a nightly Murrow Beat 9 draft are all keyed to human
review before promotion. Risk: this becomes a "drafts cemetery" if Phase 2
review is not scheduled within ~3 sessions of the proposal landing. The Beat 9
draft is the easiest to promote (it doesn't depend on proposal approval).

Recommendation: delete `halina_with_trust_meter.json` and the three 7-line
stub rewrites in a single human-confirmation pass; schedule one Design session
specifically to triage the four substantive drafts (Pig Beat 13, Murrow Beat 9,
and the three player-driven Phase 2 drafts).

---

## Stale Proposals

**§9 — Thematic reframe (crisis of values spine): PENDING, 10+ days without
progress.** Unchanged since the 12:21 workflow.md. Methodology lives in chat
history only. Risk reiterated: every NPC dialogue authoring pass since
2026-05-05 writes against a potentially-about-to-change character tone. The
player-driven-argument proposal landed today *without* referencing the
thematic-reframe decisions, which is fine for the mechanics but may strand the
voice work it generates.

**§10 — Court Round two phases: status inconsistency persists.** PROPOSALS.md
still marks §10 DONE; `data/court_rounds/_schema.md` still reads "REVERTED —
premature schema. `git rm` this file." `battle_controller.gd`, `judgment.gd`,
`principle_move.gd`, `argument_opponent.gd` all exist as REVERTED stubs (each
145 bytes — placeholder content only). `ch1_round1_halina_examination.json`
*does* exist (5,364 bytes, complete Phase 1 fact-finding). Three nightly
design_proposals reports across two days have flagged this contradiction and
proposed concrete resolutions; none has been actioned. The new
PROPOSAL_player_driven_argument.md explicitly relies on §10's structure and
calls out the REVERTED stubs (header section). If §10 is not resolved before
that proposal moves to Phase 3 (code), the player-driven argument work will
either reinvent §10 or block on it.

**§6 — Chapter 5 beat list: DEFERRED.** Correctly deferred.

**§11 — Narrative arc: DONE.** No issues.

**Player-driven argument synthesis (new, today): DRAFT.** Status correctly
marked DRAFT — Phase 1 plan; Phase 2 drafts in `_drafts/`; awaiting human
approval before Phase 3. Already produced SAVE_VERSION 17 scaffolding in
state.gd (commit `bc45550`) — confirm this is intentional and not a "Code
shipped ahead of approval" pattern.

---

## Godot MCP Opportunity

**Today's discovery (Session 39b) is the headline.** `mcp__godot__run_project`
runs the project past the macOS TCC barrier and surfaces `push_error` lines
that the headless suite cannot reach (because the suite cannot start). Within
*one session* it caught a real startup error (`trust_path: "asia"` invalid
namespace in asia.json `cula_approach`) and produced a same-session fix plus
a hardening pass in the dialogue editor.

**Past sessions that would have benefited from this same capability:**

1. **Sessions 8.5–8.12 (May 8) — eight sub-sessions rebuilding the office
   room.** Iterative furniture/door/spawn-point placement with `.tscn` edits
   verified only via headless `--import --quit`. MCP's `get_project_info` or
   a live scene-tree read could have shown node positions directly, collapsing
   the 8-pass iteration to 2–3.

2. **Sessions 9g–9i (May 12) — three sessions shrinking the office from
   24×16 → 20×11 → 16×9 tiles.** Each resize required by-hand recalculation
   of tile counts, camera limits, and door gap positions. MCP could have
   confirmed the live values from the running project.

3. **Sessions 11–17 (May 12) — six sessions fixing Y-sorting, collider
   alignment, door accessibility.** All visual results delegated to human.
   MCP's live scene-tree introspection (Z-index, CollisionShape2D extents)
   would have let agents confirm structural fixes before delegating.

A fourth opportunity, prospective: **the player-driven argument Phase 2
drafts will need playtest before promotion**, and Session 39b's pattern
(MCP run, read debug output, fix any push_errors found) is now the proven
path for an autonomous agent to do that step without waiting on the human.

---

## Night Agent Assessment

Reports across two days now: 2026-05-14 (health + data_consistency +
design_proposals), 2026-05-15 (health + design_proposals + workflow ×2).

**Health check pass rate: 3/5 both days.** JSON validity PASS, voice audit
PASS, print statements PASS. Headless tests SKIP (Godot binary absent). Git
snapshot SKIP (index.lock). Both blocking conditions are now persistent and
should be promoted to a top-of-report `⚠ BLOCKED` section so a quick scan
shows them without reading to the end. The 2026-05-15 health.md actually does
something like this in its "Action Required" section — extend that pattern.

**Data consistency: high signal.** The 2026-05-14 report flagged 11
actionable issues and 17 documentation gaps. **Session 39 today closed all 11
Tier-1 items** — chapter1.json now declares all SAVE_VERSION 11/13/15 flags,
the `landlord_contact` enum violation is fixed, and the three unregistered
NPCs are in character_registry.json. The 2026-05-15 cycle did not produce a
new data_consistency report (no file present in `godot/nightly/2026-05-15/`);
recommend running it again now that Tier-1 is clear, to surface the next
layer.

**Design proposals: high signal.** Three concrete proposals per day, each
with acceptance criteria and cross-references. The 2026-05-14 Proposal 2
(murrow.json name fix) was actioned in Session 37. Proposal 1 (Beat 13
reactions) is still pending — draft exists, promotion blocked on a Design
session. Proposal 3 (court rounds 2–3 + §10 schema resolution) is the
highest-leverage unblocker still open. The 2026-05-15 design_proposals
recapitulates §10 schema gap as Proposal 3 with even more specific JSON
schema — actionable verbatim.

**Workflow agent: redundant signal across two same-day runs.** The 12:21
workflow.md and this 21:20 workflow.md cover the same SPRINT_LOG range with
mostly the same findings. Recommend reducing workflow-agent frequency to
once-daily (e.g. evening only) rather than running twice on the same input.

**Net assessment: keep all four nightly agents; reduce workflow to one run
per day; add a data_consistency rerun trigger (it was not run today and the
Tier-2 backlog is now the next loadable signal).**

---

## Recommended Next Session Focus

**File:** `godot/PROPOSALS.md` §10 + `godot/data/court_rounds/_schema.md` +
`godot/scripts/systems/battle/battle_controller.gd` (and siblings).

**Feature: resolve PROPOSALS.md §10 status discrepancy and unblock court
rounds 2–3.**

**Why it unblocks the most subsequent work:**

The 12:21 workflow.md recommended chapter1.json registry catch-up (Tier 1
data consistency) as the highest-leverage Code session. **That work shipped
today as Session 39 — closing all 11 Tier-1 items.** The next blocking item
in line is §10.

§10's status discrepancy is now the load-bearing unresolved decision:

- `PROPOSALS.md` row 10 says DONE.
- `data/court_rounds/_schema.md` says REVERTED with a `git rm` instruction.
- `battle_controller.gd` (and `judgment.gd`, `principle_move.gd`,
  `argument_opponent.gd`) are 145-byte placeholder stubs from commit
  `c83feaa`.
- `ch1_round1_halina_examination.json` exists complete; rounds 2 and 3 do
  not.
- The new `PROPOSAL_player_driven_argument.md` (today) explicitly extends §10
  and depends on its decisions for Phase 0 → Phase 1 carry-over.

The 2026-05-14 design_proposals.md Proposal 3 supplies the missing answer to
§10's REVERTED open question ("how does the Phase 1 fact-flag system layer
with the existing stance-keyed bonus-evidence branches in
`judge_district_ch1.json`?"): **the two systems are additive and
non-competing.** Phase 1 fact-flags gate Phase 2 citation availability;
stance-keyed bonus evidence determines what surfaces as Phase 1 press
options. No overlap.

The session should produce, in order:

1. A one-sentence update to `PROPOSALS.md` §10 notes field documenting the
   additive-layering resolution and changing status to
   `PARTIAL — schema pending, battle_controller stubs awaiting implementation`.
2. A non-empty `data/court_rounds/_schema.md` matching the JSON shape laid
   out in the 2026-05-15 design_proposals.md Proposal 3.
3. Code-side declarations: `chapter1.witness_cooperation` in `state.gd`
   (int, default 0); Phase 1 fact-flag names declared for ch1_round1 that
   the existing `ch1_round1_halina_examination.json` already references but
   that may not exist in `chapter1.json` yet (audit needed).

Once those land, two parallel paths open:

- Design can author `ch1_round2_fair_hearing.json` and `ch1_round3_remedy.json`
  to the schema (one session each, sourced from `story.txt` §Round 2/3).
- Code can replace the four 145-byte battle stubs with real implementations
  per the schema, then wire `battle_screen.tscn` for the loop.

Either path is blocked today on §10 ambiguity. The estimated cost of the
unblocking session is small (~30 minutes; mostly editorial); the cost of
*not* doing it is that every subsequent court-round and battle-system
session has to start by re-deciding the same status question. After this
unblock, the natural follow-up Design session is Proposal 1 from
2026-05-15 design_proposals.md (Beat 9 Murrow archive narration), which has
a ready draft in `_drafts/nightly_design_murrow_beat9_2026-05-15.json` and
clears the path from Beat 8 → Beat 10.
