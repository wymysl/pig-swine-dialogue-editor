extends Node
## State autoload — single writer. Owns all persistent game state and save/load.
## Migration required for every shape change (see AGENTS.md §Save migration policy).

const SAVE_VERSION: int = 3

## data — the live persistent game state. Updated by systems; read by UI and actors.
var data: Dictionary = {}

func _ready() -> void:
	data = reset_state()

## reset_state — returns the canonical empty-state Dictionary.
## Every key must have an explicit default; never rely on null.
## New fields added: current_scene_path, current_spawn_id (room_transition system).
## Sprint 3: chapter1 NPC interaction flags added.
func reset_state() -> Dictionary:
	return {
		## room_transition.gd: which scene is currently loaded.
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		## room_transition.gd: which spawn point the player last entered through.
		"current_spawn_id": "default",
		## Chapter 1 NPC encounter and item flags.
		"chapter1": {
			"met_pig": false,
			"pig_revealed_crisis": false,
			"met_murrow": false,
			"has_law_binder": false,
			"recruited_crab": false,
			"recruited_whimsy": false,
			"coffee_tutorial_seen": false,
			"court_ready": false,
			"entered_court": false,
			"court_outcome": "",
		},
	}
