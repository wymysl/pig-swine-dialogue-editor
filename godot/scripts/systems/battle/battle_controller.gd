## scripts/systems/battle/battle_controller.gd
##
## Casebook Battle System — Chapter 1 court-round encounter runner.
##
## Restored from the c83feaa skeleton, but reworked for the v17 player-driven
## argument state and the live Effectiveness resolver. The old seed assumed
## court-round JSON with authored buckets; this controller consumes the current
## judgments/opponents/evidence/frame data and resolves buckets dynamically.

class_name BattleController
extends Node


class PhaseOneController:
	extends RefCounted

	var witness_cooperation: int = 0
	var established_evidence_ids: Dictionary = {}
	var press_count: int = 0

	func start(initial_cooperation: int) -> void:
		witness_cooperation = max(0, initial_cooperation)
		established_evidence_ids.clear()
		press_count = 0

	func spend_press(cost: int) -> int:
		press_count += 1
		witness_cooperation = max(0, witness_cooperation - max(0, cost))
		return witness_cooperation

	func establish_evidence(evidence_id: String) -> void:
		if evidence_id != "":
			established_evidence_ids[evidence_id] = true

	func has_established(evidence_id: String) -> bool:
		return established_evidence_ids.get(evidence_id, false)


class PhaseTwoController:
	extends RefCounted

	var judicial_patience: int = 5
	var proposed_frame: String = ""
	var allowed_evidence_ids: Dictionary = {}
	var wrong_shape_frame: bool = false

	func start(
		initial_patience: int,
		frame_id: String,
		frames: Dictionary,
		chapter1: Dictionary,
		state_rank: int
	) -> void:
		judicial_patience = max(0, initial_patience)
		proposed_frame = frame_id
		wrong_shape_frame = false
		allowed_evidence_ids.clear()

		var frame: Dictionary = {}
		if frames.get(frame_id, {}) is Dictionary:
			frame = frames.get(frame_id, {})
		if frame.is_empty():
			return

		wrong_shape_frame = not bool(frame.get("well_fitted", false))
		if _frame_unlocked(frame, chapter1, state_rank):
			for evidence_id in frame.get("supporting_evidence", []):
				allowed_evidence_ids[str(evidence_id)] = true

	func apply_present_bucket(bucket: String) -> int:
		if bucket == "backfires" or bucket == "no_effect":
			judicial_patience = max(0, judicial_patience - 1)
			return -1
		return 0

	func is_evidence_available(evidence_id: String, chapter1: Dictionary, evidence: Dictionary) -> bool:
		if evidence_id == "":
			return true
		if allowed_evidence_ids.get(evidence_id, false):
			return true
		var entry: Dictionary = {}
		if evidence.get(evidence_id, {}) is Dictionary:
			entry = evidence.get(evidence_id, {})
		var flag_path: String = str(entry.get("sets_flag", ""))
		if flag_path.begins_with("chapter1."):
			var key: String = flag_path.substr(9)
			if chapter1.get(key, false) == true:
				return true
			if key == "client_meeting_evidence" and chapter1.get(key, "") == evidence_id:
				return true
		return false

	func _frame_unlocked(frame: Dictionary, chapter1: Dictionary, state_rank: int) -> bool:
		var unlock_rank: int = _state_rank_for_tag(str(frame.get("court_round_unlock", "")))
		if unlock_rank > state_rank:
			return false
		for requirement in frame.get("requires_flags", []):
			if not _requirement_met(str(requirement), chapter1):
				return false
		return true

	func _requirement_met(requirement: String, chapter1: Dictionary) -> bool:
		if not requirement.begins_with("chapter1."):
			return true
		var expression: String = requirement.substr(9)
		if expression.contains("=="):
			var parts: PackedStringArray = expression.split("==", false, 1)
			if parts.size() != 2:
				return false
			var key: String = parts[0].strip_edges()
			var expected: String = parts[1].strip_edges().trim_prefix("'").trim_suffix("'").trim_prefix("\"").trim_suffix("\"")
			return str(chapter1.get(key, "")) == expected
		return bool(chapter1.get(expression.strip_edges(), false))

	func _state_rank_for_tag(tag: String) -> int:
		match tag:
			"round_1_open": return 1
			"round_1_react": return 2
			"round_2_open": return 3
			"round_2_react": return 4
			"round_3_open": return 5
			"round_3_remedy": return 6
			_: return 999


const JUDGMENTS_PATH: String = "res://data/judgments.json"
const OPPONENTS_PATH: String = "res://data/argument_opponents.json"
const TAXONOMY_PATH: String = "res://data/tag_taxonomy.json"
const EVIDENCE_PATH: String = "res://data/evidence_ch1.json"
const FRAMES_PATH: String = "res://data/argument_frames_ch1.json"
const ROUND_FILE_TEMPLATE: String = "res://data/court_rounds/chapter%d_round_%d.json"
const REHEARSAL_PATH: String = "res://data/court_rounds/chapter1_round_0_rehearsal.json"
const JUDGMENT_SCRIPT = preload("res://scripts/systems/battle/judgment.gd")
const OPPONENT_SCRIPT = preload("res://scripts/systems/battle/argument_opponent.gd")
const PACKET_SCORER = preload("res://scripts/systems/battle/packet_scorer.gd")

const PACKET_SLOT_ADDRESS: String = "element_non_current_address"
const PACKET_SLOT_KNOWLEDGE: String = "element_landlord_knowledge"
const PACKET_SLOT_WINDOW: String = "element_timely_actual_notice_motion"
const PACKET_SLOT_AUTHORITY: String = "element_no_third_party_cure"
const PACKET_SLOT_ORDER: Array[String] = [
	PACKET_SLOT_ADDRESS,
	PACKET_SLOT_KNOWLEDGE,
	PACKET_SLOT_WINDOW,
	PACKET_SLOT_AUTHORITY,
]
const PACKET_SLOT_STATE_KEYS: Dictionary = {
	PACKET_SLOT_ADDRESS: "packet_slot_address_non_current",
	PACKET_SLOT_KNOWLEDGE: "packet_slot_landlord_knowledge",
	PACKET_SLOT_WINDOW: "packet_slot_actual_notice_window",
	PACKET_SLOT_AUTHORITY: "packet_slot_no_third_party_authority",
}

const FRAME_DEFAULT: String = "defective_service_135bis"
const DEFAULT_REMEDY: String = "procedural_reset"
const OUTCOME_STRONG: String = "strong"
const OUTCOME_STANDARD: String = "standard"
const OUTCOME_NARROW: String = "narrow"
const OUTCOME_BLUNDER_RECOVERED: String = "blunder-recovered"

const PHASE_ONE_STARTING_COOPERATION: int = 3
const PHASE_TWO_DEFAULT_PATIENCE: int = 5
const WRONG_SHAPE_PATIENCE: int = 3

const VALID_BUCKETS: Array[String] = [
	"super_effective",
	"effective",
	"not_very_effective",
	"no_effect",
	"backfires",
]

const STATE_RANKS: Dictionary = {
	"round_1_open": 1,
	"round_1_react": 2,
	"round_2_open": 3,
	"round_2_react": 4,
	"round_3_open": 5,
	"round_3_remedy": 6,
}

var _judgments: Dictionary = {}
var _opponents: Dictionary = {}
var _evidence: Dictionary = {}
var _frames: Dictionary = {}
var _taxonomy: Dictionary = {}

var _loaded: bool = false
var _taxonomy_valid: bool = false
var _active_opponent: Resource = null
var _active_round: Resource = null
var _round_index: int = 0
var _current_move_index: int = 0
var _round_buckets: Dictionary = {}
var _last_result: Dictionary = {}
var _packet_submission_applied: bool = false
var _packet_submission_result: Dictionary = {}
var _phase_one: PhaseOneController = PhaseOneController.new()
var _phase_two: PhaseTwoController = PhaseTwoController.new()

## Per-round data file cache — populated by start_round() from
## chapter%d_round_%d.json. Replaces the old recursive-start_round model that
## inherited Phase 1 state across rounds. Step 3.2 narrow scope (2026-05-26
## design plan): the file is loaded so downstream consumers (UI, dialogue,
## future per-round Phase 1 → Phase 2 wiring) can read declared witnesses,
## judge counter-questions, and victory_resolution branches. The current
## controller still uses opponent.get_round() for opponent moves and computes
## the dispositive outcome via _compute_court_outcome(); evaluating
## victory_resolution from the data file is a deferred follow-up.
var _active_round_data: Dictionary = {}

## _rehearsal_active — true while a start_rehearsal() session is in progress.
## Cleared by end_rehearsal(). Guards rehearsal_press / rehearsal_present so
## they cannot fire during a live court round, and vice versa.
var _rehearsal_active: bool = false


static func state_rank_for_tag(tag: String) -> int:
	return int(STATE_RANKS.get(tag, 999))


func _ready() -> void:
	load_data()


func load_data() -> bool:
	_judgments.clear()
	_opponents.clear()
	_evidence.clear()
	_frames.clear()
	_taxonomy.clear()
	_loaded = false
	_taxonomy_valid = false
	_packet_submission_applied = false
	_packet_submission_result = {}

	if not _load_judgments():
		return false
	if not _load_opponents():
		return false
	if not _load_named_block(EVIDENCE_PATH, "evidence", _evidence):
		return false
	if not _load_named_block(FRAMES_PATH, "frames", _frames):
		return false

	var parsed_taxonomy: Dictionary = _load_json_dictionary(TAXONOMY_PATH)
	if parsed_taxonomy.is_empty():
		return false
	_taxonomy = parsed_taxonomy
	_loaded = true
	_taxonomy_valid = _validate_battle_tags()
	return _taxonomy_valid


func get_judgment(judgment_id: String) -> Resource:
	return _judgments.get(judgment_id, null)


func get_opponent(opponent_id: String) -> Resource:
	return _opponents.get(opponent_id, null)


func get_last_result() -> Dictionary:
	return _last_result.duplicate(true)


func start_round(opponent_id: String, round_index: int) -> void:
	if not _ensure_loaded():
		return
	var opponent: Resource = _opponents.get(opponent_id, null)
	if opponent == null:
		push_error("BattleController.start_round: unknown opponent_id '%s'" % opponent_id)
		return
	var round: Resource = opponent.get_round(round_index)
	if round == null:
		push_error("BattleController.start_round: round_index %d missing for '%s'" % [round_index, opponent_id])
		return

	_active_opponent = opponent
	_active_round = round
	_round_index = round_index
	_current_move_index = 0
	_last_result = {}
	_active_round_data = _load_round_file(opponent.chapter, round_index)

	if _is_phase_one_round(round_index):
		if round_index == 1:
			consume_assembled_packet()
		_phase_one.start(PHASE_ONE_STARTING_COOPERATION)
		_write_chapter1_flag("witness_cooperation", _phase_one.witness_cooperation)
	else:
		if not _packet_submission_applied:
			consume_assembled_packet()
		var proposed_frame: String = str(_chapter1().get("proposed_frame", ""))
		var starting_patience: int = int(_chapter1().get("judicial_patience", PHASE_TWO_DEFAULT_PATIENCE))
		if _is_merits_frame(proposed_frame):
			starting_patience = min(starting_patience, WRONG_SHAPE_PATIENCE)
		_phase_two.start(starting_patience, proposed_frame, _frames, _chapter1(), state_rank_for_tag(round.round_tag))
		_write_chapter1_flag("judicial_patience", _phase_two.judicial_patience)
		if _is_merits_frame(proposed_frame) or not _packet_submission_result.get("selected_blunders", []).is_empty():
			_emit_judge_skepticism(round_index, proposed_frame)

	_write_chapter1_flag("casebook_judge_state", round.round_tag)
	_emit_trial_record_round_started(round_index)


func opponent_advance() -> Dictionary:
	if _active_round == null:
		push_error("BattleController.opponent_advance: no active round")
		return {}

	var current_state: String = str(_chapter1().get("casebook_judge_state", ""))
	if current_state == _active_round.round_tag:
		_write_chapter1_flag("casebook_judge_state", _active_round.react_tag)
	elif current_state == _active_round.react_tag and _current_move_index < _active_round.moves.size() - 1:
		_current_move_index += 1

	var move: Resource = _current_opponent_move()
	var result: Dictionary = {
		"round_index": _round_index,
		"state": str(_chapter1().get("casebook_judge_state", "")),
		"opening_statement": _active_round.opening_statement,
		"pressure": _active_round.pressure,
		"opponent_move_id": "",
		"opponent_move": "",
	}
	if move != null:
		result["opponent_move_id"] = move.move_id
		result["opponent_move"] = move.display_name
	_emit_trial_record_opponent_stated(str(result.get("opponent_move", "")))
	_last_result = result
	return result


func player_press(witness_statement_id: String) -> Dictionary:
	if _active_round == null:
		push_error("BattleController.player_press: no active round")
		return {}
	if not _is_phase_one_round(_round_index):
		push_error("BattleController.player_press: Press is only available during Phase 1")
		return {}

	_select_opponent_move(witness_statement_id)
	var opponent_move: Resource = _current_opponent_move()
	var move_tags: Dictionary[String, float] = _weighted_tags_for_evidence(witness_statement_id)
	var resolved: Dictionary = _resolve_against_current(move_tags, opponent_move)

	_phase_one.spend_press(1)
	_write_chapter1_flag("witness_cooperation", _phase_one.witness_cooperation)
	if _evidence.has(witness_statement_id):
		_establish_evidence(witness_statement_id)

	var result: Dictionary = _base_result(resolved)
	result["action"] = "press"
	result["witness_statement_id"] = witness_statement_id
	result["witness_cooperation"] = _phase_one.witness_cooperation
	_last_result = result
	return result


func player_present(move: Resource, evidence_id: String) -> Dictionary:
	if _active_round == null:
		push_error("BattleController.player_present: no active round")
		return {}
	if move == null:
		push_error("BattleController.player_present: move is null")
		return {}

	var opponent_move: Resource = _current_opponent_move()
	var move_tags: Dictionary[String, float] = _combine_move_and_evidence_tags(move.get_weighted_tags(), evidence_id)
	var taxonomy_ok: bool = Effectiveness.validate_against_taxonomy(move_tags, _taxonomy)
	var evidence_available: bool = true
	if not _is_phase_one_round(_round_index):
		evidence_available = _phase_two.is_evidence_available(evidence_id, _chapter1(), _evidence)

	var resolved: Dictionary = _resolve_against_current(move_tags, opponent_move)
	if not evidence_available and resolved.get("bucket", "no_effect") != "backfires":
		resolved = {
			"bucket": "no_effect",
			"score": 0.0,
			"primary_match": "",
		}

	var bucket: String = str(resolved.get("bucket", "no_effect"))
	var multiplier: float = Effectiveness.bucket_to_force_multiplier(bucket)
	var pressure_delta: int = int(round(float(_active_round.pressure) * max(0.0, multiplier)))
	var patience_delta: int = 0
	if _is_phase_one_round(_round_index):
		if bucket != "backfires" and bucket != "no_effect":
			_establish_evidence(evidence_id)
	else:
		patience_delta = _phase_two.apply_present_bucket(bucket)
		_write_chapter1_flag("judicial_patience", _phase_two.judicial_patience)

	_round_buckets[_round_index] = bucket
	if not _is_phase_one_round(_round_index):
		var opponent_move_id: String = ""
		if opponent_move != null:
			opponent_move_id = opponent_move.move_id
		_append_phase2_result(_round_index, move.id, bucket, opponent_move_id, evidence_id, evidence_available)

	var result: Dictionary = _base_result(resolved)
	result["action"] = "present"
	result["move_id"] = move.id
	result["evidence_id"] = evidence_id
	result["taxonomy_valid"] = taxonomy_ok
	result["evidence_available"] = evidence_available
	result["force_multiplier"] = multiplier
	result["opponent_pressure"] = _active_round.pressure
	result["opponent_pressure_delta"] = pressure_delta
	result["judicial_patience"] = int(_chapter1().get("judicial_patience", 0))
	result["judicial_patience_delta"] = patience_delta
	result["witness_cooperation"] = int(_chapter1().get("witness_cooperation", 0))
	_last_result = result
	return result


## end_round closes the active round. Step 3.2 (2026-05-26 design plan) dropped
## the recursive start_round(opp, N+1) hand-off: the caller now drives the next
## round explicitly via start_round(_active_opponent.id, result.next_round_index).
## End-of-Round-3 still computes the dispositive court_outcome via
## _compute_court_outcome() against the accumulated phase2_round_results.
func end_round() -> Dictionary:
	if _active_round == null or _active_opponent == null:
		push_error("BattleController.end_round: no active round")
		return {}

	var bucket: String = str(_round_buckets.get(_round_index, "no_effect"))
	var round_non_backfire: bool = bucket != "backfires"
	var result: Dictionary = {
		"round_index": _round_index,
		"bucket": bucket,
		"round_non_backfire": round_non_backfire,
		"court_won_procedural_reset": false,
		"court_outcome": "",
	}

	if _round_index < 3:
		_write_chapter1_flag("casebook_judge_state", _active_round.react_tag)
		result["next_round_index"] = _round_index + 1
		result["casebook_judge_state"] = str(_chapter1().get("casebook_judge_state", ""))
		_last_result = result
		return result

	_write_chapter1_flag("casebook_judge_state", _active_round.react_tag)

	var packet_result: Dictionary = consume_assembled_packet()
	var outcome: String = _compute_court_outcome(packet_result)
	_write_chapter1_flag("court_won_procedural_reset", true)
	_write_chapter1_flag("won_court", true)
	_write_chapter1_flag("court_outcome", outcome)
	result["packet_score"] = packet_result
	result["court_won_procedural_reset"] = bool(_chapter1().get("court_won_procedural_reset", false))
	result["court_outcome"] = outcome
	result["casebook_judge_state"] = str(_chapter1().get("casebook_judge_state", ""))
	_last_result = result
	return result


## start_rehearsal — begins the Phase-1-only Murrow rehearsal encounter.
##
## Loads chapter1_round_0_rehearsal.json, arms the PhaseOneController with the
## file's declared witness_cooperation_total, and emits trial_record_round_started(0)
## so the Trial Record panel (Step 1.2) can surface as a teaching UI. No
## opponent; no packet; no outcome band. Call end_rehearsal() to close.
##
## Returns false if data has not loaded or the rehearsal file is missing.
func start_rehearsal() -> bool:
	if not _ensure_loaded():
		return false
	var rehearsal_data: Dictionary = _load_json_dictionary(REHEARSAL_PATH)
	if rehearsal_data.is_empty():
		push_error("BattleController.start_rehearsal: failed to load rehearsal file")
		return false

	_active_round_data = rehearsal_data
	_rehearsal_active = true
	_round_index = 0
	_last_result = {}

	var pf: Dictionary = {}
	if rehearsal_data.get("phase_1_fact_finding", {}) is Dictionary:
		pf = rehearsal_data["phase_1_fact_finding"]
	var cooperation: int = int(pf.get("witness_cooperation_total", 3))
	_phase_one.start(cooperation)

	_emit_trial_record_round_started(0)
	return true


## end_rehearsal — closes the active rehearsal and writes the sole persistent
## flag: chapter1.rehearsal_complete = true. Returns a result Dictionary for
## downstream consumers (dialogue trigger, test assertions).
func end_rehearsal() -> Dictionary:
	if not _rehearsal_active:
		push_error("BattleController.end_rehearsal: no rehearsal in progress")
		return {}
	_rehearsal_active = false
	_write_chapter1_flag("rehearsal_complete", true)
	_active_round_data = {}
	var result: Dictionary = {
		"rehearsal_complete": true,
		"facts_established": _phase_one.established_evidence_ids.keys(),
		"presses_used": _phase_one.press_count,
	}
	_last_result = result
	return result


## is_rehearsal_active — true between start_rehearsal() and end_rehearsal().
func is_rehearsal_active() -> bool:
	return _rehearsal_active


## rehearsal_press — advance the Phase 1 cooperation counter and record a
## fact from the rehearsal witness. Does NOT write to chapter1 state (the
## rehearsal is consequence-free; only rehearsal_complete persists). Emits
## trial_record_fact_established with an empty flag_name so the Trial Record
## panel can render the press without triggering state-change side-effects.
##
## statement_id: the witness statement id being pressed (from the rehearsal
## file's witnesses[].statements[].press_options[].follow_up_statement_id).
## local_fact_flag: the _rehearsal._fact.* flag id declared in the rehearsal
## file (empty string if the press sets no local fact).
func rehearsal_press(statement_id: String, local_fact_flag: String) -> Dictionary:
	if not _rehearsal_active:
		push_error("BattleController.rehearsal_press: no rehearsal in progress")
		return {}
	_phase_one.spend_press(1)
	if local_fact_flag != "":
		_phase_one.establish_evidence(local_fact_flag)
		_emit_trial_record_fact_established(statement_id, "")
	var result: Dictionary = {
		"action": "rehearsal_press",
		"statement_id": statement_id,
		"local_fact_flag": local_fact_flag,
		"witness_cooperation": _phase_one.witness_cooperation,
		"presses_used": _phase_one.press_count,
	}
	_last_result = result
	return result


## rehearsal_present — establish a fact from the rehearsal witness via a
## presented document. Like rehearsal_press, writes nothing to chapter1 state.
## Emits trial_record_fact_established so the Trial Record panel surfaces the
## fact as it would in a live round.
##
## evidence_id: the evidence id being presented (from present_options[].evidence_id).
## local_fact_flag: the _rehearsal._fact.* flag declared in the rehearsal file.
func rehearsal_present(evidence_id: String, local_fact_flag: String) -> Dictionary:
	if not _rehearsal_active:
		push_error("BattleController.rehearsal_present: no rehearsal in progress")
		return {}
	if local_fact_flag != "":
		_phase_one.establish_evidence(local_fact_flag)
	_emit_trial_record_fact_established(evidence_id, "")
	var result: Dictionary = {
		"action": "rehearsal_present",
		"evidence_id": evidence_id,
		"local_fact_flag": local_fact_flag,
		"witness_cooperation": _phase_one.witness_cooperation,
	}
	_last_result = result
	return result


## get_active_round_data — exposes the chapter%d_round_%d.json dict loaded
## on the most recent start_round() call. Consumers (Trial Record panel,
## dialogue dispatchers, focused tests) read witness lists, judge counter-
## questions, frame_gates, and victory_resolution from this dict without
## re-reading the file. Returns {} if no round is active.
func get_active_round_data() -> Dictionary:
	return _active_round_data.duplicate(true)


func _load_round_file(chapter: int, round_index: int) -> Dictionary:
	if chapter <= 0 or round_index <= 0:
		push_error("BattleController._load_round_file: invalid chapter %d / round %d" % [chapter, round_index])
		return {}
	var path: String = ROUND_FILE_TEMPLATE % [chapter, round_index]
	if not FileAccess.file_exists(path):
		push_error("BattleController._load_round_file: missing round file %s" % path)
		return {}
	var parsed: Dictionary = _load_json_dictionary(path)
	if parsed.is_empty():
		push_error("BattleController._load_round_file: failed to parse %s" % path)
		return {}
	return parsed


## _compute_court_outcome — determines the dispositive court_outcome band
## from BOTH packet completeness (via packet_scorer) AND Phase 2 citation
## quality (via chapter1.phase2_round_results). Replaces the old premature
## court_outcome write in consume_assembled_packet().
##
## Current Ch1 outcome bands:
##   OUTCOME_STRONG / STANDARD = packet outcome preserved unless Phase 2 downgrades it
##   OUTCOME_NARROW = packet narrow ∨ any Phase 2 backfire/unavailable citation
##                    ∨ accumulated weak/no-effect citation history
##   OUTCOME_BLUNDER_RECOVERED = incapacity / burns-round path
func _compute_court_outcome(packet_result: Dictionary) -> String:
	var packet_outcome: String = str(packet_result.get("outcome", OUTCOME_BLUNDER_RECOVERED))

	## Blunder-recovered stays blunder-recovered — the packet itself is
	## fatally compromised (incapacity filed, round burned, ≤1 slot supported).
	if packet_outcome == OUTCOME_BLUNDER_RECOVERED:
		return OUTCOME_BLUNDER_RECOVERED

	## Read Phase 2 citation results accumulated by player_present().
	## Today's Chapter 1 closing records a single broad citation in Round 3, and
	## the live resolver is still tuned for wider multi-citation play. Until that
	## data lands, Phase 2 acts as a downgrade layer without making a single
	## sparse-but-available citation erase a complete packet.
	var ch1: Dictionary = _chapter1()
	var results: Array = []
	if ch1.get("phase2_round_results", []) is Array:
		results = ch1.get("phase2_round_results", [])

	var weak_phase2_count: int = 0
	for entry in results:
		if not entry is Dictionary:
			continue
		var bucket: String = str(entry.get("effectiveness_bucket", "no_effect"))
		if bucket == "backfires":
			return OUTCOME_NARROW
		if entry.has("evidence_available") and not bool(entry.get("evidence_available", true)):
			return OUTCOME_NARROW
		if bucket == "not_very_effective" or bucket == "no_effect":
			weak_phase2_count += 1

	if weak_phase2_count >= 2:
		return OUTCOME_NARROW
	return packet_outcome


func evaluate_packet_submission() -> Dictionary:
	if not _ensure_loaded():
		return {}
	return PACKET_SCORER.score(_chapter1(), _frames, _evidence)


func consume_assembled_packet() -> Dictionary:
	if _packet_submission_applied:
		return _packet_submission_result.duplicate(true)

	var score: Dictionary = evaluate_packet_submission()
	if score.is_empty():
		return {}

	_write_chapter1_flag("judicial_patience", int(score.get("starting_judicial_patience", PHASE_TWO_DEFAULT_PATIENCE)))
	if bool(score.get("has_incapacity_blunder", false)):
		_write_chapter1_flag("incapacity_penalty", true)

	var dominant_frame: String = str(score.get("dominant_frame", FRAME_DEFAULT))
	if dominant_frame == "":
		dominant_frame = FRAME_DEFAULT
	_write_chapter1_flag("proposed_frame", dominant_frame)

	if str(_chapter1().get("packet_requested_remedy", DEFAULT_REMEDY)) != DEFAULT_REMEDY:
		_write_chapter1_flag("decoy_overbroad_remedy", true)
	if bool(score.get("crab_support_withdrawn", false)):
		_emit_crab_withdrew_after_incapacity()
		## recruited_crab is NOT flipped here. The flag is written by on_dismiss
		## of crab_incapacity_withdrawal in crab.json, after the player has seen
		## Crab's withdrawal beat. See Step 5.2, 2026-05-26 design plan.

	## court_outcome is NOT written here. Packet completeness alone cannot
	## determine the outcome — Phase 2 citation quality matters. The
	## dispositive outcome is computed by _compute_court_outcome() at
	## end-of-round-3. See Step 1.1 of the 2026-05-26 design plan.
	_packet_submission_applied = true
	_packet_submission_result = score.duplicate(true)
	_emit_trial_record_packet_scored(_packet_submission_result)
	return _packet_submission_result.duplicate(true)


func _ensure_loaded() -> bool:
	if _loaded and _taxonomy_valid:
		return true
	return load_data()


func _load_judgments() -> bool:
	var parsed: Dictionary = _load_json_dictionary(JUDGMENTS_PATH)
	if parsed.is_empty():
		return false
	var raw_judgments: Array = []
	if parsed.get("judgments", []) is Array:
		raw_judgments = parsed.get("judgments", [])
	for raw_judgment in raw_judgments:
		if not raw_judgment is Dictionary:
			push_error("BattleController: judgment entry is not a Dictionary")
			return false
		var judgment = JUDGMENT_SCRIPT.load_from_dict(raw_judgment)
		if judgment.id != "":
			_judgments[judgment.id] = judgment
	return true


func _load_opponents() -> bool:
	var parsed: Dictionary = _load_json_dictionary(OPPONENTS_PATH)
	if parsed.is_empty():
		return false
	var raw_opponents: Array = []
	if parsed.get("opponents", []) is Array:
		raw_opponents = parsed.get("opponents", [])
	for raw_opponent in raw_opponents:
		if not raw_opponent is Dictionary:
			push_error("BattleController: opponent entry is not a Dictionary")
			return false
		var opponent = OPPONENT_SCRIPT.load_from_dict(raw_opponent)
		if opponent.id != "":
			_opponents[opponent.id] = opponent
	return true


func _load_named_block(path: String, block_name: String, target: Dictionary) -> bool:
	var parsed: Dictionary = _load_json_dictionary(path)
	if parsed.is_empty():
		return false
	if not parsed.get(block_name, {}) is Dictionary:
		push_error("BattleController: '%s' missing Dictionary block '%s'" % [path, block_name])
		return false
	for key in parsed[block_name]:
		if parsed[block_name][key] is Dictionary:
			target[str(key)] = parsed[block_name][key]
	return true


func _load_json_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("BattleController: JSON file not found: %s" % path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("BattleController: cannot open JSON file: %s" % path)
		return {}
	var text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null or not parsed is Dictionary:
		push_error("BattleController: JSON parse failed: %s" % path)
		return {}
	return parsed


func _validate_battle_tags() -> bool:
	for judgment in _judgments.values():
		if not judgment is Resource:
			continue
		for move in judgment.principle_moves:
			if not Effectiveness.validate_against_taxonomy(move.get_weighted_tags(), _taxonomy):
				return false

	for opponent in _opponents.values():
		if not opponent is Resource:
			continue
		for round in opponent.court_rounds:
			for move in round.moves:
				if not Effectiveness.validate_against_taxonomy(move.get_argument_tags(), _taxonomy):
					return false
				if not Effectiveness.validate_against_taxonomy(move.get_weakness_tags(), _taxonomy):
					return false
				if not Effectiveness.validate_against_taxonomy(move.get_strength_tags(), _taxonomy):
					return false

	for evidence_id in _evidence:
		if not Effectiveness.validate_against_taxonomy(_weighted_tags_for_evidence(str(evidence_id)), _taxonomy):
			return false
	return true


func _is_phase_one_round(round_index: int) -> bool:
	return round_index == 1 or round_index == 2


func _current_opponent_move() -> Resource:
	if _active_round == null:
		return null
	return _active_round.get_move_at(_current_move_index)


func _select_opponent_move(move_id: String) -> void:
	if _active_round == null:
		return
	for index in range(_active_round.moves.size()):
		if _active_round.moves[index].move_id == move_id:
			_current_move_index = index
			return


func _resolve_against_current(move_tags: Dictionary[String, float], opponent_move: Resource) -> Dictionary:
	if opponent_move == null:
		return {
			"bucket": "no_effect",
			"score": 0.0,
			"primary_match": "",
		}
	var resolved: Dictionary = Effectiveness.resolve(
		move_tags,
		opponent_move.get_weakness_tags(),
		opponent_move.get_strength_tags()
	)
	if not VALID_BUCKETS.has(str(resolved.get("bucket", ""))):
		resolved["bucket"] = "no_effect"
	return resolved


func _combine_move_and_evidence_tags(move_tags: Dictionary[String, float], evidence_id: String) -> Dictionary[String, float]:
	var evidence_tags: Dictionary[String, float] = _weighted_tags_for_evidence(evidence_id)
	if evidence_tags.is_empty():
		return move_tags
	if move_tags.is_empty():
		return evidence_tags

	var combined: Dictionary[String, float] = {}
	for tag_id in move_tags:
		combined[tag_id] = float(combined.get(tag_id, 0.0)) + (float(move_tags[tag_id]) * 0.75)
	for tag_id in evidence_tags:
		combined[tag_id] = float(combined.get(tag_id, 0.0)) + (float(evidence_tags[tag_id]) * 0.25)
	return _normalise_tags(combined)


func _weighted_tags_for_evidence(evidence_id: String) -> Dictionary[String, float]:
	var tags: Array[String] = []
	var entry: Dictionary = {}
	if _evidence.get(evidence_id, {}) is Dictionary:
		entry = _evidence.get(evidence_id, {})
	for raw_tag in entry.get("argument_tags", []):
		var tag_id: String = str(raw_tag)
		if not tags.has(tag_id):
			tags.append(tag_id)
	for raw_tag in entry.get("context_tags", []):
		var tag_id: String = str(raw_tag)
		if not tags.has(tag_id):
			tags.append(tag_id)
	if tags.is_empty():
		return {}
	var weighted: Dictionary[String, float] = {}
	var weight: float = 1.0 / float(tags.size())
	for tag_id in tags:
		weighted[tag_id] = weight
	return weighted


func _normalise_tags(tags: Dictionary[String, float]) -> Dictionary[String, float]:
	var total: float = 0.0
	for tag_id in tags:
		total += float(tags[tag_id])
	if total <= 0.0:
		return {}
	var out: Dictionary[String, float] = {}
	for tag_id in tags:
		out[tag_id] = float(tags[tag_id]) / total
	return out


func _establish_evidence(evidence_id: String) -> void:
	if evidence_id == "" or not _evidence.has(evidence_id):
		return
	_phase_one.establish_evidence(evidence_id)
	var entry: Dictionary = _evidence[evidence_id]
	var flag_path: String = str(entry.get("sets_flag", ""))
	if not flag_path.begins_with("chapter1."):
		return
	var key: String = flag_path.substr(9)
	if key == "client_meeting_evidence":
		_write_chapter1_flag(key, evidence_id)
	else:
		_write_chapter1_flag(key, true)
	_emit_trial_record_fact_established(evidence_id, key)


func _append_phase2_result(
	round_index: int,
	citation_id: String,
	effectiveness_bucket: String,
	opponent_move: String,
	evidence_id: String,
	evidence_available: bool
) -> void:
	var state_node: Node = get_node_or_null("/root/State")
	if state_node == null:
		return
	var data: Dictionary = state_node.get("data")
	if not data.has("chapter1") or not data["chapter1"] is Dictionary:
		return
	var ch1: Dictionary = data["chapter1"]
	if not ch1.has("phase2_round_results") or not ch1["phase2_round_results"] is Array:
		return
	var results: Array = ch1["phase2_round_results"]
	results.append({
		"round": round_index,
		"citation_id": citation_id,
		"evidence_id": evidence_id,
		"evidence_available": evidence_available,
		"effectiveness_bucket": effectiveness_bucket,
		"opponent_move": opponent_move,
	})
	_emit_trial_record_citation_resolved(citation_id, effectiveness_bucket, opponent_move)


func _packet_evidence_for_slot(slot_key: String, chapter1: Dictionary) -> String:
	var state_key: String = str(PACKET_SLOT_STATE_KEYS.get(slot_key, ""))
	if state_key == "":
		return ""
	return str(chapter1.get(state_key, ""))


func _base_result(resolved: Dictionary) -> Dictionary:
	return {
		"bucket": str(resolved.get("bucket", "no_effect")),
		"score": float(resolved.get("score", 0.0)),
		"primary_match": str(resolved.get("primary_match", "")),
		"casebook_judge_state": str(_chapter1().get("casebook_judge_state", "")),
	}


func _chapter1() -> Dictionary:
	var state_node: Node = get_node_or_null("/root/State")
	if state_node == null:
		return {}
	if not state_node.get("data") is Dictionary:
		return {}
	var data: Dictionary = state_node.get("data")
	if not data.get("chapter1", {}) is Dictionary:
		return {}
	return data["chapter1"]


func _write_chapter1_flag(flag_name: String, value: Variant) -> void:
	var state_node: Node = get_node_or_null("/root/State")
	if state_node == null:
		push_error("BattleController: State autoload missing; cannot write chapter1.%s" % flag_name)
		return
	var data: Dictionary = state_node.get("data")
	if not data.has("chapter1") or not data["chapter1"] is Dictionary:
		push_error("BattleController: State.data.chapter1 missing")
		return
	if not data["chapter1"].has(flag_name):
		push_error("BattleController: chapter1.%s is not declared in State.reset_state()" % flag_name)
		return
	data["chapter1"][flag_name] = value

	var sigs: Node = get_node_or_null("/root/Signals")
	if sigs != null and sigs.has_signal("chapter1_flag_changed"):
		sigs.chapter1_flag_changed.emit(flag_name, value)


func _emit_judge_skepticism(round_index: int, proposed_frame: String) -> void:
	var sigs: Node = get_node_or_null("/root/Signals")
	if sigs != null and sigs.has_signal("judge_skepticism_raised"):
		sigs.judge_skepticism_raised.emit(round_index, proposed_frame)


## Trial Record panel signal helpers — all guard against missing autoload so they
## compile safely in headless --script mode where /root/Signals may not be registered.

func _emit_trial_record_round_started(round_index: int) -> void:
	var sigs: Node = get_node_or_null("/root/Signals")
	if sigs != null and sigs.has_signal("trial_record_round_started"):
		sigs.trial_record_round_started.emit(round_index)


func _emit_trial_record_fact_established(evidence_id: String, flag_name: String) -> void:
	var sigs: Node = get_node_or_null("/root/Signals")
	if sigs != null and sigs.has_signal("trial_record_fact_established"):
		sigs.trial_record_fact_established.emit(evidence_id, flag_name)


func _emit_trial_record_citation_resolved(citation_id: String, bucket: String, opponent_move: String) -> void:
	var sigs: Node = get_node_or_null("/root/Signals")
	if sigs != null and sigs.has_signal("trial_record_citation_resolved"):
		sigs.trial_record_citation_resolved.emit(citation_id, bucket, opponent_move)


func _emit_trial_record_opponent_stated(move_display_name: String) -> void:
	var sigs: Node = get_node_or_null("/root/Signals")
	if sigs != null and sigs.has_signal("trial_record_opponent_stated"):
		sigs.trial_record_opponent_stated.emit(move_display_name)


func _emit_trial_record_packet_scored(packet_result: Dictionary) -> void:
	var sigs: Node = get_node_or_null("/root/Signals")
	if sigs != null and sigs.has_signal("trial_record_packet_scored"):
		sigs.trial_record_packet_scored.emit(packet_result)


func _emit_crab_withdrew_after_incapacity() -> void:
	var sigs: Node = get_node_or_null("/root/Signals")
	if sigs != null and sigs.has_signal("crab_withdrew_after_incapacity"):
		sigs.crab_withdrew_after_incapacity.emit()


func _is_merits_frame(frame_id: String) -> bool:
	## Legacy compatibility: earlier dialogue drafts and tests used
	## 'merits_defence'. Runtime v3 frame id is 'substantive_defense'.
	return frame_id == "merits_defence" or frame_id == "substantive_defense"
