# meeting_room_stance — dialogue authoring notes

Companion to `meeting_room_stance.json`. Authoring metadata extracted
from the JSON in Phase 3 of the schema-cohesion refactor; the
runtime never read these blocks, only authors did.

## Provenance

Chapter 1 Phase B polish — replaces the standalone client_stance_menu.tscn modal with an in-dialogue option pick. The dialogue box renders the three choices under the prompt; the player picks with move_up/move_down + interact. Selected option renders in red (per dialogue_box.gd OPTION_COLOR_SELECTED).

## Scope

Fires when Cula approaches the meeting-room threshold for Beat 8 and client_meeting_stance is empty. Three choices write chapter1.client_meeting_stance to 'sympathetic', 'blunt_procedural', or 'technical'. Button wording follows V1.4 pack §B.1 in Cula's register (see bibles/cula.md interior-register-range).
