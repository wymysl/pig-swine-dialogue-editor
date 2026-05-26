## scripts/systems/battle/effectiveness.gd
##
## Casebook Battle System — effectiveness resolver.
##
## Single source for the rule that maps (player move tags, opponent argument tags)
## to one of five narrative buckets: super_effective, effective, not_very_effective,
## no_effect, backfires.
##
## The agreed math is here. Tag-taxonomy validation is implemented against the
## closed list in data/tag_taxonomy.json (see validate_against_taxonomy below).
## Headless tests live in tests/test_effectiveness.gd (resolve buckets, backfire,
## taxonomy validation).
##
## Wiring: battle_controller.gd::player_present() (see resolve() invocation
## near line 593) calls resolve(move_tags, opp_weakness_tags, opp_strength_tags)
## once the controller has determined the active question is a Phase 2 closing
## (i.e. _is_phase_one_round() returns false). resolve() returns
## { bucket, score, primary_match }, and the controller then converts the bucket
## via bucket_to_force_multiplier() into the numeric multiplier applied to the
## opponent's argument-strength bar.
##
## Author trap: every weighted tag dict passed in must sum to ~1.0. The
## _assert_weights_sum_to_one helper enforces this and is the most common cause
## of crashes when court_round JSON is hand-edited.

class_name Effectiveness
extends RefCounted


## A move or opponent's argument is described by a weighted tag set:
## { "tag_id": float_weight, ... } with weights summing to ~1.0.
##
## Both player moves and opponent arguments use this same shape. Opponent
## arguments additionally carry a `strength_tags` set — tags on which the
## argument is *strongest*. A move whose primary tag matches any strength tag
## triggers the `backfires` bucket regardless of the dot-product score.

## Calibrated for normalized multi-tag judgments (Step 2.3, 2026-05-26).
## With 10-tag judgments each tag normalizes to ~0.09-0.10 weight; dot products
## against 3–4 tag weak_to arrays peak around 0.25-0.35.  Thresholds are set
## at 1/10th of the pre-calibration values so the full bucket range is reachable
## with real in-game moves.  Synthetic single-tag probes (weight 1.0) still
## produce super_effective (score 0.25-0.33 >> 0.07); multi-tag probes with
## partial overlap fall into lower buckets.
const STRENGTH_BACKFIRE_THRESHOLD: float = 0.05  ## min weight to count as a "primary" tag

const BUCKET_THRESHOLDS := {
    "super_effective":     0.07,
    "effective":           0.04,
    "not_very_effective":  0.015,
    "no_effect":           0.00,
    # backfires is < 0.0 OR strength-collision (handled separately)
}


## Resolve a player move against an opponent argument.
##
## @param move_tags         Dictionary[String, float] — player move's weighted tag set
## @param opp_weakness_tags Dictionary[String, float] — opponent's vulnerable tags
## @param opp_strength_tags Dictionary[String, float] — opponent's strong tags (causes backfire)
## @return                  Dictionary { bucket: String, score: float, primary_match: String }
static func resolve(
    move_tags: Dictionary,
    opp_weakness_tags: Dictionary,
    opp_strength_tags: Dictionary
) -> Dictionary:
    _assert_weights_sum_to_one(move_tags, "move_tags")
    _assert_weights_sum_to_one(opp_weakness_tags, "opp_weakness_tags")
    _assert_weights_sum_to_one(opp_strength_tags, "opp_strength_tags")

    # Backfire check: does the move's primary tag (weight >= STRENGTH_BACKFIRE_THRESHOLD)
    # appear in the opponent's strength set?
    var primary_match: String = ""
    for tag in move_tags:
        var w: float = move_tags[tag]
        if w >= STRENGTH_BACKFIRE_THRESHOLD and opp_strength_tags.has(tag):
            primary_match = tag
            return {
                "bucket": "backfires",
                "score": -opp_strength_tags[tag],
                "primary_match": tag,
            }

    # Score = weighted dot product of move_tags and opp_weakness_tags.
    var score: float = 0.0
    var matched_tag: String = ""
    var matched_contrib: float = 0.0
    for tag in move_tags:
        if opp_weakness_tags.has(tag):
            var contrib: float = move_tags[tag] * opp_weakness_tags[tag]
            score += contrib
            if contrib > matched_contrib:
                matched_contrib = contrib
                matched_tag = tag

    # Map score to bucket.
    var bucket: String = "no_effect"
    if score >= BUCKET_THRESHOLDS.super_effective:
        bucket = "super_effective"
    elif score >= BUCKET_THRESHOLDS.effective:
        bucket = "effective"
    elif score >= BUCKET_THRESHOLDS.not_very_effective:
        bucket = "not_very_effective"
    else:
        bucket = "no_effect"

    return {
        "bucket": bucket,
        "score": score,
        "primary_match": matched_tag,
    }


## Convert a bucket name to the persuasive-force multiplier applied to the
## opponent's argument-strength bar. Tunable; this is the agreed v1 mapping.
static func bucket_to_force_multiplier(bucket: String) -> float:
    match bucket:
        "super_effective":    return 1.50
        "effective":          return 1.00
        "not_very_effective": return 0.50
        "no_effect":          return 0.00
        "backfires":          return -0.50  # damages player composure instead
        _: return 0.00


## Validate that every tag id used is in the closed taxonomy at
## data/tag_taxonomy.json. Called once at battle start; not per-move.
##
## @param tags     Dictionary[String, float] — the weighted tag set to validate.
## @param taxonomy Dictionary — parsed contents of data/tag_taxonomy.json. The
##                 union of taxonomy.article_tags, taxonomy.principle_tags, and
##                 taxonomy.context_tags is the closed set; any tag not in that
##                 union triggers a push_error and a false return. Documentation
##                 keys (any key starting with "_") are ignored.
## @return         true if every tag is in the union; false on the first miss.
##
## On failure, push_error names the offending tag so the JSON author can fix
## the source. Caller decides whether to halt the battle (recommended) or
## downgrade gracefully.
static func validate_against_taxonomy(tags: Dictionary, taxonomy: Dictionary) -> bool:
    var known: Dictionary = _flatten_taxonomy(taxonomy)
    for tag in tags:
        if not known.has(tag):
            push_error("Effectiveness: unknown tag '%s' (not in tag_taxonomy.json)" % tag)
            return false
    return true


## Internal: build the union of all real tag ids in the taxonomy as a Dictionary
## (used as a Set). Skips any key beginning with "_" (documentation fields like
## _doc, _owner).
static func _flatten_taxonomy(taxonomy: Dictionary) -> Dictionary:
    var out: Dictionary = {}
    for section_name in ["article_tags", "principle_tags", "context_tags"]:
        var section: Dictionary = taxonomy.get(section_name, {})
        for key in section:
            var k: String = String(key)
            if k.begins_with("_"):
                continue
            out[k] = true
    return out


# --- internal --------------------------------------------------------------

static func _assert_weights_sum_to_one(tags: Dictionary, label: String) -> void:
    if tags.is_empty():
        return
    var total: float = 0.0
    for k in tags:
        total += float(tags[k])
    var diff: float = absf(total - 1.0)
    assert(diff < 0.01, "%s weights must sum to ~1.0; got %f" % [label, total])
