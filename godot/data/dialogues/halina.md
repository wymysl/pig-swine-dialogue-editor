# halina — dialogue authoring notes

Companion to `halina.json`. Authoring metadata extracted
from the JSON in Phase 3 of the schema-cohesion refactor; the
runtime never read these blocks, only authors did.

## Provenance

V1.4 phase-7 voice pack (V1.4_halina_meeting_research.md). Source draft: narrative_revision/phase_7_drafts/V1_4_draft_pass4.md (pass 4 with five §J review passes baked in).

## Scope

halina.json owns the Beat 8 client meeting in Cula's Ch1. The carrier states are gated on chapter1.client_meeting_stance ('sympathetic' / 'blunt_procedural' / 'technical'), set during Beat 7 when the player picks Cula's interview tone. Each carrier state runs the full meeting flow: opening (Asia announce + entry + greetings + Murrow opening) → carrier-specific dialogue (stance question + Halina responses + bonus evidence + register reactions) → shared content (required-evidence reconciliation + fee + Pig intrusion + epigram + close). Stage directions from the draft are NOT carried into this file (engine pattern; see murrow.json first_meeting). Chapter-4 corridor sighting is out of scope for this file (Ch4 voice pack).
