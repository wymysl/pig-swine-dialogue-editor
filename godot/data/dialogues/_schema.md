# Dialogue file schema

One JSON file per NPC (or per ambient surface), named `<npc_id>.json`. The
dialogue runner (`godot/scripts/autoload/dialogue_runner.gd`) loads every
`.json` file in this directory at boot and validates it; any file whose name
contains `_rewrite`, `_v2`, or is `dialogues.json` is treated as inert
staging and skipped.

This document is authoritative. If the runner accepts a shape this doc does
not describe, treat that as a bug in either the doc or the runner and fix
the alignment. `tools/verify_dialogue_roundtrip.js` enforces the contract.

## Top-level shape

```json
{
  "version": 2,
  "npc_id": "halina",
  "display_name": "Mrs. Sikorska",
  "states": [ ... ],
  "idle_flavor": [ "...", "..." ]
}
```

- `version` — integer. Authoring metadata; runner does not read it.
- `npc_id` — must match the file name without `.json`. Used as the
  dispatch key for `Signals.dialogue_requested(npc_id, display_name)`.
- `display_name` — optional. Authoring metadata; runtime uses the
  `display_name` passed by the calling NPC node (`npc.gd`).
- `states` — ordered array of state objects (see below). The runner walks
  this top-to-bottom and fires the first state whose trigger evaluates
  true. **Ordering is load-bearing**; reordering states changes which
  line fires when.
- `idle_flavor` — array of plain strings. One is picked at random when
  no state trigger matches.

Sidecar documentation lives in `<npc_id>.md` next to each JSON. Provenance,
scope, address-form notes, and engine-flag context belong there, not in
the JSON.

## State shape

```json
{
  "id": "halina_first_meeting",
  "trigger": "!chapter1.halina_met && chapter1.client_meeting_stance == 'sympathetic'",
  "once": false,
  "speaker": "asia",
  "lines": [
    { "speaker": "asia", "text": "Mrs. Sikorska is here." },
    "Good morning. I am Halina Sikorska."
  ],
  "options": { ... },
  "on_dismiss": [
    { "set": "chapter1.halina_met", "value": true }
  ],
  "tags": ["beat8", "meeting_room"],
  "_comment": "Local authoring note. Ignored at runtime."
}
```

- `id` — string. **Must be globally unique across every dialogue JSON
  in this directory.** The runner's `dialogue_states_seen` array
  (used by `once: true`) is a flat namespace; collisions cause silent
  cross-file ghosting. The boot validator pushes an error on duplicates.
  Convention: prefix with the NPC when a state name (e.g.
  `coffee_reaction_perfect`) could plausibly recur — `crab_coffee_reaction_perfect`,
  `whimsy_coffee_reaction_perfect`.
- `trigger` — boolean expression over `State.data`. Empty/absent string
  means "always matches." See **Trigger grammar** below.
- `once` — optional bool. When `true`, the state fires at most once
  per save: after dismiss or option commit the runner appends the
  state's `id` to `State.data.dialogue_states_seen` and skips this
  state on subsequent walks. Trigger must still pass to fire.
- `speaker` — optional. Character id (from `character_registry.json`)
  used as the speaker for **plain-string lines** in this state.
  Per-line `{speaker, text}` objects always win. Without this field,
  plain-string lines use the `display_name` argument the NPC node
  passed in `dialogue_requested`.
- `lines` — array. Canonical form. Each entry is either a plain string
  (spoken by the state default speaker, see above) or
  `{ "speaker": "<character_id>", "text": "..." }` for a mid-state
  speaker switch. May mix shapes in any order. A state must declare
  exactly one of `lines`, `silent: true`, or contain only an `options`
  block — see **Silent states** below.
- `options` — optional inline-choice block. See **Options blocks** below.
- `on_dismiss` — optional array of mutations applied after the state
  is committed (option commit) or dismissed (plain dismiss). See
  **Mutations** below.
- `tags` — optional array of free-form string tags. Authoring
  metadata; runtime ignores them.
- `_comment`, `_comment_<anything>` — optional. Any key starting with
  `_` is ignored by the runtime and the validators. Use for local
  authoring notes that need to live next to a specific state.

### Silent states

A state with no `lines` (and no `options`) is rendered as silence: the
runner emits the matched state's id and an empty payload, the dialogue
box closes immediately, and any `on_dismiss` mutations still run. Use
this for "this NPC has nothing new to say in this beat, fall through to
idle" or for state-machine pivot points. Set `"silent": true` to make
the intent explicit; states with no `lines` and no `silent: true` are a
validation error (catches missing content).

## Trigger grammar

```
trigger    := group ( '||' group )*
group      := clause ( '&&' clause )*
clause     := path
            | '!' path
            | path '==' rhs
            | path '!=' rhs
            | path '>=' integer
            | path '<=' integer
path       := dotted identifier — resolved against State.data
              e.g. chapter1.met_pig, chapter1.casebook_judge_state
rhs        := 'true' | 'false' | integer | quoted-string
quoted-string := ' single-quoted ' (canonical) or " double-quoted "
                 (accepted; both stripped before compare)
```

Clauses inside a `group` are joined by `&&` (all must pass). Groups are
joined by `||` (any may pass). The expression is parsed left-to-right;
there is no operator precedence beyond this two-level structure.

**Negation: use `!path`.** `path == false` is no longer accepted by the
boot validator. The bare-truthy form is shorter, has the correct
semantics for unresolved-path-counts-as-falsy, and matches the rest of
the corpus.

**String compares: single-quoted RHS is canonical.** `chapter1.coffee_buff == 'over_caffeinated'` — not `"over_caffeinated"`. The runner still
strips either quote style, but the editor and round-trip script emit
single quotes; mixed files diff badly.

**Numeric compares (`>=` / `<=`)** treat both sides as integers. RHS is
a bare integer (no quotes). Use these for trust-meter–style threshold
checks: `chapter1.halina_trust >= 5`.

**Path resolution:** `State.data` is a nested `Dictionary`. `chapter1.met_pig` resolves to `State.data["chapter1"]["met_pig"]`. Missing path
segments resolve to `null`; the runner treats null as "trigger does not
match" and pushes a warning at evaluation time. The boot validator
walks every trigger / `on_dismiss.set` / `options.write_path` /
`options.trust_path` and pushes an error for any path that
`State.reset_state()` does not declare. Typos in flag paths are now a
load-time error, not a silent runtime no-op.

## Options blocks

```json
"options": {
  "write_path": "chapter1.client_meeting_stance",
  "trust_path": "chapter1.halina_trust",
  "chain": true,
  "choices": [
    { "text": "Lead with how she's holding up.", "value": "sympathetic", "trust_delta": 1 },
    { "text": "Lead with the timeline.",          "value": "blunt_procedural", "trust_delta": 0 },
    { "text": "Lead with the lease history.",     "value": "technical",        "trust_delta": -1 }
  ]
}
```

- `write_path` — required when `choices` is present. `State.data` path
  written with the picked `choice.value` on commit. Validated against
  `State.reset_state()` at boot.
- `choices` — array of `{ text, value, trust_delta? }`. `text` is what
  the player sees; `value` is what gets written to `write_path`.
  `trust_delta` is optional and only meaningful when `trust_path` is
  set.
- `trust_path` — optional. Counter at this `State.data` path is
  incremented by the picked choice's `trust_delta` on commit. Used
  for the Halina trust meter and similar threshold-based mechanics.
  Validated at boot.
- `chain` — optional bool. When `true`, after option commit the
  runner re-fires `dialogue_requested(npc_id, display_name)` for the
  same NPC without closing the dialogue box. Used to thread multi-turn
  conversations across separate states without scene transitions.

When a state has `options`, the dialogue box renders `lines` first as
the prompt, then the `choices` underneath. The player must commit a
choice; plain dismiss is not allowed for options states.

## Mutations (`on_dismiss`)

Each entry is one of three shapes:

```json
{ "set": "chapter1.met_pig", "value": true }      // assignment
{ "award_badge": "day_one_survivor" }              // marks badge true
{ "unlock_route": "residential" }                  // marks route true
```

- `set` — write `value` to `State.data` at the given path. Path must
  resolve at boot.
- `award_badge` — sets `State.data.badges[<id>] = true`. Unknown badge
  ids are rejected at runtime (must be pre-declared in
  `State.reset_state().badges`).
- `unlock_route` — sets `State.data.routes_unlocked[<id>] = true`.
  Same pre-declaration contract as badges.

`on_dismiss` fires for both plain dismiss and option commit. For
options states, the option write happens **first**, then `on_dismiss`,
then (if `chain: true`) the next request fires. For `once: true`
states, the state id is appended to `dialogue_states_seen` between
those two phases, so chain re-fires never re-match the same once-state.

## Speakers

Every speaker id used in any state must appear in
`godot/data/character_registry.json` (or in its `_portrait_aliases`
map). The boot validator walks every state-level `speaker`, every
per-line `{speaker, ...}`, and every `idle_flavor` entry's speaker (if
present); unknown ids are a load-time error.

Plain-string lines have no explicit speaker. The runner uses the
state-level `speaker` if present, otherwise the `display_name`
argument the NPC node passed when firing `dialogue_requested`. The
NPC node can switch between two display names (e.g. "Mr. Murrow"
formal vs "Murrow" warm) via `display_name_after_meeting` and
`first_meeting_flag` exports; see `npc.gd`.

For mid-state speaker switches (a character starts formal and warms up
within one state), use a per-line `{ "speaker": "murrow", "text": "..." }`
— the registry's `murrow` entry returns "Murrow" (warm form), while
plain-string lines continue to use the NPC node's current display name.

## Idle flavor

Plain string array only:

```json
"idle_flavor": [
  "Mr. Pig panics. Mr. Murrow thinks. I schedule the apocalypse.",
  "Order at the counter. Confessions cost extra."
]
```

A random entry is picked when no state matches.

## Files

- One canonical file per dispatch id: `pig.json`, `murrow.json`,
  `crab.json`, `whimsy.json`, `cula.json`, `asia.json`, `barista.json`,
  `halina.json`, `judge_district_ch1.json`,
  `meeting_room_stance.json`, `postcard_swine_ch1.json`,
  `asia_hint_states_ch1.json`.
- The Asia hint catalogue (`asia_hint_states_ch1.json`) is merged into
  the `asia` dispatch at boot — its states append after `asia.json`'s
  first-meeting states (see `dialogue_runner.gd::_merge_asia_hint_states`).
- Staging / archival files (`*_rewrite.json`, `*_v2.json`,
  `dialogues.json`) are skipped by both runner and validator. Do not
  edit them expecting runtime effect; promote to a canonical file or
  delete.

## Validation

All of the following are checked at boot in
`dialogue_runner.gd::_load_all_dialogues` and asserted by
`tools/verify_dialogue_roundtrip.js`:

- JSON parse.
- Globally unique `state.id`.
- Every `speaker` reference (state-level, per-line, idle-flavor) is in
  `character_registry.json` or `_portrait_aliases`.
- Every trigger path, `on_dismiss.set` path, `options.write_path`,
  and `options.trust_path` resolves against `State.reset_state()`.
- State has `lines` (≥1 entry), or `silent: true`, or `options` with
  ≥1 choice. Otherwise: validation error.
- Trigger parses cleanly per the grammar above.

Validation errors are loud (`push_error`). Validation warnings (e.g.
unused declared flag, state with both `silent` and `lines`) are
`push_warning`.
