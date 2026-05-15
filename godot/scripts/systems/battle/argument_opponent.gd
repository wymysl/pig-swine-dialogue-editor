## scripts/systems/battle/argument_opponent.gd
##
## Casebook Battle System — ArgumentOpponent data resource.
##
## Hydrates one opponent entry from data/argument_opponents.json, including the
## three Chapter 1 court rounds and their opposing moves.

class_name ArgumentOpponent
extends Resource


class OpponentMove:
	extends Resource

	var move_id: String = ""
	var display_name: String = ""
	var article_tags: Array[String] = []
	var principle_tags: Array[String] = []
	var context_tags: Array[String] = []
	var base_strength: int = 0
	var weak_to: Array[String] = []
	var resists: Array[String] = []
	var immune_to: Array[String] = []
	var on_intro: String = ""
	var on_defeat: String = ""
	var on_partial: String = ""
	var flavor_line: String = ""

	static func load_from_dict(d: Dictionary) -> OpponentMove:
		var move := OpponentMove.new()
		move.move_id = str(d.get("move_id", ""))
		move.display_name = str(d.get("display_name", ""))
		move.article_tags = _to_string_array(d.get("article_tags", []))
		move.principle_tags = _to_string_array(d.get("principle_tags", []))
		move.context_tags = _to_string_array(d.get("context_tags", []))
		move.base_strength = int(d.get("base_strength", 0))
		move.weak_to = _to_string_array(d.get("weak_to", []))
		move.resists = _to_string_array(d.get("resists", []))
		move.immune_to = _to_string_array(d.get("immune_to", []))
		move.on_intro = str(d.get("on_intro", ""))
		move.on_defeat = str(d.get("on_defeat", ""))
		move.on_partial = str(d.get("on_partial", ""))
		move.flavor_line = str(d.get("flavor_line", ""))
		return move

	func get_weakness_tags() -> Dictionary[String, float]:
		return _equal_weight_tags(weak_to)

	func get_strength_tags() -> Dictionary[String, float]:
		var combined: Array[String] = []
		for tag_id in resists:
			if not combined.has(tag_id):
				combined.append(tag_id)
		for tag_id in immune_to:
			if not combined.has(tag_id):
				combined.append(tag_id)
		return _equal_weight_tags(combined)

	func get_argument_tags() -> Dictionary[String, float]:
		var combined: Array[String] = []
		for group in [article_tags, principle_tags, context_tags]:
			for tag_id in group:
				if not combined.has(tag_id):
					combined.append(tag_id)
		return _equal_weight_tags(combined)

	static func _equal_weight_tags(tag_ids: Array[String]) -> Dictionary[String, float]:
		var out: Dictionary[String, float] = {}
		if tag_ids.is_empty():
			return out
		var weight: float = 1.0 / float(tag_ids.size())
		for tag_id in tag_ids:
			out[tag_id] = weight
		return out

	static func _to_string_array(value: Variant) -> Array[String]:
		var out: Array[String] = []
		if not value is Array:
			return out
		for item in value:
			out.append(str(item))
		return out


class CourtRound:
	extends Resource

	var round_tag: String = ""
	var react_tag: String = ""
	var round_label: String = ""
	var opening_statement: String = ""
	var pressure: int = 0
	var moves: Array[OpponentMove] = []
	var defeat_lines: Array[String] = []
	var partial_lines: Array[String] = []

	static func load_from_dict(d: Dictionary) -> CourtRound:
		var round := CourtRound.new()
		round.round_tag = str(d.get("round_tag", ""))
		round.react_tag = str(d.get("react_tag", ""))
		round.round_label = str(d.get("round_label", ""))
		round.opening_statement = str(d.get("opening_statement", ""))
		round.pressure = int(d.get("pressure", 0))
		round.defeat_lines = OpponentMove._to_string_array(d.get("defeat_lines", []))
		round.partial_lines = OpponentMove._to_string_array(d.get("partial_lines", []))

		var raw_moves: Array = []
		if d.get("moves", []) is Array:
			raw_moves = d.get("moves", [])
		for raw_move in raw_moves:
			if not raw_move is Dictionary:
				push_error("ArgumentOpponent.CourtRound: move in '%s' is not a Dictionary" % round.round_tag)
				continue
			round.moves.append(OpponentMove.load_from_dict(raw_move))
		return round

	func get_move(move_id: String) -> OpponentMove:
		for move in moves:
			if move.move_id == move_id:
				return move
		return null

	func get_move_at(index: int) -> OpponentMove:
		if index < 0 or index >= moves.size():
			return null
		return moves[index]


var id: String = ""
var chapter: int = 0
var display_name: String = ""
var court_rounds: Array[CourtRound] = []


static func load_from_dict(d: Dictionary) -> Resource:
	var opponent = load("res://scripts/systems/battle/argument_opponent.gd").new()
	opponent.id = str(d.get("id", ""))
	opponent.chapter = int(d.get("chapter", 0))
	opponent.display_name = str(d.get("display_name", ""))

	var raw_rounds: Array = []
	if d.get("court_rounds", []) is Array:
		raw_rounds = d.get("court_rounds", [])
	for raw_round in raw_rounds:
		if not raw_round is Dictionary:
			push_error("ArgumentOpponent.load_from_dict: court round in '%s' is not a Dictionary" % opponent.id)
			continue
		opponent.court_rounds.append(CourtRound.load_from_dict(raw_round))
	return opponent


func get_round(round_index: int) -> CourtRound:
	var index: int = round_index - 1
	if round_index == 0:
		index = 0
	if index < 0 or index >= court_rounds.size():
		return null
	return court_rounds[index]


func get_round_by_state(state_tag: String) -> CourtRound:
	for round in court_rounds:
		if round.round_tag == state_tag or round.react_tag == state_tag:
			return round
	return null
