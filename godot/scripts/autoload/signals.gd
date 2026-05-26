extends Node
## Signals autoload — sole signal bus for the entire project.
## All cross-system communication goes through this node.
## Single writer: Code role only (see AGENTS.md §File ownership).
##
## Signal declaration format:
##   signal signal_name(param: Type)  ## Brief payload description.

## Emitted when an argument fragment is added to the Blue Folder.
## fragment_id: key from data/argument_fragments.json.
## TODO(consumer): Badge/toast feedback is deferred; see 2026-05-19 tech critique F5.
@warning_ignore("unused_signal")
signal case_folder_fragment_added(fragment_id: String)

## Emitted when the player picks up the Blue Folder for the first time.
## TODO(consumer): Pickup acknowledgment UI is deferred; see 2026-05-19 tech critique F5.
@warning_ignore("unused_signal")
signal case_folder_acquired()

## Emitted when the Blue Folder UI opens or closes.
## is_open: true after open(), false after close().
## TODO(consumer): Pause/HUD affordance is deferred; see 2026-05-19 tech critique F5.
@warning_ignore("unused_signal")
signal case_folder_toggled(is_open: bool)

## Emitted by UI surfaces that request an immediate manual save.
@warning_ignore("unused_signal")
signal manual_save_requested()

## Emitted after save_game writes user://save.json successfully.
@warning_ignore("unused_signal")
signal save_completed()

## Emitted when save/load cannot complete safely.
## reason: short player-facing explanation of the failure.
@warning_ignore("unused_signal")
signal save_failed(reason: String)

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
##            client_meeting_evidence, casebook_judge_state, coffee_buff,
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

## Emitted by DialogueRunner when an options block with "chain": true commits
## an option. Signals DialogueBox to suppress its post-commit dismiss so the
## runner can immediately fire the next matching state for the same NPC,
## keeping the panel open and loading new content without a visible close/reopen.
@warning_ignore("unused_signal")
signal dialogue_chain_start()

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

## round_index/proposed_frame: wrong-shape court frame lowered initial judicial patience.
## TODO(consumer): Judge-skepticism camera/HUD response is deferred; see 2026-05-19 tech critique F5.
@warning_ignore("unused_signal")
signal judge_skepticism_raised(round_index: int, proposed_frame: String)

## Trial Record panel — emitted by BattleController.start_round() when a new court round begins.
## round_index: 0 = rehearsal, 1–3 = live rounds (matches controller _round_index).
@warning_ignore("unused_signal")
signal trial_record_round_started(round_index: int)

## Trial Record panel — emitted when Phase 1 fact-finding establishes a fact-flag.
## evidence_id: the piece of evidence that was established (key in evidence_ch1.json).
## flag_name: the chapter1 flag written (e.g. "packet_slot_address_non_current").
@warning_ignore("unused_signal")
signal trial_record_fact_established(evidence_id: String, flag_name: String)

## Trial Record panel — emitted when a Phase 2 citation resolves against the opponent move.
## citation_id: the evidence/judgment move id cited by the player.
## bucket: one of super_effective / effective / not_very_effective / no_effect / backfires.
## opponent_move: the opponent move's display_name for the move that was in play.
@warning_ignore("unused_signal")
signal trial_record_citation_resolved(citation_id: String, bucket: String, opponent_move: String)

## Trial Record panel — emitted by opponent_advance() when an opposing move is presented.
## move_display_name: the opponent move's human-readable name; empty string if no move active.
@warning_ignore("unused_signal")
signal trial_record_opponent_stated(move_display_name: String)

## Trial Record panel — emitted after consume_assembled_packet() scores the packet.
## packet_result: the Dictionary returned by consume_assembled_packet() (includes outcome band).
@warning_ignore("unused_signal")
signal trial_record_packet_scored(packet_result: Dictionary)

## Emitted by consume_assembled_packet() when the packet scorer returns crab_support_withdrawn
## (i.e. decoy_incapacity was filed and Crab was still recruited). Replaces the former silent
## _write_chapter1_flag("recruited_crab", false) in battle_controller.gd (Step 5.2,
## 2026-05-26 design plan). Consumer: court-round NPC layer serves crab_incapacity_withdrawal
## dialogue state; that state's on_dismiss writes recruited_crab = false.
@warning_ignore("unused_signal")
signal crab_withdrew_after_incapacity()
