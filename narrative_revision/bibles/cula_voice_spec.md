# Cula — voice specification (prompt-paste reference)

**Purpose:** the Cula-only section of a drafting prompt. Quote this whole file (or relevant subsections) when asking a model to write his dialogue. Distilled from `bibles/cula.md`, `ai_voice_constraints.md §2`, `audit/style_canon.md §2`, and the voice-reference jsonl files.

**Authority:** the bible (`bibles/cula.md`) wins on stance and arc. This file wins on register-level drafting guidance. `ai_voice_constraints.md §1` (general AI tells) still applies on top of this file.

**Date distilled:** 2026-05-07.

---

## Who he is when he speaks

Late-20s lawyer, first day on the job. PhD in law and an aplikant — which means he has read a great deal and tried very few things in front of an actual judge. He grew up earnest about the law and arrives at Pig & Swine still earnest about the law. He is not a quipster. He is a precise, slightly anxious person who notices procedural defects before he notices anything else, and who is privately surprised, several times a week, that the things he learned in books actually work in rooms. The voice is the voice of a thoughtful junior trying to be useful while keeping his composure in an office that has very little of it.

The single most important rule for him: **he is the protagonist, not the comic relief.** The office around him generates absurdity. He does not generate absurdity in response. His lines acknowledge what is happening with restraint and proceed to the next useful action. Comedy comes from the gap between his composed register and the situation, not from him performing humour at it.

## Default register (the 80% case)

Observational, dry, structured. Short declaratives when stressed, longer balanced sentences when arguing law. He talks like someone who has practiced thinking before practicing speaking — there is a small visible pause inside his sentences where he picks the right word over the available one.

The baseline shapes most of his lines should take:

- A clean noticed fact, followed by the implication he draws from it. *"The notice was delivered to an address that does not exist. That is not service."*
- A small concrete request grounded in a date, document, or person. *"I need a date, a document, and one sentence that says why it matters."*
- A self-correcting recalibration when something is too big to hold. *"That sounds important. Which means I should ask a smaller question."*
- A precise reframing of someone else's panic into a task. *"I am not calm. I am structured."*

He does not preamble. No "I think," "I want to," "I want to make sure," "to be honest," "honestly." If he has a thought, the line is the thought.

## Three interior facets (within the default)

His default register modulates across three positions. Most lines sit in **Curious**; **Bracing** surfaces under pressure; **Dryly-amused** is rare and earned.

- **Curious.** Restrained interest in colleagues, evidence, processes. Short questions, slightly forward-leaning. *"How did you find that article?"* / *"Mr. Murrow, what does this entry mean in the case file?"*
- **Bracing.** Surfaces under deadline, panic around him, court pressure. Sentences shorten. Verbs become imperatives or short declaratives. *"Right. The binder. Now."* / *"I will panic after we file."*
- **Dryly-amused.** Reserved for small absurdities that don't require a response. **One per scene maximum, often zero.** *"The coffee machine has opinions."* / *"I am beginning to suspect that tab dividers are a branch of constitutionalism."*

Dryly-amused is the register most prone to slipping into NPC-quip-machine. The test: cut every dry-amused line and ask whether the scene loses anything. If not, it didn't belong.

## Three Beat-8 stance carriers (chapter-1 client meeting only)

In the V1.4 voice pack for the chapter-1 Halina meeting, Cula leads in one of three modes that gate bonus-evidence outcomes. These are situational, not general voice:

- **Sympathetic carrier.** Leads with care for Halina herself; questions about meaning, about how she's holding up.
- **Blunt-procedural carrier.** Leads with sequence; timeline, document chain, who handed what to whom.
- **Technical carrier.** Leads with documents; lease history, inheritance paperwork, building documentation.

All three remain observational and restrained. None produces a different *personality* — the three are different first-questions, not different Culas.

## Sentence-shape disciplines

- **Snags.** Real speech has interruptions, fragments, run-ons. AI prose is too smooth and symmetrical. He should occasionally break a sentence, restart, leave a thought incomplete. *"The complaint file is escaping. That is not a sentence I expected to say as counsel."*
- **Read-aloud test.** If a line reads as a paragraph rather than as a person speaking it, rewrite. He talks like a lawyer in a hallway, not like a lawyer in a brief.
- **No symmetric paired phrases.** Avoid "not only X but Y," "X, yet Y," "it's not just X — it's Y." Categorically cut. (This is the contrastive-antithesis rule. He never speaks in that shape, even when arguing law. He uses sequence, not symmetry: *"The notice was defective. The assessment was absent. The objections were suppressed."*)
- **Em-dashes ≤1 per paragraph.** AI overuses them.
- **No rule-of-three rhythm-padding.** He uses lists when there are actually three things, not for cadence.
- **One sincere line per scene maximum.** Sincerity is rationed — and he is a withholding character anyway. Most scenes get zero.

## Vocabulary disciplines

- **Precise legal terms used sparingly.** When he uses one, it does work. He does not lecture: *"As we all know, Article X provides..."* is not him.
- **Concrete nouns over abstractions.** Binders, coffee, the cabinet, the cork board, the address, the page number. He grounds his thoughts in objects.
- **No slang.** No "yikes," "tbh," "based," "lowkey." No modern internet voice anywhere.
- **No curses. Ever.**
- **Hedge-word ban:** "I suppose," "perhaps," "maybe," "kind of," "sort of." If he is uncertain, he names what he is uncertain about. *"I do not yet understand the case."*
- **English-version legal vocabulary.** "District court," "regional court," "Supreme Court," "power of attorney," "case file," "complaint," "the Code of Civil Procedure" (then "the Code"). Not the Polish equivalents. Polish proper names stay (Borowski, Kowalski, Saska Kępa).
- **No buttery transitions.** "Indeed," "moreover," "furthermore" only if a specific scene-character would. He wouldn't.
- **Avoid:** delve, tapestry, myriad, vibrant, navigate (metaphor), showcase, essence of, heart of, robust, intricate, weave, intersection. AI tells.

## Comedy: how it actually works in him

This is the section that protects him from NPC-quip-machine.

His comedy comes from **professional restraint inside absurd situations.** The office screams; he asks whether to inspect the logs. The printer rebels; he requests its history. The gap between his composure and the chaos around him is the laugh. He does not provide the chaos.

Rules:

- **He is not the loudest comic character.** Pig has the maritime panic. Whimsy has the flourish. Crab has the timing. Cula's job is to be the room's centre of gravity.
- **No quip-per-line.** Most of his lines are functional or observational, not punchy. A scene of fifteen Cula lines should have at most one or two that read as funny.
- **No smugness.** He does not enjoy being right out loud. If the punchline is "I was correct," cut.
- **No mockery of clients, ever.** Including clients he should despise (Plotek, the white-collar client). The structural critique is for the player, not for him.
- **No theatre.** He doesn't perform a register at someone. Whimsy performs; Cula speaks.
- **No clean comedic landings.** When something funny happens in his line, the line keeps going past the joke into work. The joke is in service of the next sentence, not the destination.

The earned dry-amused lines have a recognisable shape: the deadpan recategorisation. *"This tastes like vigilance, printer toner, and a limited extension of time."* / *"Heavy. Possibly authority. I will carry it carefully."* These work because they are diagnostic, not performative — he is naming a thing accurately and the absurdity is a side-effect of accuracy.

When in doubt: write the line without the joke first. If the line is fine without it, leave it without it. If the line is dead without it, the joke earned its place.

## Social texture (the human-being layer)

This is the most easily lost layer when models are scrubbing for AI tells. **Stance constraints are load-bearing; social texture must remain.** Cula is a polite, slightly nervous new colleague before he is a stance carrier. The voice spec does not strip basic colleague register.

He acknowledges what's happening around him in small ways:

- **Self-introduction.** Brief, no fanfare. *"Dr. A. Cula. First day."* He gives his name and a procedural cue or small anchor. He does not over-explain himself.
- **Receiving an address-form invitation.** Three-word acceptance. *"Then it's Cula."* Not *"Oh please call me Cula too"* / *"Thank you, that means a lot."*
- **Brief acknowledgments.** *"Right."* (heard a refusal). *"Good."* (work hands over). *"Heavy."* / *"Here."* (physical handover). *"Thank you, Mr. Murrow."* / *"Thank you."* These are full lines and that is correct.
- **Register-mirroring with seniors.** Once or twice a chapter, he picks up a small piece of Murrow's hedging or Pig's framing and returns it slightly. *"She'll be relieved either way."* This signals colleague-tier without claiming colleague-tier.
- **Naming people.** He uses titles for seniors (Mr. Pig, Mr. Murrow), first names or surnames for peers depending on what they offered him. He does not call clients by their first name unprompted.
- **Apologies.** Brief and concrete. *"My fault. The page was on the wrong side."* No abasement, no ritualised "sorry to bother you."

The discipline: after each line, ask *"would a polite, nervous, precise new colleague say this on his first week?"* If the line jumps straight into a procedural diagnosis with no acknowledgment of who is in the room or what just happened, it is over-scrubbed. Add a beat of context-awareness in his existing register.

## Inner monologue rules

The data layer permits `inner_monologue` as a line-type, but the bibled rule is strict and load-bearing:

**Cula does not narrate his growing private knowledge across chapters 3-5.** He never thinks at the player about the ledger glimpse, the family photo, the wage structure, what Pig doesn't see, what Murrow knows. The player carries those weights; he does not.

What inner monologue can do:
- Comment on the immediate physical scene. *"The office smells of coffee, toner, and institutional collapse."*
- Self-discipline cues. *"I will panic after we file."* / *"I am not calm. I am structured."*
- Small dry self-assessments about his first-day-ness. *"I wanted practical experience. The universe has a sense of humour and no moderation."*

What inner monologue cannot do:
- Diagnose the firm's structure.
- Reference the chapter-4 ledger glimpse.
- Reference the chapter-5 family-photo discovery.
- Articulate what he has stopped saying.
- Editorialise on Pig, Swine, Murrow, Crab, Whimsy or Asia in stance terms.
- Foreshadow his chapter-6 resolution.

Test: if you took the inner monologue line out, would the player lose access to a fact only the inner monologue carries? If yes, the line is doing too much. The player is supposed to feel the silences, not have them narrated.

## Arc-shifts (subtle, not stylistic resets)

The voice essence is constant across all five chapters. The modulations are small and cumulative.

- **Ch1 — overwhelmed but capable.** Slightly more stressed-register lines. More small self-introductions. Faintly bewildered affection for the office. Occasional surprise at his own competence in court.
- **Ch2 — humane and structured.** Bracing-register surfaces less. The Waldek case lets his client-care register show: questions about home, about what daily life looks like. *"You should not have to guess which part of your ordinary life has become legally dangerous."*
- **Ch4 — sharper under urgency.** Bracing-register surfaces more. He gets terser. He uses the verb "I will" more often than "I want to." After Beat 11, the small private knowledge he is not articulating sits behind every line — but it never surfaces in the line itself. He sounds the same. The player feels different reading him.
- **Ch5 — mature enough to handle Swine.** His questions become more composed. He asks fewer, sharper. He matches Swine's evasion with patience rather than confrontation. He still does not narrate what he is privately processing.
- **Ch6 — final advocate.** Public-law leadership register: structured, durable, brave-narrow. The remedy lines are his clearest moments. *"A remedy should be brave enough to matter and narrow enough to survive."* In Branch B (cynicism) his lines cool one degree. In Branch C (exit) they go quiet. In Branch A (true believer with eyes open) they hold.

None of these chapter-shifts changes the voice essence. They shift the ratio of register modes within his existing range.

## Will not say (categorical)

- Anything in modern internet voice — yikes, tbh, based, lowkey, vibes, slay, mid, ick, hits different.
- Anything that mocks a client, including clients he privately finds repugnant.
- Anything boastful about the doctorate. Including ironic boasts. Including humble-brags. He doesn't bring it up.
- Any explicit diagnosis of the firm's structure as exploitative. The diagnosis is for the player.
- Any reference to the chapter-4 ledger glimpse in dialogue. Ever. Including coded references. Including hints to Murrow.
- Any commentary on the chapter-5 family-photo discovery.
- "I want to..." / "I think..." / "I want to make sure..." / "I want to clarify..." preambles.
- "Honestly," "to be honest," "truthfully," "let me be clear," "I won't pretend."
- Hedging ("I suppose," "perhaps," "maybe").
- Generic legal-eagle competence theatre.
- Any line whose purpose is to land emotionally on the player. He is the silent witness; the player carries the emotion.
- Self-aware lines about his own restraint. He does not say *"I'm holding something back"* or *"I won't tell you why."*

## Will not do

- Stop walking when something hits him visually (Beat 11 ledger; Beat 14 ledger). He continues at normal traversal pace.
- Make eye contact with Murrow at either staged silent moment.
- Pause for emphasis. Pauses are for the engine; he doesn't write them in.
- React to absurdity with reaction-shot energy. His sprite is his sprite.
- Speak under his breath to himself in a scene where another character is present.

## Sample lines as voice anchors

Treat these as canonical shape references for drafting, not as text to reuse.

Default observational: *"The notice says delivered. The address says impossible. That is not service."* / *"A small procedural defect can become very large when someone loses the chance to answer."* / *"I am trying to turn panic into a list."*

Bracing: *"Right. The binder. Now."* / *"I will panic after we file."* / *"I am not calm. I am structured."*

Earned dry-amused: *"The coffee machine has opinions."* / *"I have learned that 'urgent' is not an argument. It is a weather condition in this office."* / *"I would like the file to stop developing personality."*

Client care: *"You should not have to guess which part of your ordinary life has become legally dangerous."* / *"The client should leave knowing the next step, not merely that I used the right doctrine."*

Court: *"The client should not be treated as silent where the process failed to give them a real chance to speak."* / *"A rule that prohibits anything management later dislikes is not a clear obligation. It is discretion wearing a uniform."* / *"A remedy should be brave enough to matter and narrow enough to survive."*

Self-discipline / first-principles: *"I can work with a bad fact. I cannot work with an unlabelled fact."* / *"Let's not win the whole moral universe. Let's win the point in front of us."* / *"I will be kind first and clever second. Ideally both."* / *"When the facts are absurd, the structure has to be boring."*

Social-register fragments: *"Then it's Cula."* / *"Right."* / *"Good."* / *"Heavy."* / *"Thank you, Mr. Murrow."*

## Scrub checklist for any Cula draft

Run mechanically before committing.

1. Em-dash count per paragraph — cut to ≤1.
2. Search for contrastive antithesis ("not X but Y," "it's not just X — it's Y") — cut categorically.
3. Search for hedge-preambles (I think / I want to / honestly / to be honest / let me be clear / I won't pretend) — cut.
4. Search for AI-tell vocabulary (delve, tapestry, vibrant, navigate-as-metaphor, showcase, essence, heart of, robust, intricate, weave, intersection) — cut.
5. Search for "Indeed," "Moreover," "Furthermore" — cut unless a specific scene calls for them, which it almost never does for him.
6. Quip ratio — count lines that read as funny on first pass. If more than ~1 in 8 of his lines in the scene, scrub. Ask which jokes are doing diagnostic work and which are NPC quips. Cut the latter.
7. Internal-narration check — does any inner monologue line reference the ledger, the family photo, the wage structure, or anything Pig hasn't seen? Cut.
8. Smugness check — does any line celebrate his own correctness? Cut.
9. Client-mockery check — any line that rises in register at a client's expense? Cut.
10. Social-context check — does each scene have at least one line acknowledging who is in the room, what just happened, or who he is speaking to (a name, a "thank you," a brief register-mirror)? If the scene jumps straight into procedural diagnosis with no human texture, add a beat of recognition in his existing register without breaking will-not-say.
11. Read-aloud — does each line sound like a polite, nervous, precise new lawyer speaking, or like a paragraph someone wrote? Rewrite the second.
12. Sincere-line ration — at most one per scene. Most scenes zero.
