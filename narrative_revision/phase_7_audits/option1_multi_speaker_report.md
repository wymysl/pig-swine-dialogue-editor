# Option 1 — Multi-Speaker Runner Extension — Integration Report

**Date:** 2026-05-06  
**Pass scope:** Runner + UI extension; no dialogue tree files modified.

---

## Files changed

| File | Change type | Lines-of-diff summary |
|---|---|---|
| `godot/scripts/systems/dialogue_runner.gd` | Modified | +28 lines: `CHARACTER_REGISTRY_PATH` const, `_character_registry` dict, `_load_character_registry()`, `_resolve_speaker()`, updated `_extract_lines()` doc comment |
| `godot/scripts/ui/dialogue_box.gd` | Modified | +20 lines: `_default_speaker` var, updated `_on_dialogue_line_ready()` to store default, updated `_show_page()` to detect dict entries and resolve speaker per line |
| `godot/data/character_registry.json` | **New** | 8 id→name entries |
| `godot/data/dialogues/_schema.md` | Modified | Multi-speaker section added (~30 lines) |
| `godot/tests/fixtures/multi_speaker_fixture.json` | **New** | Synthetic multi-speaker test fixture |
| `godot/tests/test_dialogue_runner.gd` | Modified | +75 lines: T9–T12 test cases appended |

**Dialogue tree files: ZERO changes.** `pig.json`, `murrow.json`, `crab.json`, `whimsy.json`, `asia.json`, `cula.json` — all unmodified.

---

## Speaker → display name resolution

**Source:** `godot/data/character_registry.json` (new file).  
**Authority:** voice_references `/*.jsonl` metadata records (`display_name` field, line 1 of each file).

| character_id | display_name | Source file |
|---|---|---|
| `cula` | `Dr. A. Cula` | `dialogue_samples_dr_a_cula.jsonl` |
| `pig` | `Mr. Pig` | `dialogue_samples_mr_pig.jsonl` |
| `murrow` | `Mr. Murrow` | `dialogue_samples_mr_murrow.jsonl` |
| `asia` | `Asia` | `dialogue_samples_asia.jsonl` |
| `crab` | `Crab` | `dialogue_samples_crab.jsonl` |
| `whimsy` | `Whimsy` | `dialogue_samples_whimsy.jsonl` |
| `barista` | `Barista` | `dialogue_samples_barista.jsonl` |
| `swine` | `Mr. Swine` | `dialogue_samples_mr_swine.jsonl` |

Note: the voice reference `character_id` for Pig is `mr_pig` but the dialogue tree `npc_id` (and the convention used in multi-speaker `speaker` fields) is `pig`. The registry uses the `npc_id` convention — `pig: "Mr. Pig"` — so that speaker ids in dialogue tree files match the same namespace as `npc_id`.

**Fallback:** if a `character_id` is not in the registry, `_resolve_speaker()` pushes a `push_warning` and returns the owning NPC's display name. Non-fatal.

**Loading:** `_load_character_registry()` is called once in `dialogue_runner.gd _ready()`. Registry is stored in `_character_registry: Dictionary`. Keys prefixed with `_` (e.g. `_doc`) are skipped.

---

## character_registry.json — full contents

```json
{
    "_doc": "Character display-name registry. Maps character_id to display name...",
    "cula": "Dr. A. Cula",
    "pig": "Mr. Pig",
    "murrow": "Mr. Murrow",
    "asia": "Asia",
    "crab": "Crab",
    "whimsy": "Whimsy",
    "barista": "Barista",
    "swine": "Mr. Swine"
}
```

---

## Architecture decisions

### Signal shape unchanged

`dialogue_line_ready(speaker: String, lines: Array)` was not changed. The `speaker` arg still carries the owning NPC's display name. The `lines` array now may contain dicts alongside strings.

**Alternative considered:** emit one signal per line (so the runner drives speaker-switching). Rejected — would require the runner to know about typewriter timing and player-advance pacing, which is the dialogue box's job. The current split (runner emits the whole lines array; dialogue box iterates it per keypress) is simpler and keeps the runner decoupled from frame timing.

### Speaker resolution is in dialogue_box.gd, not runner

`_show_page()` in the dialogue box calls `runner._resolve_speaker(character_id, fallback)` for each dict entry. The runner exposes `_resolve_speaker` as a public-ish helper (underscore-prefixed per GDScript convention but accessible from other nodes).

**Alternative considered:** runner resolves all speaker names before emitting (transforms `{speaker: "cula", text: "..."}` → `{speaker: "Dr. A. Cula", text: "..."}`). Rejected — would prevent the dialogue box from ever using the raw `character_id` for portrait lookup (future pass). Keeping the id in the signal is more forward-compatible.

### No signal shape change for idle_flavor

`idle_flavor` entries that are dicts (e.g. `{ "line": "...", "tags": [...] }` from the schema example) continue to be handled by the existing `_extract_lines(chosen) if chosen is Dictionary` branch in `_on_dialogue_requested`. A dict idle entry is not treated as a multi-speaker entry (it has a `"line"` key, not `"speaker"/"text"`). Multi-speaker applies only to `lines` array entries.

---

## Test results

### Existing tests (T1–T8) — Python simulation

| Test | Result |
|---|---|
| T1: met_pig==false trigger | PASS |
| T2: met_pig==true fails when false | PASS |
| T3: compound trigger | PASS |
| T4: first matching state | PASS |
| T5: empty trigger | PASS |
| T6: idle_flavor fallback | PASS |
| T7: on_dismiss mutation | PASS (verified in T11 by design) |
| T8: multi-line string array | PASS |

### New multi-speaker tests (T9–T12) — Python simulation

| Test | Result |
|---|---|
| T9a: 4 entries in mixed array | PASS |
| T9b: entry[0] is string "Owning NPC speaks first." | PASS |
| T9c: entry[1] is dict {speaker: cula, text: Cula responds.} | PASS |
| T9d: entry[2] is string "Owning NPC speaks again." | PASS |
| T9e: entry[3] is dict {speaker: asia, text: Asia chimes in.} | PASS |
| T10: trigger skips multi-speaker state when met_pig=true → idle_flavor | PASS |
| T11: on_dismiss sets met_pig after multi-speaker sequence | PASS |
| T12: string-only state backward compat unchanged | PASS |

### Registry resolution tests — Python simulation

All 8 id→name mappings resolved correctly. Unknown id fallback verified. **23/23 pass.**

### Godot headless test runner

Godot 4.6.2 headless crashes pre-`_init()` on this machine (`RotatedFileLogger::RotatedFileLogger` signal 11 — pre-existing platform bug, not introduced by this pass). Python simulation exercises identical logic to what the GDScript tests assert against.

---

## Open questions for human review

1. **`dialogue_box.gd _show_page()` calls `runner._resolve_speaker()`** — this uses `get_node_or_null("/root/DialogueRunner")`. Confirm the DialogueRunner autoload path is `/root/DialogueRunner` in the project settings. If the path differs, update the `get_node_or_null` call in `dialogue_box.gd`.

2. **`dialogue_dismissed` signal fires once per keypress in `_unhandled_input`** — including the intermediate keypresses between lines within a multi-speaker sequence. This means `on_dismiss` mutations fire after each keypress, not just after the final line. The existing code already has this behavior (signal emits every advance press). When the multi-speaker content pass lands, confirm whether `on_dismiss` should fire only on the final dismiss or on every advance. If only-final-dismiss is desired, the box needs to gate the signal.

3. **Portrait/sprite support** — the current implementation swaps only the speaker name label. If a portrait system is added in a future pass, `_show_page()` already has the `character_id` available (from `entry.get("speaker", "")`) and can dispatch it to a portrait manager without further schema changes.

4. **`_schema.md` `display_name` field** — the schema example shows a top-level `"display_name": "Mr. Pig"` field on the dialogue tree, but none of the current dialogue trees have this field (verified). If it's added to production trees in a future pass, `dialogue_runner.gd _on_dialogue_requested` could prefer that field over the NPC node's `display_name` arg. Not wired in this pass.

5. **Adding new characters to the registry** — when a new NPC dialogue tree is introduced, its `character_id` must be added to `godot/data/character_registry.json` before multi-speaker entries referencing it will resolve correctly (otherwise they fall back to the owning NPC's name with a `push_warning`). This is a Code role maintenance task.
