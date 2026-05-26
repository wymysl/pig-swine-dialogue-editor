extends SceneTree
## tests/test_effectiveness.gd — exercises the Casebook Battle effectiveness
## resolver in scripts/systems/battle/effectiveness.gd.
##
## Covers: bucket mapping by score, backfire on strength collision, weight
## normalization assertion (skipped if asserts are stripped in release),
## bucket_to_force_multiplier mapping, taxonomy validation against the
## actual closed list in data/tag_taxonomy.json.
##
## Runs headless: `godot --headless --path . --script tests/test_effectiveness.gd`
## Exits 0 on pass, 1 on fail.

var _pass_count: int = 0
var _fail_count: int = 0


func _init() -> void:
	print("[TestEffectiveness] Starting...")

	var script: GDScript = load("res://scripts/systems/battle/effectiveness.gd") as GDScript
	if script == null:
		_fail("Could not load effectiveness.gd")
		_finish()
		return

	## -------------------------------------------------------------------
	## Test 1: bucket_to_force_multiplier mapping is exact.
	## -------------------------------------------------------------------
	## These multipliers are tunable but committed; if they drift the
	## battle math drifts with them, so they're worth pinning.
	if not is_equal_approx(script.bucket_to_force_multiplier("super_effective"), 1.50):
		_fail("T1: super_effective multiplier should be 1.50")
	elif not is_equal_approx(script.bucket_to_force_multiplier("effective"), 1.00):
		_fail("T1: effective multiplier should be 1.00")
	elif not is_equal_approx(script.bucket_to_force_multiplier("not_very_effective"), 0.50):
		_fail("T1: not_very_effective multiplier should be 0.50")
	elif not is_equal_approx(script.bucket_to_force_multiplier("no_effect"), 0.00):
		_fail("T1: no_effect multiplier should be 0.00")
	elif not is_equal_approx(script.bucket_to_force_multiplier("backfires"), -0.50):
		_fail("T1: backfires multiplier should be -0.50")
	elif not is_equal_approx(script.bucket_to_force_multiplier("invalid_bucket"), 0.00):
		_fail("T1: invalid bucket should fall through to 0.00")
	else:
		_pass("T1: bucket_to_force_multiplier mapping pinned")

	## -------------------------------------------------------------------
	## Test 2: resolve() — super_effective when full weight on a weakness.
	## -------------------------------------------------------------------
	var move_tags: Dictionary = {"service_of_process": 1.0}
	var weak: Dictionary = {"service_of_process": 1.0}
	var strong: Dictionary = {"proportionality": 1.0}
	var r: Dictionary = script.resolve(move_tags, weak, strong)
	if r.bucket != "super_effective":
		_fail("T2: expected super_effective, got %s (score %f)" % [r.bucket, r.score])
	elif not is_equal_approx(r.score, 1.0):
		_fail("T2: expected score 1.0, got %f" % r.score)
	elif r.primary_match != "service_of_process":
		_fail("T2: primary_match should be 'service_of_process', got '%s'" % r.primary_match)
	else:
		_pass("T2: full-weight tag match on opponent weakness → super_effective")

	## -------------------------------------------------------------------
	## Test 3: resolve() — effective when partial weight match.
	## -------------------------------------------------------------------
	## 0.6 weight on a weakness with 0.1 magnitude → 0.06 score, which is
	## inside the "effective" band (>= 0.04, < 0.07). Move's other 0.4 is
	## on an unrelated tag and contributes nothing.
	## (Recalibrated Step 2.3 2026-05-26: thresholds 10× lower to match
	## normalized multi-tag judgment weights.)
	move_tags = {"service_of_process": 0.6, "procedural_fairness": 0.4}
	weak = {"service_of_process": 0.1, "access_to_court": 0.9}
	strong = {"margin_of_appreciation": 1.0}
	r = script.resolve(move_tags, weak, strong)
	if r.bucket != "effective":
		_fail("T3: expected effective, got %s (score %f)" % [r.bucket, r.score])
	elif not is_equal_approx(r.score, 0.06):
		_fail("T3: expected score 0.06, got %f" % r.score)
	else:
		_pass("T3: partial weight match → effective bucket")

	## -------------------------------------------------------------------
	## Test 4: resolve() — no_effect when no overlap.
	## -------------------------------------------------------------------
	move_tags = {"proportionality": 1.0}
	weak = {"service_of_process": 1.0}
	strong = {"legal_certainty": 1.0}
	r = script.resolve(move_tags, weak, strong)
	if r.bucket != "no_effect":
		_fail("T4: expected no_effect, got %s (score %f)" % [r.bucket, r.score])
	elif r.score != 0.0:
		_fail("T4: expected score 0.0, got %f" % r.score)
	else:
		_pass("T4: zero overlap → no_effect bucket")

	## -------------------------------------------------------------------
	## Test 5: resolve() — backfires when move's primary tag is opponent strength.
	## -------------------------------------------------------------------
	## STRENGTH_BACKFIRE_THRESHOLD is 0.5; a 1.0-weight move that hits the
	## opponent's strength set must backfire regardless of weakness overlap.
	move_tags = {"margin_of_appreciation": 1.0}
	weak = {"margin_of_appreciation": 1.0}  # also a weakness; backfire still wins
	strong = {"margin_of_appreciation": 1.0}
	r = script.resolve(move_tags, weak, strong)
	if r.bucket != "backfires":
		_fail("T5: expected backfires, got %s" % r.bucket)
	elif r.primary_match != "margin_of_appreciation":
		_fail("T5: primary_match should be 'margin_of_appreciation'")
	elif not is_equal_approx(r.score, -1.0):
		_fail("T5: expected score -1.0, got %f" % r.score)
	else:
		_pass("T5: primary tag in opponent strength → backfires (overrides weakness)")

	## -------------------------------------------------------------------
	## Test 6: resolve() — minor weight on opponent strength does NOT backfire.
	## -------------------------------------------------------------------
	## A move with only 0.03 weight on a strong tag is below the
	## STRENGTH_BACKFIRE_THRESHOLD of 0.05 and should NOT backfire.
	## (Recalibrated Step 2.3 2026-05-26: threshold lowered to 0.05.)
	move_tags = {"margin_of_appreciation": 0.03, "service_of_process": 0.97}
	weak = {"service_of_process": 1.0}
	strong = {"margin_of_appreciation": 1.0}
	r = script.resolve(move_tags, weak, strong)
	if r.bucket == "backfires":
		_fail("T6: minor tag on strength should NOT trigger backfire")
	elif r.bucket != "super_effective":
		_fail("T6: expected super_effective (0.97 on weakness), got %s (score %f)" % [r.bucket, r.score])
	else:
		_pass("T6: sub-threshold strength overlap → no backfire")

	## -------------------------------------------------------------------
	## Test 7: validate_against_taxonomy — known tags pass.
	## -------------------------------------------------------------------
	var taxonomy: Dictionary = _load_taxonomy()
	if taxonomy.is_empty():
		_fail("T7: could not load data/tag_taxonomy.json")
	else:
		var valid_tags: Dictionary = {
			"echr_6": 0.5,
			"service_of_process": 0.3,
			"civil_proceedings": 0.2,
		}
		if not script.validate_against_taxonomy(valid_tags, taxonomy):
			_fail("T7: validate rejected all-known tags")
		else:
			_pass("T7: validate accepts known tags from each section")

	## -------------------------------------------------------------------
	## Test 8: validate_against_taxonomy — unknown tag rejected.
	## -------------------------------------------------------------------
	if not taxonomy.is_empty():
		var typo_tags: Dictionary = {
			"echr_6": 0.5,
			"service_of_porcess": 0.5,  # typo
		}
		if script.validate_against_taxonomy(typo_tags, taxonomy):
			_fail("T8: validate accepted unknown tag")
		else:
			_pass("T8: validate rejects unknown/typo tag")

	## -------------------------------------------------------------------
	## Test 9: validate_against_taxonomy — empty tag set is vacuously valid.
	## -------------------------------------------------------------------
	if not taxonomy.is_empty():
		if not script.validate_against_taxonomy({}, taxonomy):
			_fail("T9: empty tag set should validate")
		else:
			_pass("T9: empty tag set validates (vacuous truth)")

	## -------------------------------------------------------------------
	## Test 10: validate_against_taxonomy — taxonomy doc keys ignored.
	## -------------------------------------------------------------------
	## "_doc" and "_owner" appear in the taxonomy JSON. A move tagged "_doc"
	## must NOT validate even though the key exists in the section, because
	## doc keys are sentinels not real tags.
	if not taxonomy.is_empty():
		var doc_tags: Dictionary = {"_doc": 1.0}
		if script.validate_against_taxonomy(doc_tags, taxonomy):
			_fail("T10: validate accepted '_doc' sentinel as a real tag")
		else:
			_pass("T10: validate rejects '_doc' sentinel keys")

	_finish()


func _load_taxonomy() -> Dictionary:
	var path: String = "res://data/tag_taxonomy.json"
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var text: String = file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed == null or not parsed is Dictionary:
		return {}
	return parsed


func _pass(msg: String) -> void:
	_pass_count += 1
	print("[TestEffectiveness] PASS: ", msg)


func _fail(msg: String) -> void:
	_fail_count += 1
	printerr("[TestEffectiveness] FAIL: ", msg)


func _finish() -> void:
	print("")
	print("[TestEffectiveness] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		print("[TestEffectiveness] PASS")
		quit(0)
