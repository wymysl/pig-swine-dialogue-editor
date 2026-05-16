# Agent 12 — Binder UI v0 (Code role)

Commit: `b790554` — *Binder UI v0: case-file pages prototype, autoload + scene*

## Files

| Path | Lines | Bytes |
|---|---:|---:|
| `godot/scripts/autoload/binder_ui.gd` | 95 | 2,946 |
| `godot/scripts/ui/blue_binder.gd` | 259 | 8,991 |
| `godot/scenes/ui/blue_binder.tscn` | 139 | 3,505 |
| `godot/project.godot` (edit) | +6 | — |

Total: 499 insertions across four staged paths.

## Palette

Paper background: Palette H "Court Interior" **Dirty Linen** `#b8a890`
(`color = Color(0.7216, 0.6588, 0.5647, 1)` in the .tscn).

Body / title / footer text: Palette H **Institutional Wood** `#3a2818`
(`Color(0.2275, 0.1569, 0.0941, 1)`).

WCAG AA contrast against the paper: ≈ 5.7 : 1 (passes AA for both
normal-weight body text and 14px footnote). Verified arithmetically against
the WCAG formula; no display-time check was possible without rendering.

Why Court Interior over Milk Bar Parchment: the binder is a procedural
artifact (envelope addresses, renewal numbers, fact cross-references), and
the proposal §2 default explicitly anchors the mood in
"annotated paper … paper-clipped exhibits … period-frozen 1990s/2000s
office". Court Interior is the *procedural register* per CONVENTIONS.md
§Heavy-scene escalation rule; it matches the binder's role as the firm's
case-file artefact. Milk Bar Parchment would warm the binder into "cozy
office vignette", which fights the proposal's tone.

The `PageBody` Panel uses `self_modulate = Color(1, 1, 1, 0.35)` to fade
the default theme StyleBox so the paper hue dominates. No new StyleBox
resources, no new art assets.

## Non-colour signals (AGENTS.md §Stack invariants — "No information by colour alone")

Three independent, redundant signals on unread cards, each readable in
isolation:

1. **Tab prefix glyph** — `⚠ ` is prepended to the tab label
   (`UNREAD_PREFIX` constant in `blue_binder.gd`). Visible at first glance
   in the tab strip regardless of which page is active.
2. **Active page header suffix** — when the open page is unread, the title
   becomes `<display_name>   ⚠ Unread`. The text "Unread" is the load-
   bearing token; the glyph is reinforcement.
3. **Body content replacement** — `_page_body_summary.text =
   "[ Not yet read in the case file. ]"`, press lines suppressed, tags
   footer empty. The bracketed sentence is the canonical unread phrase;
   anyone reading the page sees plain English, not a colour state.

No alpha modulation on text was applied to the page body (testing showed
alpha-blending light text against `#b8a890` collapses below AA contrast).
Modulation appears only on the tab Buttons' label opacity if a future Art
pass theme overrides demand it; in v0 the glyph + label suffix carries the
signal alone.

## Acceptance — must be run on macOS

The Cowork-mode sandbox is a Linux environment with no `godot4` binary on
`PATH`. The headless acceptance commands listed in the brief were *not*
executed by this agent. JSON validity for `data/evidence_ch1.json` was
re-verified locally with `python3 -m json.tool` (exit 0). Everything else
must be run on Piotr's macOS box.

Exact commands, expected to exit 0 each:

```bash
cd /Users/piotr/Documents/Silly\ projects/pig-swine-rpg
python3 -m json.tool godot/data/evidence_ch1.json > /dev/null            # already verified

godot --headless --path godot --script tests/test_smoke.gd \
  --log-file /tmp/agent12_smoke.log
godot --headless --path godot --script tests/test_runner.gd \
  --log-file /tmp/agent12_runner.log
godot --headless --path godot --script tests/test_scene_inspect.gd \
  --log-file /tmp/agent12_inspect.log
godot --headless --path godot --export-release "Web" \
  exports/web/index.html --log-file /tmp/agent12_export.log
```

If any command fails the brief's halt rule applies — revert the commit
(`git revert b790554`) and file a follow-up. The single-commit shape was
deliberately chosen so revert is atomic and disturbs nothing else from
tonight's cohort.

Static review I *was* able to perform:

- JSON validity of `data/evidence_ch1.json` confirmed.
- `project.godot` diff verified clean (two additions, no other changes).
- `_unhandled_input` arrow-key navigation — checked against Godot's UI
  focus traversal order. Initial design had Buttons swallowing
  `ui_left`/`ui_right`; fix applied (`btn.focus_mode =
  Control.FOCUS_NONE`) before commit.
- Autoload boot order — State is declared before BinderUI in
  `project.godot`, so `State.data` is populated by the time
  `BinderUI._ready` instantiates the scene and `_build_tabs` reads
  `chapter1.binder_read_*`.
- `process_mode = ALWAYS` set both in the .tscn root and in
  `BinderUI._ready` so the autoload still receives the `binder` input
  action after `get_tree().paused = true`.

## Visual smoke — for Piotr

Headless Godot cannot render the binder. Run in the editor:

1. `cd /Users/piotr/Documents/Silly\ projects/pig-swine-rpg`
2. Open the project in Godot 4.6.2 (or `open -a Godot godot/project.godot`).
3. F5 to run from `scenes/Main.tscn`.
4. Trigger `chapter1.has_law_binder = true`. Two routes:
   - Walk to Pig → Murrow → pick up the procedural binder via the normal
     Chapter 1 hand-off (state-correct path).
   - Quick path for the visual smoke alone: add a temporary debugger
     watch and set `State.data.chapter1.has_law_binder = true` via the
     Godot debugger's Expression evaluator, or call from the Remote tab.
5. Press **B**.
6. Confirm:
   - Binder paper appears centred on the dim backdrop, 1100 × 640.
   - Eight tabs render across the top in JSON order
     (envelope, renewal, renumbering, wojcik, return-to-sender, lease,
     landlord, rights memo).
   - All eight tabs show the `⚠ ` prefix initially — no game writes
     `binder_read_*` yet, so every card reads as unread.
   - Active tab's page body shows the bracketed "Not yet read…" message.
   - `←` / `→` move between pages; Esc closes; B closes.
   - Closing returns control to the underlying scene; player movement
     resumes.

If any of the above doesn't match: capture the editor console output and
file a follow-up note. The most likely failure mode is the input action
not being picked up — check `Project → Project Settings → Input Map` for
the `binder` action and confirm KEY_B is bound.

## v1 design questions (for Piotr, before v1 starts)

These are the items the v0 prototype surfaced that need product decisions
before v1 is built. I am *not* making these calls inside v0; that is
exactly the point of the prototype.

1. **Open-anywhere vs at-a-surface.** Currently B opens the binder from
   any scene where `has_law_binder == true`. The case-file metaphor
   reads stronger if Cula has to be standing at a desk (firm's desk,
   archive table). Decision question: do we restrict open to specific
   `Interactable` nodes (`desk_pig_swine`, `desk_archive_room`,
   `desk_cafe_paragraf`)? If yes, the open-anywhere shortcut becomes a
   debug-only affordance.
2. **Auto-read on view vs explicit "press to read".** v0 reads
   `binder_read_*` but writes nothing. v1 needs to write — two options:
   - **Auto-read on first view** — turning to a page silently flips
     `binder_read_<x> = true`. Low friction; risks the player flipping
     through pages without engaging.
   - **Explicit "Press to read"** — opens a focused single-page view
     with E or Enter to commit, *then* flips the flag. Higher friction;
     forces a beat of reading. Mirrors the Ace Attorney "Press" verb.
3. **Multi-state visual register.** v0 has two states — read / unread.
   Should v1 introduce a third "skimmed but not read" tier (player
   opened the binder but didn't commit-read this card)? If yes, the
   read-state flag becomes a string-enum (`""` / `"skimmed"` / `"read"`)
   instead of a bool; SAVE_VERSION bump required.
4. **Tab order.** v0 follows JSON insertion order (binder pages 1–3,
   then bonus evidence in collection order, then rights memo). Should
   bonus evidence cluster separately (binder pages | exhibits) with a
   dividing rule? The visual separation reinforces the procedural
   metaphor.
5. **Reach-into-court behaviour.** During the Phase 1 court round
   (witness fact-finding), should the binder be openable, openable-but-
   read-only, or hard-locked? The PROPOSAL §10 model implies it gates
   "Present" actions, which means the binder needs to be reachable
   somehow during Phase 1. Decision needed before the battle controller
   wires the Present action to it.

## Cross-agent notes

**For Agent 1 (battle controller restoration).** This autoload reads
`chapter1.binder_read_envelope`, `chapter1.binder_read_renewal`,
`chapter1.binder_read_renumbering`, `chapter1.bonus_evidence_collected`,
and `chapter1.has_rights_memo`. It writes none of them. Your Phase 1
Present actions are the canonical writers per
`PROPOSAL_player_driven_argument.md §3`. The read-only contract is safe
under concurrent writers — `State.data` is a shared writable Dictionary,
and v0 refreshes the binder UI on every `open()` via
`refresh_from_state()`, so whatever your controller writes is reflected
the next time Piotr presses B.

**For Agent 9 (QA audit governance).** Two changes to `project.godot`,
both Code-owned per the AGENTS.md ownership table:
- new autoload entry `BinderUI` (Code owns autoloads under
  `scripts/autoload/`)
- new input action `binder` (Code owns input wiring)

No edits to `Main.tscn`, no edits to `state.gd`, no edits to `save.gd`,
no edits to any data file. Cross-reference clean.

## Art requests for v1 polish (out of scope tonight)

If v1 promotes the binder past prototype, the Art role should be filed a
request for:

- `art/ui/binder_paper_dirty_linen.png` — actual paper texture (light
  grain, faint vertical fold mark at the binder spine) to replace the
  flat ColorRect.
- `art/ui/binder_paperclip.png` — small paper-clip sprite for the
  exhibit cards (bonus evidence) only, to visually distinguish them
  from binder pages 1–3.
- `art/ui/binder_handwriting_overlay.png` — sparse Murrow-marginalia
  texture (three-colour highlighter, faint ink underline) to overlay
  on read cards. Matches the procedural-binder pickup line:
  *"Murrow has flagged Article 135-bis in three colors."*
- `audio/sfx/binder_open.ogg`, `binder_page_turn.ogg`,
  `binder_close.ogg` — three short OGG loops. Period-frozen paper
  sounds; no proprietary samples.

None of these are required for v0. Their absence is intentional and
documented; v0 is supposed to feel "the assembly hasn't started yet" so
Piotr can judge the case-file metaphor on its bones.
