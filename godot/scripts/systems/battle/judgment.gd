## scripts/systems/battle/judgment.gd
##
## Casebook Battle System — Judgment data resource.
##
## Hydrates one entry from data/judgments.json. A Judgment has no runtime
## side effects; battle_controller.gd decides when and how to invoke it.

class_name Judgment
extends Resource


var id: String = ""
var chapter_unlock: int = 0
var draft: bool = true
var tags: Dictionary = {
	"article": [],
	"principle": [],
	"context": [],
}
var principle_moves: Array[Resource] = []
var judgment_name: String = ""
var case_summary: String = ""


static func load_from_dict(d: Dictionary) -> Resource:
	var judgment = load("res://scripts/systems/battle/judgment.gd").new()
	judgment.id = str(d.get("id", ""))
	judgment.chapter_unlock = int(d.get("chapter_unlock", 0))
	judgment.draft = bool(d.get("draft", true))
	judgment.judgment_name = str(d.get("judgment_name", ""))
	judgment.case_summary = str(d.get("case_summary", ""))

	var raw_tags: Dictionary = {}
	if d.get("tags", {}) is Dictionary:
		raw_tags = d.get("tags", {})
	judgment.tags = {
		"article": _to_string_array(raw_tags.get("article", [])),
		"principle": _to_string_array(raw_tags.get("principle", [])),
		"context": _to_string_array(raw_tags.get("context", [])),
	}

	var raw_moves: Array = []
	if d.get("principle_moves", []) is Array:
		raw_moves = d.get("principle_moves", [])
	for raw_move in raw_moves:
		if not raw_move is Dictionary:
			push_error("Judgment.load_from_dict: principle move in '%s' is not a Dictionary" % judgment.id)
			continue
		var move_script := load("res://scripts/systems/battle/principle_move.gd") as GDScript
		var move = move_script.load_from_dict(raw_move, judgment.tags)
		if move != null:
			judgment.principle_moves.append(move)

	return judgment


func get_principle_move(move_id: String) -> Resource:
	for move in principle_moves:
		if move.id == move_id:
			return move
	return null


static func _to_string_array(value: Variant) -> Array[String]:
	var out: Array[String] = []
	if not value is Array:
		return out
	for item in value:
		out.append(str(item))
	return out
