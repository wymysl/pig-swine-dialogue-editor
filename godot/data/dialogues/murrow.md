# murrow — dialogue authoring notes

Companion to `murrow.json`. Authoring metadata extracted
from the JSON in Phase 3 of the schema-cohesion refactor; the
runtime never read these blocks, only authors did.

## comment v1 4 coffee

V1.4 (2026-05-12): two coffee_reaction_* states added per minigames.txt §Character reactions §Murrow. Gated on chapter1.coffee_buff and chapter1.met_murrow per the design brief. Additional clause !chapter1.entered_court scopes them to the pre-court window. Reactions placed BEFORE court_readiness_check (whose long conjunction matches the same post-recruit window) so they win priority while a buff is set. Murrow addresses Cula as 'Doctor Cula' in speech per existing pattern in this file (first_meeting opening).
