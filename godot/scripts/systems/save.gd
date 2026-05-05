extends Node
## Save — versioned save/load for State.data.
## Sole writer: Code role (see AGENTS.md §File ownership).
##
## Versioning policy: bump State.SAVE_VERSION whenever State.reset_state()
## shape changes. Add a matching branch in migrate_save().
##
## Version history:
##   1 — initial structure (room_transition keys only)
##   2 — (no shape change; version bumped in sprint 2 for housekeeping)
##   3 — sprint 3: adds chapter1 sub-dictionary

const SAVE_PATH: String = "user://save.json"


## save_game — serialises State.data to disk with version metadata.
func save_game() -> void:
	var payload: Dictionary = {
		"version": State.SAVE_VERSION,
		"data": State.data,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Save: cannot open save path for writing: " + SAVE_PATH)
		return
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()


## load_game — reads save file, migrates if needed, applies to State.data.
## Returns true on success, false if file missing or unrecoverable.
func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Save: cannot open save file for reading.")
		return false
	var text: String = file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(text)
	if parsed == null or not parsed is Dictionary:
		push_error("Save: corrupt save file (JSON parse failed). Resetting.")
		State.data = State.reset_state()
		return false

	var version: int = int(parsed.get("version", 1))
	var saved_data: Dictionary = parsed.get("data", {})

	saved_data = migrate_save(saved_data, version)
	State.data = saved_data
	return true


## migrate_save — advances saved_data from old_version to State.SAVE_VERSION.
## Each version step must be idempotent and non-destructive.
func migrate_save(saved_data: Dictionary, old_version: int) -> Dictionary:
	## v1 -> v2: no structural change; nothing to do.
	if old_version < 2:
		pass

	## v2 -> v3: add chapter1 sub-dictionary if missing.
	if old_version < 3:
		if not saved_data.has("chapter1"):
			saved_data["chapter1"] = {
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
			}

	return saved_data
