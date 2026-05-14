# barista — dialogue authoring notes

Companion to `barista.json`. Authoring metadata extracted
from the JSON in Phase 3 of the schema-cohesion refactor; the
runtime never read these blocks, only authors did.

## comment buff contract

Buff values written by coffee_brewing.gd (see scripts/systems/minigames/coffee_brewing.gd::_compute_grade): 'procedurally_alert_plus' (S grade), 'procedurally_alert' (A/B grade), 'caffeinated' (C grade), 'over_caffeinated' (D grade and F grade). chapter1.coffee_brew_grade carries the grade letter; the F-grade machine-objects state gates on 'over_caffeinated' AND coffee_brew_grade == 'F' to distinguish it from the D-grade procedural_mud case.

## comment retry pending code

The coffee_retry_prompt state has a trigger that matches any buff outcome. With first-match-in-JSON-order, the more specific outcome states above will fire before this one, so coffee_retry_prompt is unreachable on the FIRST post-minigame interaction. The intent is that an outcome's on_dismiss flips a 'coffee_outcome_acknowledged' flag (or equivalent), and the retry state's trigger then becomes the first match. chapter1.coffee_retry_decision is now declared, but the acknowledgement flag and retry honor still need Code wiring; see PROPOSAL_coffee_engine_followups.md. Until Code wires those pieces, this state remains structurally present but inert.

## comment scope

Coffee tutorial dialogue — V1.4 pass 1. The legacy single coffee_outcome state has been split into five buff-gated states (one per spec §Result grades buff outcome, plus a separate F-grade variant), as required by the SCOPE NOTE that previously lived in V1.3. The retry prompt is authored as a standalone state with an in-dialogue options block. The runner picks first-match in JSON order; specific states are placed BEFORE more permissive ones (machine_objects before generic over_caffeinated; outcome states before retry).
