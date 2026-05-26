# Voice spec — `smokers_lawyer_ch1`

Status: **DRAFT, pending Piotr acceptance.**
Authored: 2026-05-24, nightly-design proposal execution.
Owner of acceptance: Piotr.

This document is the voice-spec request artifact required by
`godot/.antigravity/skills/design.md` §Halt conditions before any dialogue
lines may be authored for the `smokers_lawyer_ch1` NPC.

## Why this artifact exists

The 2026-05-18 Pixellab street-pack sprints placed a `smokers_lawyer_ch1`
Area2D + AnimatedSprite2D in `godot/scenes/world/routes/office_street.tscn`
(line 314). Per the 2026-05-18 SPRINT_LOG entry, the NPC was flagged for a
Design follow-up: *"NPC dialogue stubs NOT authored — `npc_id` fields ...
reference `data/dialogues/<npc_id>.json` files that do not yet exist;
`npc.gd` will route to DialogueRunner which logs a warning when interacted
with."*

The follow-up never happened, because Design's halt condition forbids
authoring lines for an NPC whose voice is not established in `story.txt`,
`style_canon.txt`, or `data/voice_references/`. `smokers_lawyer_ch1` is
not named in any of those. The character is implicit in Art's brief
(`godot/art/_pixellab_street_pack_02.md §D1 Smoking junior lawyer`) and
visible in the scene; the *voice* is undefined.

This spec is the missing voice-spec request. Once Piotr accepts (or
revises), `data/dialogues/smokers_lawyer_ch1.json` can be filled with
authored lines and the stub (`_voice_spec_pending: true`) flag removed.

## Character

A junior lawyer at one of the corporate towers further east, or at a
competing firm on Counsel Row. **NOT Pig & Swine staff** — the firm is
a known quantity to the player by the time they meet him; an external
register is more useful as texture and avoids confusion with the recurring
cast.

He smokes on this corner because the legal quarter's smoking-tolerated
spots are a real Warsaw-bar texture detail — most court buildings post
no-smoking on the steps; benches on the sidewalk one block away
accumulate junior lawyers between hearings. The corner outside Pig &
Swine is one such spot.

He is not quest-critical. He does not block routes. He is not a
recruitable advocate. He does not return in any later chapter (the
character does *not* survive review for Chapter 2+ — Cula has seen
hundreds of him).

## Register

- **Dry. Tired. Slightly contemptuous of his own job.** Not hostile to
  Cula; willing to acknowledge a peer.
- **One legal-shop-talk reference per line** is the rhythm. Real KPC
  citation if it fits; a procedural-noun observation otherwise. *Not*
  doctrinal lecture; just the way overheard junior lawyers actually
  talk.
- **Not theatrical** — that lane is Whimsy's. Where Whimsy turns law
  into rhetoric, this character treats law as the day job that's running
  late.
- **Not archival-precise** — that lane is Murrow's. He doesn't have
  Murrow's command of the file; he's three years out of the bar exam
  and the file is whatever's in his briefcase.
- **No moralizing.** He does not editorialize on Pig & Swine, on Polish
  legal practice generally, or on Cula. He has opinions; he keeps them.
- **Inspirations push:** call it "junior-Murrow before the precision is
  earned" — same observational rhythm, same short declarative cadence,
  but without the archival certainty. The Mrożek dryness is in scope;
  the Kundera essayist gravitas is not. Compare to Hrabal's tired-
  observational voice (the corner-shop philosopher who is right four
  times in five) — though dialed down: this character is not a
  philosopher; he's a tired second-year associate.

## Address forms

- **Toward Cula:** *"Cula"* on professional recognition (the Polish-
  legal-quarter small-world register where everyone has heard of
  everyone), or *"counsel"* before Cula has named himself. **Not** *"Dr.
  A. Cula"* — that register belongs to the firm and the client. **Not**
  *"Doctor Cula"* — non-canonical per AGENTS.md.
- **Toward Pig & Swine:** the firm's full name *"Pig & Swine"* on first
  reference, then *"Pig & Swine"* again (no nickname; junior lawyers
  who think they're cool give firms nicknames, but this character
  isn't trying).
- **Toward Mr. Pig / Murrow / Crab / Whimsy:** by surname with no
  honorific (*"Pig"*, *"Murrow"*) — the small-world Polish-bar
  register acknowledges them without bowing. If the line needs more
  formal weight, drop to surname-only (*"Murrow has the file."*).

## First-meeting carve-out

Per AGENTS.md §First-meeting introductions, transactional NPCs do not
require a name-exchange first-meeting beat. **This character is
transactional in the same sense as the barista** — the interaction is
sidewalk texture, not a personal-introduction social moment. If Cula
volunteers his name, the character acknowledges it; he does not require
it.

## Forbidden

- Reference to any real Polish firm (per AGENTS.md §Humor rules: "Real
  people forbidden. Invent fictional analogues.").
- Any malicious intent toward Cula or Pig & Swine (per AGENTS.md
  §Forbidden patterns).
- Sex/scatological jokes; slurs; modern internet voice.
- Any recruitment-pitch hook — he is *not* on the recruitable-advocate
  table.
- Any "back in my day" content — that's Pig's lane.
- Any maritime metaphor — that's Pig's lane.

## Out of scope

- A Chapter 2+ return. He is a sidewalk fixture, not a recurring
  character.
- A mechanical interaction (no flags set; no inventory; no recruitment
  branch).
- A personal-name reveal. He stays "smoking junior lawyer" in the
  display_name field. (If a name is ever needed for a later beat, that's
  a separate voice-spec extension.)

## Recommended scope for v1 lines

Once accepted, the stub `data/dialogues/smokers_lawyer_ch1.json` is
authored as:

- **One first-approach state.** Two short lines. Either: (a) he registers
  Cula as a peer with one observation about the day, or (b) he registers
  Cula as new (the small-world bar gossip travels) with one observation
  about Pig & Swine. Lead Piotr toward option (a) — gossip in a junior-
  lawyer voice would risk punching down at Pig & Swine, and the firm's
  external reputation should land via the resort-tier joke in Chapter 4,
  not on Beat 1.
- **One repeat / ambient state.** One short line. A second observation
  about the day, the corner, or his next hearing. Nothing that advances
  state.
- **One idle_flavor line.** Optional. Short. Same register.

Total budget: 4 lines. All must pass the Taste Standard (5/5).

## Acceptance prompt for Piotr

Reject, accept, or revise. If accept, the next nightly can author the
four-line v1 content into `data/dialogues/smokers_lawyer_ch1.json` and
flip `_voice_spec_pending: false`.

If reject: the sprite stays on the street as a non-speaking visual
element; the stub line (a stage-direction observation) continues to
silence the runtime warning without committing to a register.
