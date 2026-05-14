# asia_hint_states_ch1 — dialogue authoring notes

Companion to `asia_hint_states_ch1.json`. Authoring metadata extracted
from the JSON in Phase 3 of the schema-cohesion refactor; the
runtime never read these blocks, only authors did.

## Provenance

V1.A phase-7 voice pack (V1.A_asia_hint_states.md). Source draft: narrative_revision/phase_7_drafts/V1_A_draft_pass3.md (pass 3 — pass-1 + pass-2 hostile critique + in-house arbitration; 0 critical failures; commit shape). 10 legacy lines verbatim from _legacy/dialogue_samples.txt lines 50-59; 2 new lines (halina_met, archive_research_complete) authored from pack §B.1 recommended sample shapes. V1.4 (2026-05-12): four coffee-result hint states added per minigames.txt §Chapter integration — Chapter 1 (Asia return comments). Inserted between hint_court_ready and hint_won_court so they only fire in the post-readiness, pre-court window.

## Scope

asia_hint_states_ch1.json owns Asia's repeatable hint-NPC surface for chapter 1. Encodes the get_asia_hint() first-unmet-flag-wins priority logic from story.txt lines 1245-1288. 16 states in priority order (12 progression + 4 coffee-result); the engine evaluates triggers top-to-bottom and returns the first matching state's line. All states are repeatable (no on_dismiss except hint_halina_arrived_announcement). Asia is the sole speaker; there is no turn structure. Voice-reference records are in dialogue_samples_asia.jsonl (ids: asia_ch01_v1_a_p3_hint_state_<flag>_001).

## Engine flags required

The engine calls get_asia_hint() when the player interacts with Asia's reception desk. Evaluate state triggers top-to-bottom; return the first match. All flags are in the chapter1 namespace. The default state (state 16) has no flag condition and always matches if no earlier state fires.

## Address forms

Asia does not address the player by name in hint-state lines. Other NPCs: Mr. Pig, Mr. Murrow, Mrs. Sikorska, Mr. Swine (formal-titled); Crab, Whimsy (bare).

## comment coffee window narrowing

Per user instruction, hint_coffee_skipped is gated on chapter1.coffee_tutorial_seen == false. That bare gate would match from game start; narrowing to (court_ready && !entered_court) confines all four coffee hints to the post-readiness, pre-court window where Asia would plausibly comment on the coffee choice. Once entered_court flips, the coffee hints stop firing and hint_won_court (and below) takes over. The narrowing also keeps the coffee hints from blocking earlier progression states.
