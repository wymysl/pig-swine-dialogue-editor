# postcard_swine_ch1 — dialogue authoring notes

Companion to `postcard_swine_ch1.json`. Authoring metadata extracted
from the JSON in Phase 3 of the schema-cohesion refactor; the
runtime never read these blocks, only authors did.

## Provenance

V1.7 phase-7 voice pack (V1.7_post_court_payoff.md). Source draft: narrative_revision/phase_7_drafts/V1_7_draft_pass5.md (pass 5 — commit shape; pass-4 arbitration baked in).

## Scope

postcard_swine_ch1.json owns the Beat-14 final stinger at the close of Chapter 1. It fires after the celebration sequence (Beat 13) has completed and the team has dispersed back to work. Asia announces the postcard; Mr. Pig reads the body aloud; Whimsy delivers a single archaic-deflection beat. The chapter closes with the Day-One Survivor badge and route unlocks.

## Engine flags required

Fires when chapter1.court_won_procedural_reset == true and chapter1.beat13_complete == true. On dismiss of the final state, sets chapter1.complete = true and unlocks routes: residential, business_district, court_plaza. Awards badge: day_one_survivor.

## Address forms

Asia addresses Pig as 'Mr. Pig'. Pig reads Swine's postcard text aloud verbatim. Swine's postcard address line: 'To Mr. Pig, Pig & Swine, Warsaw'.
