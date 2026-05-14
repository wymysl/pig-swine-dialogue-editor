## scripts/systems/battle/principle_move.gd
##
## Casebook Battle System — PrincipleMove data class.
##
## A PrincipleMove is one invocable legal principle drawn from a Judgment.
## In Court Rounds, effectiveness is authored directly in the round JSON
## (see data/court_rounds/_schema.md); the `tags` field here is used by the
## Effectiveness resolver for dynamic wild-argument encounters only.
##
## This is a value-type RefCounted; do not attach to the scene tree.

class_name PrincipleMove
extends RefCounted


## Unique string id matching the move entry in judgments.json.
var id: String = ""

## Short player-facing name (e.g. "Access to Court", "Practical Rights").
var name: String = ""

## Flavour text shown when the move is selected (one sentence; present-tense
## invocation, e.g. "The right of access to a court must be practical and
## effective, not merely theoretical.").
var flavour_text: String = ""

## Weighted tag set: { "tag_id": float_weight, ... } — used by the
## Effectiveness resolver for wild-argument encounters.
## Tags must be declared in data/tag_taxonomy.json.
var tags: Dictionary = {}

## The Judgment this move belongs to. Set by the loading code.
var judgment_id: String = ""

## Base persuasive force: float, typically 1.0. Scaled by effectiveness bucket
## in Effectiveness.bucket_to_force_multiplier(). May be tuned per-move
## to allow stronger or weaker variants.
var base_force: float = 1.0


## from_dict — parse from a move entry in judgments.json.
## @param data     The move dict.
## @param jid      The parent judgment id.
static func from_dict(data: Dictionary, jid: String) -> PrincipleMove:
    if not data.has("id") or not data.has("name"):
        push_error("PrincipleMove.from_dict: missing 'id' or 'name' in judgment '%s'" % jid)
        return null
    var m := PrincipleMove.new()
    m.id           = str(data.get("id", ""))
    m.name         = str(data.get("name", ""))
    m.flavour_text = str(data.get("flavour_text", ""))
    m.judgment_id  = jid
    m.base_force   = float(data.get("base_force", 1.0))

    var raw_tags = data.get("tags", {})
    if raw_tags is Dictionary:
        m.tags = raw_tags
    else:
        push_error("PrincipleMove.from_dict: 'tags' must be a Dictionary in move '%s'" % m.id)

    return m


## to_dict — serialise to JSON-compatible dictionary.
func to_dict() -> Dictionary:
    return {
        "id":           id,
        "name":         name,
        "flavour_text": flavour_text,
        "tags":         tags,
        "judgment_id":  judgment_id,
        "base_force":   base_force,
    }
