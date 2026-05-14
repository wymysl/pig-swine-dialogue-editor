## scripts/systems/battle/judgment.gd
##
## Casebook Battle System — Judgment data class.
##
## A Judgment is a court ruling the player has collected. It unlocks one or more
## PrincipleMoves. Loaded from data/judgments.json by the Casebook autoload.
##
## This is a value-type RefCounted; do not attach to the scene tree.

class_name Judgment
extends RefCounted


## Unique string id matching the judgments.json key.
var id: String = ""

## Display name shown in the Casebook and battle UI.
var display_name: String = ""

## Short citation reference (e.g. "Golder v. United Kingdom (1975)").
var citation: String = ""

## One-sentence summary of the ruling's significance shown in Casebook detail view.
var summary: String = ""

## Weighted tag set: { "tag_id": float_weight, ... } — used by the
## Effectiveness resolver for wild-argument encounters.
## Tags must be declared in data/tag_taxonomy.json.
var tags: Dictionary = {}

## IDs of PrincipleMoves this judgment unlocks. Each id is a key in
## the `moves` block of judgments.json.
var move_ids: Array[String] = []

## Whether the player currently holds this judgment.
## Set by Casebook autoload.
var unlocked: bool = false


## from_dict — parse a single judgment entry from the JSON representation.
## Returns a populated Judgment or null on validation failure.
static func from_dict(data: Dictionary) -> Judgment:
    if not data.has("id") or not data.has("display_name"):
        push_error("Judgment.from_dict: missing required fields 'id' or 'display_name'")
        return null
    var j := Judgment.new()
    j.id           = str(data.get("id", ""))
    j.display_name = str(data.get("display_name", ""))
    j.citation     = str(data.get("citation", ""))
    j.summary      = str(data.get("summary", ""))
    j.unlocked     = bool(data.get("unlocked", false))

    var raw_tags = data.get("tags", {})
    if raw_tags is Dictionary:
        j.tags = raw_tags
    else:
        push_error("Judgment.from_dict: 'tags' must be a Dictionary in judgment '%s'" % j.id)

    var raw_moves = data.get("move_ids", [])
    if raw_moves is Array:
        for mid in raw_moves:
            j.move_ids.append(str(mid))
    else:
        push_error("Judgment.from_dict: 'move_ids' must be an Array in judgment '%s'" % j.id)

    return j


## to_dict — serialise back to a JSON-compatible dictionary (for save/export).
func to_dict() -> Dictionary:
    return {
        "id":           id,
        "display_name": display_name,
        "citation":     citation,
        "summary":      summary,
        "tags":         tags,
        "move_ids":     move_ids,
        "unlocked":     unlocked,
    }
