extends Node
## Signals autoload — sole signal bus for the entire project.
## All cross-system communication goes through this node.
## Single writer: Code role only (see AGENTS.md §File ownership).
##
## Signal declaration format:
##   signal signal_name(param: Type)  ## Brief payload description.

## Emitted when a room transition begins (before the fade-out starts).
## target_scene_path: res:// path of the scene being loaded.
signal room_transition_started(target_scene_path: String)

## Emitted when a room transition completes (after fade-in, player placed).
## target_scene_path: res:// path of the scene now active.
signal room_transition_finished(target_scene_path: String)

## Emitted by an NPC when the player presses interact while overlapping.
## npc_id: matches a key in data/dialogues/ (without .json extension).
## display_name: the canonical name for the speaker label (Rule A).
signal dialogue_requested(npc_id: String, display_name: String)

## Emitted by DialogueRunner when a line is resolved and ready to display.
## speaker: canonical display_name (Rule A). line: resolved text.
signal dialogue_line_ready(speaker: String, line: String)

## Emitted by the dialogue box when the player dismisses the current line.
signal dialogue_dismissed()
