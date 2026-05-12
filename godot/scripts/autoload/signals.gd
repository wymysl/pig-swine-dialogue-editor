extends Node
## Signals autoload — sole signal bus for the entire project.
## All cross-system communication goes through this node.
## Single writer: Code role only (see AGENTS.md §File ownership).
##
## Signal declaration format:
##   signal signal_name(param: Type)  ## Brief payload description.

## Emitted when a room transition begins (before the fade-out starts).
## target_scene_path: res:// path of the scene being loaded.
@warning_ignore("unused_signal")
signal room_transition_started(target_scene_path: String)

## Emitted when a room transition completes (after fade-in, player placed).
## target_scene_path: res:// path of the scene now active.
@warning_ignore("unused_signal")
signal room_transition_finished(target_scene_path: String)

## Emitted by an NPC when the player presses interact while overlapping.
## npc_id: matches a key in data/dialogues/ (without .json extension).
## display_name: the canonical name for the speaker label (Rule A).
@warning_ignore("unused_signal")
signal dialogue_requested(npc_id: String, display_name: String)

## Emitted by DialogueRunner when a line is resolved and ready to display.
## speaker: canonical display_name (Rule A). npc_id: stable character key for portrait lookup.
## lines: Array of strings for paginated dialogue.
@warning_ignore("unused_signal")
signal dialogue_line_ready(speaker: String, npc_id: String, lines: Array)

## Emitted by the dialogue box when the player dismisses the current line.
@warning_ignore("unused_signal")
signal dialogue_dismissed()

## Emitted when the entire dialogue sequence finishes and the box closes.
@warning_ignore("unused_signal")
signal dialogue_ended()

## Emitted when the player picks up an item.
@warning_ignore("unused_signal")
signal item_picked_up(item_id: String, display_name: String)

## Emitted when a minigame concludes.
@warning_ignore("unused_signal")
signal minigame_finished(minigame_id: String, outcome: String)

## Emitted by any caller that mutates a `State.data.chapter1.<flag>` value.
## flag_name: the chapter1 dictionary key that just changed (e.g. "met_pig").
## new_value: the value written. Typed as Variant because chapter1 holds a
##            mix of bool (most flags), String (court_outcome, client_meeting_stance,
##            bonus_evidence_collected, casebook_judge_state, coffee_buff,
##            coffee_brew_grade), and potentially other types as the schema
##            grows. Subscribers that care about the actual value should
##            re-read State.data.chapter1[flag_name] rather than rely on the
##            payload type.
##
## NPCs subscribe in `scripts/actors/npc.gd` to re-evaluate their
## `presence_flags` visibility gate. This is an event channel only — it does
## NOT add a field to State.data, and it does NOT introduce a beat enum.
## Beats live in `narrative_revision/` as story content; runtime presence keys
## off the existing chapter1 flag bag.
##
## Contract: callers that write `State.data.chapter1.<flag>` are responsible
## for emitting this signal after the write completes. Failing to emit means
## NPCs gated on that flag will not refresh until the next scene load (when
## _ready() re-evaluates).
@warning_ignore("unused_signal")
signal chapter1_flag_changed(flag_name: String, new_value: Variant)

## Emitted by DialogueRunner when an `award_badge` action fires from a
## dialogue's on_dismiss. badge_id is the key written to State.data.badges.
## Consumers: badge popup UI (A.4 — not yet implemented).
@warning_ignore("unused_signal")
signal badge_awarded(badge_id: String)

## Emitted by DialogueRunner when an `unlock_route` action fires from a
## dialogue's on_dismiss. route_id is the key written to State.data.routes_unlocked.
## Consumers: route-unlock acknowledgment UI (A.4 — not yet implemented).
@warning_ignore("unused_signal")
signal route_unlocked(route_id: String)

## Emitted by DialogueRunner when the matched state has an `options` block.
## Fires immediately after dialogue_line_ready for the same state.
## write_path: dotted key path into State.data (e.g. "chapter1.client_meeting_stance").
## choices: Array of Dictionaries shaped { "text": String, "value": Variant }.
##
## DialogueBox subscribes to render the choice list under the prompt line.
## Player navigates with move_up/move_down and commits with interact (E).
## Selected option is rendered in red; non-selected in the default font color.
@warning_ignore("unused_signal")
signal dialogue_options_ready(write_path: String, choices: Array)

## Emitted by DialogueBox when the player commits a selected option.
## DialogueRunner subscribes to apply the write (and any on_dismiss actions)
## then clears its mutation queue so the subsequent dialogue_dismissed
## signal is a no-op.
@warning_ignore("unused_signal")
signal dialogue_option_committed(value: Variant)

## Emitted by coffee_brewing.gd when the minigame completes and the result
## panel is dismissed. Payload shape (all fields present):
##   { "minigame": "coffee_brewing", "context": String,
##     "grade": "S"|"A"|"B"|"C"|"D"|"F", "result": String,
##     "buff": "procedurally_alert_plus"|"procedurally_alert"|"caffeinated"|"over_caffeinated",
##     "brew_quality": int, "bitterness": int,
##     "perfect_hits": int, "good_hits": int, "okay_hits": int, "misses": int,
##     "assist_used": bool }
## NOTE: coffee_brewing.gd also emits minigame_finished("coffee_brewing", buff)
## for back-compat with the barista dialogue gate in barista.json.
@warning_ignore("unused_signal")
signal coffee_brewing_completed(result: Dictionary)
