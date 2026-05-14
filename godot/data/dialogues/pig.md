# pig — dialogue authoring notes

Companion to `pig.json`. Authoring metadata extracted
from the JSON in Phase 3 of the schema-cohesion refactor; the
runtime never read these blocks, only authors did.

## comment v1 4 coffee

V1.4 (2026-05-12): two coffee_reaction_* states added per minigames.txt §Character reactions §Mr. Pig. Gated on chapter1.coffee_buff and chapter1.met_pig per the design brief. Additional clause !chapter1.entered_court so coffee reactions stop firing once the court scene begins (post-court the player is hearing case-outcome material, not coffee remarks). Reactions are placed BEFORE has_binder_and_memo because that state's broad gate (has_law_binder && has_rights_memo) would otherwise win priority for the entire post-recruit window. JSON-order priority is the runner's only mechanism for resolving multiple matches.
