class_name PacketScorer
extends RefCounted
## Shared Chapter 1 motion-packet scorer.
##
## BattleController consumes this result for court state. BlueBinder consumes the
## same result for the pre-court packet UI so the preview and court consequence
## cannot drift.

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

const DECOY_FLAG_TO_FRAME: Dictionary = {
	"decoy_merits": "substantive_defense",
	"decoy_notice_period": "notice_period_failure",
	"decoy_standing_wrong_party": "standing_wrong_party",
	"decoy_overbroad_remedy": "overbroad_remedy",
	"decoy_incapacity": "incapacity_defense",
}
const DECOY_FRAME_PRIORITY: Array[String] = [
	"incapacity_defense",
	"standing_wrong_party",
	"notice_period_failure",
	"substantive_defense",
	"overbroad_remedy",
]

const PHASE_TWO_DEFAULT_PATIENCE: int = 5


static func score(chapter1: Dictionary, frames: Dictionary, evidence: Dictionary) -> Dictionary:
	var supported_slots: Dictionary = {}
	var selected_evidence: Dictionary = {}
	var supported_count: int = 0

	for slot_key in PACKET_SLOT_ORDER:
		var evidence_id: String = _packet_evidence_for_slot(slot_key, chapter1)
		var supported: bool = _packet_slot_supported(slot_key, evidence_id, chapter1, evidence)
		supported_slots[slot_key] = supported
		selected_evidence[slot_key] = evidence_id
		if supported:
			supported_count += 1

	var has_address_defect: bool = bool(supported_slots.get(PACKET_SLOT_ADDRESS, false))
	var supporting_detail_count: int = 0
	for slot_key in [PACKET_SLOT_KNOWLEDGE, PACKET_SLOT_WINDOW, PACKET_SLOT_AUTHORITY]:
		if bool(supported_slots.get(slot_key, false)):
			supporting_detail_count += 1

	var selected_blunders: Array[String] = _selected_blunder_frames(chapter1)
	var dominant_frame: String = _dominant_frame(selected_blunders)
	var blunder_count: int = selected_blunders.size()
	var has_incapacity: bool = selected_blunders.has("incapacity_defense")
	var burns_round_attempt: bool = false
	var patience_delta: int = 0
	var trust_delta: int = 0
	for frame_id in selected_blunders:
		var frame: Dictionary = {}
		if frames.get(frame_id, {}) is Dictionary:
			frame = frames.get(frame_id, {})
		patience_delta += int(frame.get("judicial_patience_delta_on_select", 0))
		trust_delta += int(frame.get("halina_trust_delta_on_select", 0))
		burns_round_attempt = burns_round_attempt or bool(frame.get("burns_round_attempt", false))

	var support_patience_delta: int = 0
	if selected_blunders.is_empty():
		if supported_count <= 1:
			support_patience_delta = -2
		elif not has_address_defect:
			support_patience_delta = -1
	patience_delta += support_patience_delta

	var outcome: String = _packet_outcome(
		supported_count,
		has_address_defect,
		supporting_detail_count,
		blunder_count,
		has_incapacity,
		burns_round_attempt
	)
	var starting_patience: int = max(0, PHASE_TWO_DEFAULT_PATIENCE + patience_delta)
	var recovery_source: String = _packet_recovery_source(chapter1, outcome, has_incapacity)
	var crab_withdrawn: bool = has_incapacity and bool(chapter1.get("recruited_crab", false))
	var minimum_required: int = _minimum_required_elements(frames)
	var remedy_id: String = str(chapter1.get("packet_requested_remedy", DEFAULT_REMEDY))
	if remedy_id == "":
		remedy_id = DEFAULT_REMEDY

	return {
		"outcome": outcome,
		"supported_count": supported_count,
		"supported_total": PACKET_SLOT_ORDER.size(),
		"required_count": supported_count,
		"required_total": PACKET_SLOT_ORDER.size(),
		"minimum_required": minimum_required,
		"meets_minimum": supported_count >= minimum_required,
		"requested_remedy": remedy_id,
		"has_address_defect": has_address_defect,
		"supporting_detail_count": supporting_detail_count,
		"supported_slots": supported_slots,
		"selected_evidence": selected_evidence,
		"selected_blunders": selected_blunders,
		"selected_frames": selected_blunders.duplicate(),
		"blunder_count": blunder_count,
		"dominant_frame": dominant_frame,
		"proposed_frame": dominant_frame,
		"reaction_template": _packet_reaction_template(selected_blunders),
		"judicial_patience_delta": patience_delta,
		"packet_support_patience_delta": support_patience_delta,
		"halina_trust_delta": trust_delta,
		"starting_judicial_patience": starting_patience,
		"burns_round_attempt": burns_round_attempt,
		"has_incapacity_blunder": has_incapacity,
		"crab_support_withdrawn": crab_withdrawn,
		"recovery_source": recovery_source,
	}


static func _packet_evidence_for_slot(slot_key: String, chapter1: Dictionary) -> String:
	var state_key: String = str(PACKET_SLOT_STATE_KEYS.get(slot_key, ""))
	if state_key == "":
		return ""
	return str(chapter1.get(state_key, ""))


static func _packet_slot_supported(
	slot_key: String,
	evidence_id: String,
	chapter1: Dictionary,
	evidence: Dictionary
) -> bool:
	if evidence_id != "":
		return _evidence_supports_packet_slot(evidence_id, slot_key, evidence) \
			and _is_evidence_surfaced_for_packet(evidence_id, chapter1, evidence)
	if not bool(chapter1.get(slot_key, false)):
		return false
	for candidate_id in evidence.keys():
		var candidate: String = str(candidate_id)
		if _evidence_supports_packet_slot(candidate, slot_key, evidence) \
				and _is_evidence_surfaced_for_packet(candidate, chapter1, evidence):
			return true
	return false


static func _evidence_supports_packet_slot(evidence_id: String, slot_key: String, evidence: Dictionary) -> bool:
	var entry: Dictionary = {}
	if evidence.get(evidence_id, {}) is Dictionary:
		entry = evidence.get(evidence_id, {})
	var support: Variant = entry.get("supports_packet_slots", [])
	if not support is Array:
		return false
	for raw_slot in support:
		if str(raw_slot) == slot_key:
			return true
	return false


static func _is_evidence_surfaced_for_packet(evidence_id: String, chapter1: Dictionary, evidence: Dictionary) -> bool:
	var entry: Dictionary = {}
	if evidence.get(evidence_id, {}) is Dictionary:
		entry = evidence.get(evidence_id, {})
	var flag_path: String = str(entry.get("sets_flag", ""))
	if flag_path == "" or not flag_path.begins_with("chapter1."):
		return true
	var key: String = flag_path.substr(9)
	if not chapter1.has(key):
		return false
	var value: Variant = chapter1[key]
	if value is bool:
		return bool(value)
	if value is String:
		return str(value) == evidence_id
	return false


static func _selected_blunder_frames(chapter1: Dictionary) -> Array[String]:
	var selected: Array[String] = []
	for flag_name in DECOY_FLAG_TO_FRAME.keys():
		if bool(chapter1.get(str(flag_name), false)):
			_append_unique_frame(selected, str(DECOY_FLAG_TO_FRAME[flag_name]))
	if str(chapter1.get("packet_requested_remedy", DEFAULT_REMEDY)) != DEFAULT_REMEDY:
		_append_unique_frame(selected, "overbroad_remedy")

	var proposed_frame: String = _normalise_frame_id(str(chapter1.get("proposed_frame", "")))
	if proposed_frame != "" and proposed_frame != FRAME_DEFAULT:
		_append_unique_frame(selected, proposed_frame)

	var ordered: Array[String] = []
	for frame_id in DECOY_FRAME_PRIORITY:
		if selected.has(frame_id):
			ordered.append(frame_id)
	for frame_id in selected:
		if not ordered.has(frame_id):
			ordered.append(frame_id)
	return ordered


static func _append_unique_frame(frames: Array[String], frame_id: String) -> void:
	var normalised: String = _normalise_frame_id(frame_id)
	if normalised != "" and not frames.has(normalised):
		frames.append(normalised)


static func _normalise_frame_id(frame_id: String) -> String:
	if frame_id == "merits_defence":
		return "substantive_defense"
	return frame_id


static func _dominant_frame(selected_blunders: Array[String]) -> String:
	if selected_blunders.is_empty():
		return FRAME_DEFAULT
	for frame_id in DECOY_FRAME_PRIORITY:
		if selected_blunders.has(frame_id):
			return frame_id
	return selected_blunders[0]


static func _packet_outcome(
	supported_count: int,
	has_address_defect: bool,
	supporting_detail_count: int,
	blunder_count: int,
	has_incapacity: bool,
	burns_round_attempt: bool
) -> String:
	if has_incapacity or burns_round_attempt or supported_count <= 1:
		return OUTCOME_BLUNDER_RECOVERED
	if blunder_count > 0:
		return OUTCOME_NARROW
	if supported_count == PACKET_SLOT_ORDER.size():
		return OUTCOME_STRONG
	if has_address_defect and supporting_detail_count >= 1:
		return OUTCOME_STANDARD
	if supported_count >= 2:
		return OUTCOME_NARROW
	return OUTCOME_BLUNDER_RECOVERED


static func _packet_reaction_template(selected_blunders: Array[String]) -> String:
	if selected_blunders.has("incapacity_defense"):
		return "icy_silence"
	if selected_blunders.has("standing_wrong_party") or selected_blunders.has("overbroad_remedy"):
		return "sharper_really_your_theory"
	if selected_blunders.has("notice_period_failure"):
		return "cool_dismissal"
	if selected_blunders.has("substantive_defense"):
		return "tolerant_try_again"
	return "approving_set_aside"


static func _packet_recovery_source(chapter1: Dictionary, outcome: String, has_incapacity: bool) -> String:
	if outcome != OUTCOME_BLUNDER_RECOVERED and outcome != OUTCOME_NARROW:
		return ""
	if has_incapacity:
		if bool(chapter1.get("recruited_crab", false)):
			return "crab_withdrawal"
		return "crab_refusal"
	if bool(chapter1.get("recruited_crab", false)):
		return "crab_rescue"
	if bool(chapter1.get("recruited_whimsy", false)):
		return "whimsy_rescue"
	return "court_redirect"


static func _minimum_required_elements(frames: Dictionary) -> int:
	var frame: Dictionary = {}
	if frames.get(FRAME_DEFAULT, {}) is Dictionary:
		frame = frames.get(FRAME_DEFAULT, {})
	if frame.is_empty():
		return 3
	var requirements: Dictionary = {}
	if frame.get("packet_requirements", {}) is Dictionary:
		requirements = frame.get("packet_requirements", {})
	if requirements.is_empty():
		return 3
	return int(requirements.get("minimum_required_elements", 3))
