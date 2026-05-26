extends SceneTree
## test_battle.gd — effectiveness resolver bucket coverage.
##
## Verifies that all five narrative buckets are reachable by crossing
## synthetic player-move tag sets against the real landlord_counsel_ch1
## opponent data from data/argument_opponents.json.
##
## Step 1.3 (2026-05-26): populated immune_to arrays, proving backfire
##   reachable.
## Step 2.3 (2026-05-26): recalibrated thresholds (STRENGTH_BACKFIRE_THRESHOLD
##   0.5→0.05; super_effective 0.70→0.07; effective 0.40→0.04;
##   not_very_effective 0.15→0.015) and wired merits_override/landlord_prejudice
##   weak_to arrays to cover all five buckets with real judgment tag weights.
##
## Two test cases:
##   T1  bucket_distribution — crosses five probes across three moves to
##       confirm all five buckets (super_effective, effective,
##       not_very_effective, no_effect, backfires) are reachable.
##   T2  immune_to_populated — every move in landlord_counsel_ch1 has at
##       least one immune_to tag, which is the pre-condition for backfire.

const OPPONENTS_PATH: String = "res://data/argument_opponents.json"

var _pass_count: int = 0
var _fail_count: int = 0

var _eff_script: GDScript = null
var _opp_script: GDScript = null


func _init() -> void:
	print("[TestBattle] Starting...")
	await process_frame

	_eff_script = load("res://scripts/systems/battle/effectiveness.gd") as GDScript
	if _eff_script == null:
		_fail("effectiveness.gd loads")
		_finish()
		return

	_opp_script = load("res://scripts/systems/battle/argument_opponent.gd") as GDScript
	if _opp_script == null:
		_fail("argument_opponent.gd loads")
		_finish()
		return

	if not FileAccess.file_exists(OPPONENTS_PATH):
		_fail("data/argument_opponents.json exists")
		_finish()
		return

	var file := FileAccess.open(OPPONENTS_PATH, FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed == null or not parsed is Dictionary:
		_fail("argument_opponents.json parses as Dictionary")
		_finish()
		return

	var opponent = null
	var opponents_arr: Array = parsed.get("opponents", [])
	for entry in opponents_arr:
		if entry is Dictionary and entry.get("id", "") == "landlord_counsel_ch1":
			opponent = _opp_script.load_from_dict(entry)
			break
	if opponent == null:
		_fail("landlord_counsel_ch1 found in data")
		_finish()
		return

	_test_bucket_distribution(opponent)
	_test_immune_to_populated(opponent)

	_finish()


## Crosses five synthetic player-move probes across three opponent moves and
## asserts that all five effectiveness buckets are reachable.
## Calibrated for Step 2.3 thresholds (super_eff=0.07, eff=0.04, nve=0.015,
## STRENGTH_BACKFIRE_THRESHOLD=0.05).
func _test_bucket_distribution(opponent: Object) -> void:
	print("[T1] bucket_distribution")

	## --- landlord_prejudice (Round 3) ---
	## weak_to (Step 2.3): [effective_remedy, prescribed_by_law, legal_certainty] → each 1/3
	## resists:   [proportionality, legitimate_aim]
	## immune_to: [margin_of_appreciation]
	## strength:  {proportionality:1/3, legitimate_aim:1/3, margin_of_appreciation:1/3}

	var round3: Object = opponent.get_round(3)
	_assert(round3 != null, "round 3 exists")
	if round3 == null:
		return

	var prejudice_move: Object = round3.get_move("landlord_prejudice")
	_assert(prejudice_move != null, "landlord_prejudice move found in round 3")
	if prejudice_move == null:
		return

	var weakness3: Dictionary = prejudice_move.get_weakness_tags()
	var strength3: Dictionary = prejudice_move.get_strength_tags()

	## Probe A — super_effective
	## effective_remedy weight 1.0; score = 1.0 × 1/3 ≈ 0.333 >= 0.07 → super_effective.
	## effective_remedy not in strength set → no backfire.
	var probe_super: Dictionary = {"effective_remedy": 1.0}
	var result_a: Dictionary = _eff_script.resolve(probe_super, weakness3, strength3)
	_assert(result_a.get("bucket", "") == "super_effective",
		"effective_remedy probe (score ~0.333) is super_effective against landlord_prejudice")

	## --- merits_override (Round 2) ---
	## weak_to (Step 2.3): [access_to_court, procedural_fairness, effective_remedy,
	##                       prescribed_by_law] → each 0.25
	## resists:   [legal_certainty, legitimate_aim]
	## immune_to: [margin_of_appreciation]

	var round2: Object = opponent.get_round(2)
	_assert(round2 != null, "round 2 exists")
	if round2 == null:
		return

	var merits_move: Object = round2.get_move("merits_override")
	_assert(merits_move != null, "merits_override move found in round 2")
	if merits_move == null:
		return

	var weakness2: Dictionary = merits_move.get_weakness_tags()
	var strength2: Dictionary = merits_move.get_strength_tags()

	## Probe B — effective
	## service_of_process (0.8) not in weak_to → 0; access_to_court (0.2) in weak_to
	## at 0.25 → score = 0.2 × 0.25 = 0.05; 0.04 <= 0.05 < 0.07 → effective.
	## Neither player tag is in merits_override's strength set → no backfire.
	var probe_eff: Dictionary = {"service_of_process": 0.8, "access_to_court": 0.2}
	var result_b: Dictionary = _eff_script.resolve(probe_eff, weakness2, strength2)
	_assert(result_b.get("bucket", "") == "effective",
		"partial access_to_court probe (score 0.05) is effective against merits_override")

	## --- file_says_served (Round 1) ---
	## weak_to:   [service_of_process, access_to_court, procedural_fairness] → each 1/3
	## resists:   [proportionality, legitimate_aim]
	## immune_to: [margin_of_appreciation]

	var round1: Object = opponent.get_round(1)
	_assert(round1 != null, "round 1 exists")
	if round1 == null:
		return

	var file_move: Object = round1.get_move("file_says_served")
	_assert(file_move != null, "file_says_served move found in round 1")
	if file_move == null:
		return

	var weakness1: Dictionary = file_move.get_weakness_tags()
	var strength1: Dictionary = file_move.get_strength_tags()

	## Probe C — not_very_effective
	## echr_8 (0.9) not in weak_to; access_to_court (0.1) in weak_to at 1/3
	## → score = 0.1 × 0.333 ≈ 0.033; 0.015 <= 0.033 < 0.04 → not_very_effective.
	## Neither player tag is in file_says_served's strength set → no backfire.
	var probe_nve: Dictionary = {"echr_8": 0.9, "access_to_court": 0.1}
	var result_c: Dictionary = _eff_script.resolve(probe_nve, weakness1, strength1)
	_assert(result_c.get("bucket", "") == "not_very_effective",
		"echr_8-heavy probe (score ~0.033) is not_very_effective against file_says_served")

	## Probe D — no_effect
	## echr_10 is not in weak_to or strength of file_says_served → score = 0.0.
	var probe_no: Dictionary = {"echr_10": 1.0}
	var result_d: Dictionary = _eff_script.resolve(probe_no, weakness1, strength1)
	_assert(result_d.get("bucket", "") == "no_effect",
		"echr_10 probe scores no_effect against file_says_served")

	## Probe E — backfires
	## margin_of_appreciation weight 1.0 >= STRENGTH_BACKFIRE_THRESHOLD (0.05)
	## and appears in immune_to → strength set. Resolver returns backfires.
	var probe_backfire: Dictionary = {"margin_of_appreciation": 1.0}
	var result_e: Dictionary = _eff_script.resolve(probe_backfire, weakness1, strength1)
	_assert(result_e.get("bucket", "") == "backfires",
		"margin_of_appreciation probe backfires against file_says_served")

	## Tally — all five buckets must be reachable.
	var buckets_seen: Dictionary = {}
	buckets_seen[result_a.get("bucket", "")] = true
	buckets_seen[result_b.get("bucket", "")] = true
	buckets_seen[result_c.get("bucket", "")] = true
	buckets_seen[result_d.get("bucket", "")] = true
	buckets_seen[result_e.get("bucket", "")] = true
	_assert(buckets_seen.size() == 5,
		"all five distinct buckets reachable across probes (%d seen)" % buckets_seen.size())


## Confirms that every move in landlord_counsel_ch1 has a non-empty immune_to
## array. Empty immune_to arrays meant the backfire path was never reachable
## for any player move choice (Step 1.3 root cause).
func _test_immune_to_populated(opponent: Object) -> void:
	print("[T2] immune_to_populated")
	for round_index in range(1, 4):
		var court_round: Object = opponent.get_round(round_index)
		if court_round == null:
			_fail("round %d exists" % round_index)
			continue
		for move in court_round.moves:
			_assert(move.immune_to.size() > 0,
				"move '%s' has non-empty immune_to" % move.move_id)


func _assert(condition: bool, msg: String) -> void:
	if condition:
		_pass_count += 1
		print("  PASS: %s" % msg)
	else:
		_fail_count += 1
		printerr("  FAIL: %s" % msg)


func _fail(msg: String) -> void:
	_fail_count += 1
	printerr("[TestBattle] FAIL: %s" % msg)


func _finish() -> void:
	print("")
	print("[TestBattle] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		print("[TestBattle] PASS")
		quit(0)
