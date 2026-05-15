## scripts/systems/battle/principle_move.gd
##
## Casebook Battle System — PrincipleMove data resource.
##
## A PrincipleMove is one invocable legal principle under a Judgment. It derives
## its weighted resolver tags from the parent Judgment's article/principle/context
## groups plus the move's effectiveness_modifiers.

class_name PrincipleMove
extends Resource


const ARTICLE_WEIGHT_KEY: String = "article_match_weight"
const PRINCIPLE_WEIGHT_KEY: String = "principle_match_weight"
const CONTEXT_WEIGHT_KEY: String = "context_match_weight"

var id: String = ""
var name: String = ""
var effectiveness_modifiers: Dictionary = {
	ARTICLE_WEIGHT_KEY: 1.0,
	PRINCIPLE_WEIGHT_KEY: 1.0,
	CONTEXT_WEIGHT_KEY: 1.0,
}
var cost: int = 0
var flavor_line: String = ""

var _judgment_tags: Dictionary = {
	"article": [],
	"principle": [],
	"context": [],
}


static func load_from_dict(d: Dictionary, judgment_tags: Dictionary = {}) -> Resource:
	var move = load("res://scripts/systems/battle/principle_move.gd").new()
	move.id = str(d.get("id", ""))
	move.name = str(d.get("name", ""))
	move.cost = int(d.get("cost", 0))
	move.flavor_line = str(d.get("flavor_line", ""))

	var raw_modifiers: Dictionary = {}
	if d.get("effectiveness_modifiers", {}) is Dictionary:
		raw_modifiers = d.get("effectiveness_modifiers", {})
	move.effectiveness_modifiers = {
		ARTICLE_WEIGHT_KEY: float(raw_modifiers.get(ARTICLE_WEIGHT_KEY, 1.0)),
		PRINCIPLE_WEIGHT_KEY: float(raw_modifiers.get(PRINCIPLE_WEIGHT_KEY, 1.0)),
		CONTEXT_WEIGHT_KEY: float(raw_modifiers.get(CONTEXT_WEIGHT_KEY, 1.0)),
	}
	move.set_judgment_tags(judgment_tags)
	return move


func set_judgment_tags(judgment_tags: Dictionary) -> void:
	_judgment_tags = {
		"article": _to_string_array(judgment_tags.get("article", [])),
		"principle": _to_string_array(judgment_tags.get("principle", [])),
		"context": _to_string_array(judgment_tags.get("context", [])),
	}


func get_weighted_tags() -> Dictionary[String, float]:
	var weighted: Dictionary[String, float] = {}
	_add_group_tags(
		weighted,
		_to_string_array(_judgment_tags.get("article", [])),
		float(effectiveness_modifiers.get(ARTICLE_WEIGHT_KEY, 1.0))
	)
	_add_group_tags(
		weighted,
		_to_string_array(_judgment_tags.get("principle", [])),
		float(effectiveness_modifiers.get(PRINCIPLE_WEIGHT_KEY, 1.0))
	)
	_add_group_tags(
		weighted,
		_to_string_array(_judgment_tags.get("context", [])),
		float(effectiveness_modifiers.get(CONTEXT_WEIGHT_KEY, 1.0))
	)
	return _normalise(weighted)


static func _add_group_tags(out: Dictionary[String, float], tag_ids: Array[String], group_weight: float) -> void:
	if tag_ids.is_empty() or group_weight <= 0.0:
		return
	var per_tag: float = group_weight / float(tag_ids.size())
	for tag_id in tag_ids:
		out[tag_id] = float(out.get(tag_id, 0.0)) + per_tag


static func _normalise(tags: Dictionary[String, float]) -> Dictionary[String, float]:
	var total: float = 0.0
	for tag_id in tags:
		total += float(tags[tag_id])
	if total <= 0.0:
		return {}

	var normalised: Dictionary[String, float] = {}
	for tag_id in tags:
		normalised[tag_id] = float(tags[tag_id]) / total
	return normalised


static func _to_string_array(value: Variant) -> Array[String]:
	var out: Array[String] = []
	if not value is Array:
		return out
	for item in value:
		out.append(str(item))
	return out
