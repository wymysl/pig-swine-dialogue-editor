# judge_district_ch1 — dialogue authoring notes

Companion to `judge_district_ch1.json`. Authoring metadata extracted
from the JSON in Phase 3 of the schema-cohesion refactor; the
runtime never read these blocks, only authors did.

## Provenance

V1.6 phase-7 voice pack (V1.6_court_rounds.md). Source draft: narrative_revision/phase_7_drafts/V1_6_draft_pass5.md (pass 5 — pass-1 + four §J review passes baked in; arbitrated commit shape).

## Scope

judge_district_ch1.json owns the District Court Judge's three rounds of dry-surprise across Beat 12. The states are gated on chapter1.client_meeting_stance ('sympathetic' / 'blunt_procedural' / 'technical') for Round 1 and Round 3, and on chapter1.casebook_judge_state for round-progression. Round 1 reactions also reference chapter1.client_meeting_evidence ('wojcik_witness_statement' / 'return_to_sender_slip' / 'lease_1962_inheritance_1987') via the stance flag (1:1 mapping per V1.4 — sympathetic→Wójcik, blunt_procedural→slip+countersignature, technical→countersignature only). Round 2 is single-branch (no stance variation in Whimsy's third-clause non-cure preemption argument). Round 3 sympathetic and blunt_procedural variants share remedy-announcement text; technical adds the one-clause acknowledgment that the underlying tenancy is not before the court.

## Engine flags required

The casebook engine must set chapter1.casebook_judge_state to one of: 'round_1_open', 'round_1_react', 'round_2_open', 'round_2_react', 'round_3_open', 'round_3_remedy'. After each judge state dismisses, the engine should clear or advance the flag. Round_open states fire the bench prompt before the player's argument; round_react / round_3_remedy states fire after.

## Address forms

Bench addresses Cula as 'Counsel' throughout. The judge does not address Halina. The judge does not name the landlord's counsel.
