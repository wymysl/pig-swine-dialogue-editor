# crab — dialogue authoring notes

Companion to `crab.json`. Authoring metadata extracted
from the JSON in Phase 3 of the schema-cohesion refactor; the
runtime never read these blocks, only authors did.

## comment v1 4 coffee

V1.4 (2026-05-12): four coffee_reaction_* states added per minigames.txt §Character reactions §Crab. Two outcomes (Perfect = procedurally_alert_plus; Bad = over_caffeinated), each in pre- and post-recruit variants per the design brief's address-form rule (Crab uses 'Cula' only after recruited_crab flips; pre-recruit uses 'Dr. A. Cula'). In normal play, coffee_buff is only set after recruited_whimsy, which is gated downstream of recruited_crab — so the pre-recruit variants are practically unreachable. They exist for completeness per the design brief. Reactions are placed AFTER the engagement states and BEFORE after_engagement so they win priority during the buff window. !entered_court scopes them to pre-court.
