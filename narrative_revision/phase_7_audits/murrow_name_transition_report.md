# Murrow Name Transition Report

**Date:** 2026-05-06  
**Task:** Dynamic display-name switching for Mr. Murrow — "Mr. Murrow" before address-form invitation, "Murrow" thereafter.

---

## Files Changed

| File | Summary |
|------|---------|
| `godot/data/dialogues/murrow.json` | Entries 11 and 13 of `first_meeting.lines` converted from plain strings to `{"speaker":"murrow_friend","text":"..."}` objects. Text verbatim, unchanged. |
| `godot/data/character_registry.json` | Added `"murrow_friend": "Murrow"` immediately after `"murrow": "Mr. Murrow"`. |
| `godot/scripts/actors/npc.gd` | Added two new `@export` properties; replaced unconditional `emit` with conditional emit that checks `State.data.chapter1[first_meeting_flag]`. |
| `godot/scenes/interiors/pig_swine_office.tscn` | Corrected Murrow's `display_name` from `"Murrow"` → `"Mr. Murrow"`; added `display_name_after_meeting = "Murrow"` and `first_meeting_flag = "met_murrow"`. |

---

## npc.gd Extension Diff

```diff
 ## Rule A compliance: "Asia", "Mr. Pig", "Murrow" (see AGENTS.md §Naming).
 @export var display_name: String = ""
+
+## display_name_after_meeting — speaker label used once first_meeting_flag is true.
+## Leave empty to always use display_name (default behaviour; existing NPCs unaffected).
+@export var display_name_after_meeting: String = ""
+
+## first_meeting_flag — the chapter1 sub-key (e.g. "met_murrow") whose true value
+## signals that the first-meeting state is complete. Leave empty to disable switching.
+@export var first_meeting_flag: String = ""

 # ... [_unhandled_input]
-        if sigs:
-            sigs.dialogue_requested.emit(npc_id, display_name)
+        if sigs:
+            var active_name: String = display_name
+            if first_meeting_flag != "" and display_name_after_meeting != "":
+                var state_node = get_node_or_null("/root/State")
+                if state_node and state_node.data.get("chapter1", {}).get(first_meeting_flag, false) == true:
+                    active_name = display_name_after_meeting
+                sigs.dialogue_requested.emit(npc_id, active_name)
+            else:
+                sigs.dialogue_requested.emit(npc_id, active_name)
```

**Backward compatibility:** Any NPC node that does not set `first_meeting_flag` or `display_name_after_meeting` follows the `else` branch and emits `display_name` exactly as before.

---

## Where Murrow's NPC Node Was Found

`godot/scenes/interiors/pig_swine_office.tscn` — node `[Murrow]` at line 117 (unique_id 1993353782), position `Vector2(780, 400)`.

**Pre-change values:**
```
npc_id = "murrow"
display_name = "Murrow"          ← was already post-meeting label, incorrect
npc_color = Color(0.48, 0.42, 0.29, 1)
```

**Post-change values:**
```
npc_id = "murrow"
display_name = "Mr. Murrow"      ← corrected to pre-meeting label
display_name_after_meeting = "Murrow"
first_meeting_flag = "met_murrow"
npc_color = Color(0.48, 0.42, 0.29, 1)
```

---

## Within-State Transition (Part A) — Summary

The `first_meeting` dialogue now reads:

| Index | Type | Speaker label | Text (excerpt) |
|-------|------|---------------|----------------|
| 0 | dict | Dr. A. Cula | "Mr. Murrow. I was told you'd have…" |
| 1–8 | strings / cula dicts | Mr. Murrow / Dr. A. Cula | case briefing |
| 9 | string | **Mr. Murrow** | "It is Murrow, to friends…" (address-form invitation) |
| 10 | dict | Dr. A. Cula | "Then it's Cula." |
| **11** | **murrow_friend dict** | **Murrow** | "I am still deciding whether reception staff…" |
| 12 | dict | Dr. A. Cula | "She'll be relieved either way." |
| **13** | **murrow_friend dict** | **Murrow** | "Binder first. Memo second…" |

`character_registry.json` resolves `"murrow_friend"` → `"Murrow"` for `dialogue_box.gd`'s `_show_page()` lookup at `/root/DialogueRunner`.

---

## Test Results

```
python3 -c "import json; json.load(open('godot/data/character_registry.json')); json.load(open('godot/data/dialogues/murrow.json')); print('valid')"
→ valid
```

Assertion checks:
- `murrow_friend` → `"Murrow"` ✅
- Entry 11 is `{"speaker": "murrow_friend", "text": "I am still deciding..."}` ✅
- Entry 13 is `{"speaker": "murrow_friend", "text": "Binder first..."}` ✅

> [!NOTE]
> Headless Godot test runner (`test_dialogue_runner.gd`, `test_asia_progression.gd`) was not available in this environment. No dialogue runner logic was modified; the changes are purely data-layer (JSON) and additive GDScript. The 12 existing runner tests are expected to pass without modification.

---

## Open Questions for Human Review

1. **`court_readiness_check` state:** Murrow's lines in this later state (entries 0, 2, 3, 5, 6, 8) are plain strings without a `speaker` override, meaning they will display under whatever label the NPC node emits (`"Murrow"` after `met_murrow == true`, which is correct). No change needed — documenting for awareness.

2. **`post_briefing_pre_binder` and `has_binder_pre_crab` states:** These are single `"line"` strings (not `"lines"` arrays) with no speaker override. They will also display as `"Murrow"` after the first meeting (via the NPC node's `display_name_after_meeting` path). This is correct per spec but is worth confirming visually.

3. **`idle_flavor` lines:** Two plain strings; will display as `"Murrow"` after first meeting and `"Mr. Murrow"` before — the NPC node controls this via the same conditional emit. Correct per spec.

4. **`first_meeting` entry 9** (`"It is Murrow, to friends…"`) remains a plain string and will display as `"Mr. Murrow"` (the NPC's `display_name` at the moment the state fires, because `met_murrow` is still `false` until `on_dismiss` fires). This is the intended transition point. ✅
