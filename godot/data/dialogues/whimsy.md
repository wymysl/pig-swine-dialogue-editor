# whimsy — dialogue authoring notes

Companion to `whimsy.json`. Authoring metadata extracted
from the JSON in Phase 3 of the schema-cohesion refactor; the
runtime never read these blocks, only authors did.

## comment v1 4 coffee

V1.4 (2026-05-12): four coffee_reaction_* states added per minigames.txt §Character reactions §Whimsy. Two outcomes (Perfect = procedurally_alert_plus; Bad = over_caffeinated), each in pre- and post-recruit variants per the design brief's address-form rule (Whimsy uses 'Cula' only after recruited_whimsy flips; pre-recruit uses 'Dr. A. Cula'). In normal play coffee_buff is only set after recruited_whimsy by definition (the minigame trigger requires it), so the pre-recruit variants are practically unreachable. They exist for completeness per the design brief. Reactions placed AFTER before_meeting; !entered_court scopes them to pre-court.
