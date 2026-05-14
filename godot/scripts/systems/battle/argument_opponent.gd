## scripts/systems/battle/argument_opponent.gd
##
## Casebook Battle System — ArgumentOpponent data class.
##
## Represents an opposing legal argument in a wild-argument or Court Round
## encounter. In Court Rounds, opponents are the judge's counter-questions
## (loaded from the counter_questions block of the round JSON); the
## ArgumentOpponent wraps each one for uniform handling by the Effectiveness
## resolver in wild encounters.
##
## This is a value-type RefCounted; do not attach to the scene tree.

class_name ArgumentOpponent
extends RefCounted


## Unique id. In Court Rounds this matches the counter_question id.
var id: String = ""

## Player-facing argument text (judge's counter-question or hostile proposition).
var argument_text: String = ""

## Tags indicating the argument's vulnerable points — player moves that
## match these tags are effective.
## { "tag_id": float_weight, ... } summing to ~1.0.
var weakness_tags: Dictionary = {}

## Tags indicating the argument's strengths — player moves whose primary tag
## matches a strength tag may backfire.
## { "tag_id": float_weight, ... } summing to ~1.0.
var strength_tags: Dictionary = {}

## Argument strength: the number of effective-hit equivalents required to
## defeat this argument. Decremented by submit_citation() in BattleController.
var argument_strength: int = 2

## Current remaining strength (runtime, managed by BattleController).
var current_strength: int = 2


## from_counter_question_dict — construct from a Phase 2 counter_question
## entry in a court_round JSON file.
## Does NOT populate weakness/strength tags (those are resolved from authored
## effectiveness values in Court Rounds, not dynamically computed).
static func from_counter_question_dict(data: Dictionary) -> ArgumentOpponent:
    if not data.has("id"):
        push_error("ArgumentOpponent.from_counter_question_dict: missing 'id'")
        return null
    var a := ArgumentOpponent.new()
    a.id                = str(data.get("id", ""))
    a.argument_text     = str(data.get("judge_line", ""))
    a.argument_strength = int(data.get("argument_strength", 2))
    a.current_strength  = a.argument_strength
    return a


## from_wild_argument_dict — construct from a wild-argument JSON entry.
## Populates weakness_tags and strength_tags for use with the Effectiveness
## resolver in dynamic wild encounters.
static func from_wild_argument_dict(data: Dictionary) -> ArgumentOpponent:
    if not data.has("id") or not data.has("argument_text"):
        push_error("ArgumentOpponent.from_wild_argument_dict: missing 'id' or 'argument_text'")
        return null
    var a := ArgumentOpponent.new()
    a.id            = str(data.get("id", ""))
    a.argument_text = str(data.get("argument_text", ""))

    var wt = data.get("weakness_tags", {})
    if wt is Dictionary:
        a.weakness_tags = wt
    else:
        push_error("ArgumentOpponent: 'weakness_tags' must be a Dictionary in '%s'" % a.id)

    var st = data.get("strength_tags", {})
    if st is Dictionary:
        a.strength_tags = st
    else:
        push_error("ArgumentOpponent: 'strength_tags' must be a Dictionary in '%s'" % a.id)

    a.argument_strength = int(data.get("argument_strength", 2))
    a.current_strength  = a.argument_strength
    return a


## is_defeated — true when current_strength has reached zero.
func is_defeated() -> bool:
    return current_strength <= 0


## apply_hit — reduce current_strength by the given amount (minimum 0).
## Returns remaining strength.
func apply_hit(amount: int) -> int:
    current_strength = max(0, current_strength - amount)
    return current_strength
