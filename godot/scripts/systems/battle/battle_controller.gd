## scripts/systems/battle/battle_controller.gd
##
## Casebook Battle System — Court Round two-phase controller.
##
## Implements PROPOSALS.md §10: Phase 1 (witness fact-finding, witness_cooperation
## budget, fact-flags) feeds into Phase 2 (closing argument, judicial_patience,
## principle citations gated by Phase 1 fact-flags).
##
## Usage:
##   var ctrl := BattleController.new()
##   ctrl.load_round("res://data/court_rounds/ch01_round1.json")
##   ctrl.start()
##   # respond to Signals.battle_phase_changed, Signals.battle_ended, etc.
##
## Owner: Code role (AGENTS.md §File ownership).
## Wire-up: battle_screen.tscn connects to this via Signals; this does NOT
## touch UI nodes directly.

class_name BattleController
extends Node


## Phase enum — internal state machine.
enum Phase {
    IDLE           = 0,
    PHASE1_WITNESS = 1,
    PHASE2_CLOSING = 2,
    RESULT         = 3,
}


## Round data loaded from JSON.
var _round_data: Dictionary = {}

## Runtime BattleState — lives only for the duration of one court encounter.
var _state: Dictionary = {}


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## load_round — parse a court_round JSON file into _round_data.
## Returns true on success; false and pushes an error on failure.
func load_round(path: String) -> bool:
    if not FileAccess.file_exists(path):
        push_error("BattleController: court round file not found: " + path)
        return false
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("BattleController: cannot open: " + path)
        return false
    var text: String = file.get_as_text()
    file.close()
    var parsed = JSON.parse_string(text)
    if parsed == null or not parsed is Dictionary:
        push_error("BattleController: JSON parse failed: " + path)
        return false
    _round_data = parsed
    return true


## start — initialise BattleState and enter Phase 1.
## Call after load_round(). Emits Signals.battle_phase_changed.
func start() -> void:
    if _round_data.is_empty():
        push_error("BattleController.start: no round data loaded.")
        return
    _reset_state()
    _enter_phase(Phase.PHASE1_WITNESS)


## submit_witness_option — spend cooperation on a Phase 1 witness option.
##
## @param witness_index  int — index into phase1.witnesses
## @param option_id      String — id field of the chosen option
## Returns a result Dictionary:
##   { success: bool, response: String, flag_set: String, cooperation_remaining: int }
func submit_witness_option(witness_index: int, option_id: String) -> Dictionary:
    if _state.current_phase != Phase.PHASE1_WITNESS:
        push_error("BattleController.submit_witness_option: not in Phase 1")
        return { "success": false, "response": "", "flag_set": "", "cooperation_remaining": 0 }

    var witnesses: Array = _round_data.get("phase1", {}).get("witnesses", [])
    if witness_index < 0 or witness_index >= witnesses.size():
        push_error("BattleController.submit_witness_option: invalid witness_index %d" % witness_index)
        return { "success": false, "response": "", "flag_set": "", "cooperation_remaining": 0 }

    var witness: Dictionary = witnesses[witness_index]
    var option: Dictionary = {}
    for opt in witness.get("options", []):
        if opt.get("id", "") == option_id:
            option = opt
            break

    if option.is_empty():
        push_error("BattleController.submit_witness_option: option_id '%s' not found" % option_id)
        return { "success": false, "response": "", "flag_set": "", "cooperation_remaining": 0 }

    ## Check requires_item if present.
    var required_item: String = option.get("requires_item", "")
    if required_item != "" and not _player_has_item(required_item):
        return {
            "success": false,
            "response": "The item '%s' is not in Cula's inventory." % required_item,
            "flag_set": "",
            "cooperation_remaining": _state.witness_cooperation_remaining,
        }

    ## Deduct cost.
    var cost: int = int(option.get("cost", 1))
    _state.witness_cooperation_remaining -= cost
    _state.witness_cooperation_remaining = max(0, _state.witness_cooperation_remaining)

    ## Set fact-flag.
    var flag: String = option.get("sets_fact_flag", "")
    if flag != "" and _round_data.get("phase1", {}).get("fact_flags", []).has(flag):
        _state.active_fact_flags[flag] = true
    elif flag != "":
        push_error("BattleController: fact_flag '%s' not in phase1.fact_flags" % flag)

    var response: String = option.get("response", "")
    var result := {
        "success": true,
        "response": response,
        "flag_set": flag,
        "cooperation_remaining": _state.witness_cooperation_remaining,
    }

    ## Advance to next witness or end Phase 1 if cooperation exhausted.
    if _state.witness_cooperation_remaining <= 0:
        _advance_from_phase1()
    elif _all_witness_options_exhausted(witness_index):
        _state.current_witness_index += 1
        if _state.current_witness_index >= witnesses.size():
            _advance_from_phase1()

    return result


## submit_citation — invoke a principle citation in Phase 2 against the
## current counter-question.
##
## @param citation_id  String — id field of the chosen citation
## Returns a result Dictionary:
##   { success: bool, bucket: String, result_text: String,
##     judicial_patience_remaining: int, cq_defeated: bool, encounter_over: bool }
func submit_citation(citation_id: String) -> Dictionary:
    if _state.current_phase != Phase.PHASE2_CLOSING:
        push_error("BattleController.submit_citation: not in Phase 2")
        return _empty_citation_result()

    var cqs: Array = _round_data.get("phase2", {}).get("counter_questions", [])
    if _state.current_cq_index >= cqs.size():
        push_error("BattleController.submit_citation: current_cq_index out of range")
        return _empty_citation_result()

    var cq: Dictionary = cqs[_state.current_cq_index]
    var citation: Dictionary = {}
    for cit in cq.get("citations", []):
        if cit.get("id", "") == citation_id:
            citation = cit
            break

    if citation.is_empty():
        push_error("BattleController.submit_citation: citation_id '%s' not found" % citation_id)
        return _empty_citation_result()

    ## Check Phase 1 fact-flag gate.
    for req in citation.get("requires_fact_flags", []):
        if not _state.active_fact_flags.get(req, false):
            return {
                "success": false,
                "bucket": "no_effect",
                "result_text": "That citation requires a fact not yet established in evidence.",
                "judicial_patience_remaining": _state.judicial_patience_remaining,
                "cq_defeated": false,
                "encounter_over": false,
            }

    ## Apply effectiveness.
    var bucket: String = citation.get("effectiveness", "no_effect")
    var force: float = Effectiveness.bucket_to_force_multiplier(bucket)
    var cq_id: String = cq.get("id", "")
    var current_strength: int = _state.cq_argument_strengths.get(cq_id, 0)
    var new_strength: int = max(0, current_strength - int(ceil(force)))
    _state.cq_argument_strengths[cq_id] = new_strength

    ## Apply judicial_patience delta.
    var jp_delta: int = int(citation.get("judicial_patience_delta",
        _default_jp_delta_for_bucket(bucket)))
    _state.judicial_patience_remaining = max(0,
        _state.judicial_patience_remaining + jp_delta)

    var result_text: String = citation.get("result_text", "")
    var cq_defeated: bool = new_strength <= 0

    if cq_defeated:
        _state.cqs_defeated += 1
        _state.current_cq_index += 1

    var encounter_over: bool = false
    if _state.judicial_patience_remaining <= 0 or \
       _state.current_cq_index >= cqs.size():
        _conclude_phase2()
        encounter_over = true

    return {
        "success": true,
        "bucket": bucket,
        "result_text": result_text,
        "judicial_patience_remaining": _state.judicial_patience_remaining,
        "cq_defeated": cq_defeated,
        "encounter_over": encounter_over,
    }


## get_available_citations — returns citations for the current counter-question
## that are unlocked by the current fact-flag set. Useful for building the UI menu.
func get_available_citations() -> Array:
    if _state.current_phase != Phase.PHASE2_CLOSING:
        return []
    var cqs: Array = _round_data.get("phase2", {}).get("counter_questions", [])
    if _state.current_cq_index >= cqs.size():
        return []
    var cq: Dictionary = cqs[_state.current_cq_index]
    var available: Array = []
    for cit in cq.get("citations", []):
        var unlocked: bool = true
        for req in cit.get("requires_fact_flags", []):
            if not _state.active_fact_flags.get(req, false):
                unlocked = false
                break
        if unlocked:
            available.append(cit)
    return available


## get_battle_state_snapshot — returns a copy of the current BattleState for UI.
func get_battle_state_snapshot() -> Dictionary:
    return _state.duplicate(true)


# ---------------------------------------------------------------------------
# Private helpers
# ---------------------------------------------------------------------------

func _reset_state() -> void:
    var phase1: Dictionary = _round_data.get("phase1", {})
    var phase2: Dictionary = _round_data.get("phase2", {})

    ## Initialise fact-flags to false.
    var fact_flags: Dictionary = {}
    for f in phase1.get("fact_flags", []):
        fact_flags[f] = false

    ## Initialise cq argument strengths.
    var cq_strengths: Dictionary = {}
    for cq in phase2.get("counter_questions", []):
        cq_strengths[cq.get("id", "")] = int(cq.get("argument_strength", 1))

    _state = {
        "current_phase":                  Phase.IDLE,
        "witness_cooperation_remaining":  int(phase1.get("witness_cooperation_max", 6)),
        "active_fact_flags":              fact_flags,
        "judicial_patience_remaining":    int(phase2.get("judicial_patience_max", 10)),
        "current_witness_index":          0,
        "current_cq_index":               0,
        "cqs_defeated":                   0,
        "cq_argument_strengths":          cq_strengths,
        "outcome":                        "",
    }


func _enter_phase(phase: Phase) -> void:
    _state.current_phase = phase
    ## TODO: emit Signals.battle_phase_changed when Signals autoload is extended.
    ## Signals.battle_phase_changed.emit(phase, _round_data)


func _advance_from_phase1() -> void:
    _enter_phase(Phase.PHASE2_CLOSING)


func _conclude_phase2() -> void:
    _enter_phase(Phase.RESULT)
    var outcome: String = _determine_outcome()
    _state.outcome = outcome
    _apply_outcome_side_effects(outcome)
    ## TODO: emit Signals.battle_ended when Signals autoload is extended.
    ## Signals.battle_ended.emit(outcome, _state.duplicate(true))


func _determine_outcome() -> String:
    var thresholds: Dictionary = _round_data.get("phase2", {}) \
        .get("victory_threshold", {})
    var strong_win_threshold: int = int(thresholds.get("strong_win", 2))
    var weak_win_threshold: int = int(thresholds.get("weak_win", 1))
    if _state.judicial_patience_remaining <= 0:
        return "loss"
    if _state.cqs_defeated >= strong_win_threshold:
        return "strong_win"
    if _state.cqs_defeated >= weak_win_threshold:
        return "weak_win"
    return "loss"


func _apply_outcome_side_effects(outcome: String) -> void:
    var outcomes: Dictionary = _round_data.get("phase2", {}).get("outcomes", {})
    var branch: Dictionary = outcomes.get(outcome, {})
    var actions: Array = []
    if outcome == "loss":
        actions = branch.get("on_defeat", [])
    else:
        actions = branch.get("on_victory", [])

    ## Apply set-actions to State.data (same shape as dialogue on_dismiss).
    var st: Node = get_node_or_null("/root/State")
    if st == null:
        push_error("BattleController._apply_outcome_side_effects: State autoload missing.")
        return
    for action in actions:
        if action.has("set") and action.has("value"):
            _set_state_value(st, action["set"], action["value"])


## _set_state_value — writes a dotted-path key into State.data.
## Mirrors dialogue_runner.gd's _set_state_value; keep in sync.
func _set_state_value(st: Node, path: String, value) -> void:
    var parts: Array = path.split(".")
    if parts.size() == 1:
        if st.data.has(parts[0]):
            st.data[parts[0]] = value
        else:
            push_error("BattleController._set_state_value: top-level key '%s' missing" % parts[0])
    elif parts.size() == 2:
        var top: String = parts[0]
        var key: String = parts[1]
        if st.data.has(top) and st.data[top] is Dictionary and st.data[top].has(key):
            st.data[top][key] = value
        else:
            push_error("BattleController._set_state_value: path '%s' missing" % path)
    else:
        push_error("BattleController._set_state_value: path depth > 2 not supported: " + path)


func _player_has_item(item_id: String) -> bool:
    ## TODO: wire to Inventory system once it exists.
    ## For v1, court round JSON authors should avoid requires_item on critical
    ## citations; evidence is proved through Phase 1 witness options instead.
    push_warning("BattleController._player_has_item: Inventory not yet wired; item '%s' assumed present." % item_id)
    return true


func _all_witness_options_exhausted(witness_index: int) -> bool:
    ## TODO: track per-witness used option ids to detect full exhaustion.
    ## For now, the controller advances on cooperation-exhaustion only.
    return false


func _default_jp_delta_for_bucket(bucket: String) -> int:
    match bucket:
        "super_effective":    return 0
        "effective":          return 0
        "not_very_effective": return -1
        "no_effect":          return -1
        "backfires":          return -2
        _: return 0


func _empty_citation_result() -> Dictionary:
    return {
        "success": false,
        "bucket": "no_effect",
        "result_text": "",
        "judicial_patience_remaining": _state.get("judicial_patience_remaining", 0),
        "cq_defeated": false,
        "encounter_over": false,
    }
