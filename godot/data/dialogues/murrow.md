# murrow — dialogue authoring notes

Companion to `murrow.json`. Authoring metadata extracted
from the JSON in Phase 3 of the schema-cohesion refactor; the
runtime never read these blocks, only authors did.

## comment v1 4 coffee

V1.4 (2026-05-12): two coffee_reaction_* states added per minigames.txt §Character reactions §Murrow. Gated on chapter1.coffee_buff and chapter1.met_murrow per the design brief. Additional clause !chapter1.entered_court scopes them to the pre-court window. Reactions placed BEFORE court_readiness_check (whose long conjunction matches the same post-recruit window) so they win priority while a buff is set.

V1.5 (2026-05-19, Piotr): 'Doctor Cula' dropped from Murrow's speech entirely. Canon: Murrow uses 'Dr. A. Cula' exactly ONCE at first meeting (the form appears in `before_pig` for path A and in `state_2_response_friendly` / `_professional` for path B); 'Cula' in every subsequent state regardless of register — court, client-facing scenes, and cold-rebuke beats included. The coffee_reaction_bad line, the post_decoy_incapacity rebuke, and `court_readiness_check` all use bare 'Cula'. Authoring rule: a line that reaches for 'Doctor Cula' should be rewritten with 'Cula' or with no direct address. Carries content load via word choice, not via reverting the form.
