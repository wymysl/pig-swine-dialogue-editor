## scripts/systems/battle/effectiveness.gd
##
## Casebook Battle System — effectiveness resolver.
##
## Single source for the rule that maps (player move tags, opponent argument tags)
## to one of five narrative buckets: super_effective, effective, not_very_effective,
## no_effect, backfires.
##
## This is a SKELETON. The agreed math is here; the wiring to taxonomy assertions
## and the GUT tests are TODO and must be written before the resolver ships.

class_name Effectiveness
extends RefCounted


## A move or opponent's argument is described by a weighted tag set:
## { "tag_id": float_weight, ... } with weights summing to ~1.0.
##
## Both player moves and opponent arguments use this same shape. Opponent
## arguments additionally carry a `strength_tags` set — tags on which the
## argument is *strongest*. A move whose primary tag matches any strength tag
## triggers the `backfires` bucket regardless of the dot-product score.

const STRENGTH_BACKFIRE_THRESHOLD: float = 0.5  ## min weight to count as a "primary" tag

const BUCKET_THRESHOLDS := {
    "super_effective":     0.70,
    "effective":           0.40,
    "not_very_effective":  0.15,
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
## TODO: implement against the loaded taxonomy. Pseudocode:
##
##   for tag in move.tags.keys():
##       assert(taxonomy.has_tag(tag), "unknown tag: " + tag)
static func validate_against_taxonomy(_tags: Dictionary, _taxonomy: Dictionary) -> bool:
    return true  # placeholder


# --- internal --------------------------------------------------------------

static func _assert_weights_sum_to_one(tags: Dictionary, label: String) -> void:
    if tags.is_empty():
        return
    var total: float = 0.0
    for k in tags:
        total += float(tags[k])
    var diff: float = absf(total - 1.0)
    assert(diff < 0.01, "%s weights must sum to ~1.0; got %f" % [label, total])
