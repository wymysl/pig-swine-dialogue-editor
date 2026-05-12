# V1.A Pass 3 — Asia hint-state branches (chapter 1) — commit shape

**Pack:** `narrative_revision/phase_7_packs/V1.A_asia_hint_states.md`
**Date drafted:** 2026-05-09
**Speaking characters:** Asia (sole speaker; hint-NPC repeat-line surface).
**Status:** Pass 3 — applies in-house arbitration of pass 2's hostile critique against pass 1. **Commit shape — no text changes from pass 1.**

**Pass-2 critique disposition.**

The pass-2 critique returned **0 critical failures, 4 marginals, recommendation: commit**. The critic respected the pack's pre-arbitrations on states 1 and 11; applied risk-weighted scrutiny to the new states 7 and 8; ran a clean diff against `_legacy/dialogue_samples.txt §Sign and notice text samples` lines 50–59 confirming verbatim hold for all 10 legacy lines.

Pass-2 marginals all held as defensible (4):

1. **State 1 — *"loudest crisis in the room"*** held per pack §B.1 explicit approval. The line is the closest approach to the no-Pig-panic-editorial boundary; pack pre-arbitrates as room-class observation rather than pattern-diagnosis. Critic accepts.
2. **State 7 — *"She brought her own folder"*** held. Critic argues against the pass-1 alternate *"She's been waiting twenty minutes"* on the grounds that *"making this line funnier would risk disrespecting the client beat before Beat 8 can carry it"* — sharper reasoning than pass-1 self-check; arbitration log records the rejection of the alternate.
3. **State 8 — *"disappointed-page-turn sound"*** held per pack §B.1 explicit approval. Critic notes the repeatability risk (compound joke wears faster than plain location-only line) and offers fallback. Hold the verbose form: pack §B.1 explicitly requires the characteristic Murrow detail, and Asia's voice has a baseline joke-density level that hint lines must maintain. The repeatability risk is a feature of chapter pacing (player who lingers gets to hear Asia twice), not a bug in the line.
4. **State 11 — *"expensive and irresponsible"*** held per pack §B.1 explicit approval. Critic confirms the coordinate-adjective pair lands grammatically on the stamp (an object), not on Mr. Swine's pattern.

Pass-2 cross-sequence observation noted as feature (not failure):

5. **States 8 and 9 both use Murrow-recognition shapes** (*"disappointed-page-turn sound"* / *"special face for missing documents"*). Critic flagged but dismissed as not-a-failure because the gates are sequential. Going further: the parallel is **load-bearing, not coincidental**. Asia's recognition-of-Murrow as an operational pattern is exactly the quiet awareness her bible Preamble describes; consecutive states using Murrow-recognition shapes reinforce that she watches him through the day rather than diagnosing him in any one moment. Hold both.

**No text changes from pass 1.** The 12 lines below are the commit shape. Pass-3 changes are limited to (a) this arbitration log header, (b) the final self-check, and (c) the commit candidates with finalised JSONL metadata.

---

## State 1 — `!chapter1.pig_revealed_crisis`

**Trigger:** player has just entered the office; Pig has not yet delivered his Beat-2 panic line.
**Line:**

> You should talk to Mr. Pig first. He's the loudest crisis in the room.

Verbatim from `_legacy/dialogue_samples.txt §Sign and notice text samples` line 50.

---

## State 2 — `!chapter1.met_murrow`

**Trigger:** Pig crisis revealed; Murrow not yet met (Beat 3 not entered).
**Line:**

> Mr. Murrow will know what the case is actually about. He's somewhere between the files and disappointment.

Verbatim from legacy line 51.

---

## State 3 — `!chapter1.has_law_binder`

**Trigger:** Murrow met; player has not yet collected the procedural binder from the archive.
**Line:**

> You're looking for the procedural binder. I tried lifting it once and briefly saw another dimension.

Verbatim from legacy line 52.

---

## State 4 — `!chapter1.recruited_crab`

**Trigger:** binder collected; Crab not yet recruited (Beat 5 not entered).
**Line:**

> If it's a service problem, Crab will have an opinion. He always has an opinion.

Verbatim from legacy line 53.

---

## State 5 — `!chapter1.has_rights_memo`

**Trigger:** Crab recruited; Rights Memo not yet collected.
**Line:**

> The rights memo may be near Whimsy. Try Café Paragraf — or wherever someone is talking too loudly about fairness.

Verbatim from legacy line 54. Single canonical sanctioned em-dash.

---

## State 6 — `!chapter1.recruited_whimsy`

**Trigger:** Rights Memo collected; Whimsy not yet recruited (Beat 7 not entered).
**Line:**

> Whimsy is useful if pointed at the right legal issue. Try asking him about fair hearing.

Verbatim from legacy line 55.

---

## State 7 — `!chapter1.halina_met` (PHASE-8 ADDITION)

**Trigger:** Whimsy recruited; Halina has arrived at the office for Beat 8 client meeting; player has not yet entered the meeting room.
**Line:**

> Mrs. Sikorska is in the meeting room. She brought her own folder.

Authored from §B.1 recommended sample shape. No editorial on Halina's manner or case; operational detail (folder).

---

## State 8 — `!chapter1.archive_research_complete` (PHASE-8 ADDITION)

**Trigger:** Beat 8 client meeting concluded; Murrow has gone to the archive with the binder and the case folder for Beat 9 research; player has not yet followed.
**Line:**

> Mr. Murrow is in the archive with the binder. He's been making the disappointed-page-turn sound.

Authored from §B.1 recommended sample shape. Operational sound-recognition (not psychological diagnosis); pack-explicit-approved characteristic Murrow detail.

---

## State 9 — `!chapter1.court_ready`

**Trigger:** archive research complete; Beat 10 readiness check not yet completed.
**Line:**

> Mr. Murrow should check the case before court. He has a special face for missing documents.

Verbatim from legacy line 56.

---

## State 10 — `!chapter1.won_court`

**Trigger:** readiness check passed; team has not yet walked to the District Court.
**Line:**

> If Mr. Murrow says you're ready, go north to the District Court. And maybe drink water.

Verbatim from legacy line 57.

---

## State 11 — `!chapter1.received_swine_postcard`

**Trigger:** court won; Beat-14 Swine postcard has not yet arrived.
**Line:**

> Something arrived from Mr. Swine. The stamp looks expensive and irresponsible.

Verbatim from legacy line 58.

---

## State 12 — Default (post-postcard; chapter close)

**Trigger:** all chapter-1 flags satisfied; chapter winding down before chapter-2 transition.
**Line:**

> For the first time today, nothing is actively on fire. I give it twelve minutes.

Verbatim from legacy line 59.

---

## Self-check (pass 3 — final)

### Discipline checks (final)

- **§A em-dash count.** Total dialogue em-dashes across 12 lines: 1. State 5's *"Try Café Paragraf — or wherever..."* is the canonical sanctioned slot. All other 11 lines: zero. Within the per-line ≤1 rule.
- **§A contrastive antithesis.** None.
- **§A banned vocabulary.** None.
- **§A symmetric paired phrases.** None. State 11's *"expensive and irresponsible"* is a coordinate-adjective pair on a single noun, not symmetric clause-pairing.
- **§A generic uplifting endings.** None. State 12's *"I give it twelve minutes"* is exhaustion-with-cheerful-tone, not uplift.
- **§A pet-name register.** None.
- **§A exclamation marks.** None across all 12 lines.
- **§A.5 language convention.** No Polish in dialogue except proper names: Café Paragraf (state 5; proper place name).
- **§A.6 social context.** Hint-NPC register held across all 12. Address-form for Cula not used (room-shaped). Address-forms for other NPCs: formal title for Pig, Murrow, Sikorska, Swine; canonical bare for Crab, Whimsy.
- **Sincere-line ration.** No sincere break. All 12 lines stay in cheerful-while-drowning baseline. Asia's single canonical sharp moment (chapter-3 STUB-decline) is reserved.
- **STUB-decline reservation.** No line uses *"front-desk staff have negotiating power"* / *"password to the photocopier"* / any sibling phrasing. Chapter-3 H5 commit shape protected.
- **Other reserved phrasings.** Chapter-2 Waldek warmth not pre-empted; chapter-4 Bajtek call not pre-empted; chapter-5 backup-copy line not pre-empted; chapter-6 brief-index not pre-empted.

### Per-state verification (final)

- **States 1–6 and 9–12 (10 lines):** verbatim from `_legacy/dialogue_samples.txt §Sign and notice text samples` lines 50–59. Each confirmed against §A and §B.1 by pass 1; verbatim-hold confirmed by pass-2 diff check.
- **State 7 (1 new line):** authored from §B.1 recommended sample shape. Two short sentences; formal name; operational detail; no editorial.
- **State 8 (1 new line):** authored from §B.1 recommended sample shape. Two short sentences; formal name; operational sound-recognition; pack-explicit-approved characteristic detail.

### Pattern checks (final)

- **Cheerful-while-drowning register held across 12 lines.** No sharpening; no legal opinion; no editorial on Pig's panic.
- **Domestic-administrative vocabulary anchors.** Each line lands at least one practical noun.
- **Snag-by-trail rhythm preserved.** No symmetric two-clause structures; rhythm varies across the 12 lines.
- **Repeatability test.** Each line bears at least three reads without grating. State 8's compound joke (*"disappointed-page-turn sound"*) wears slightly faster than plain location lines but holds within acceptable range; pack-mandated characteristic Murrow detail outweighs.
- **Hint-direction clarity.** Each line points the player toward the next quest gate without spoiling.
- **Murrow-recognition pattern (states 8 and 9).** Two consecutive Murrow-recognition shapes (*"disappointed-page-turn sound"* / *"special face for missing documents"*) reinforce Asia's quiet-awareness discipline rather than redundancy. Load-bearing for the bible's Preamble (sees-everything-participates-warmly).

---

## Commit candidates (final — JSONL appends)

**`data/voice_references/dialogue_samples_asia.jsonl` (append — 12 hint-state lines)**

Each record uses the existing schema (`record_type`, `id`, `character_id`, `speaker`, `chapter`, `scene`, `context`, `line_type`, `expression`, `tags`, `text`, `notes`). Convention:

- `record_type`: `dialogue_sample`
- `id`: `asia_ch01_v1_a_p3_hint_state_<flag-name>_001`
- `character_id`: `asia`
- `speaker`: `Asia`
- `chapter`: `ch01`
- `scene`: `pig_swine_office`
- `context`: brief description naming trigger and hint direction
- `line_type`: `hint_state`
- `expression`: `cheerful_tired`
- `tags`: `["phase7_v1_a_p3", "hint_state", "<flag_name>", ...]`
- `text`: the line verbatim
- `notes`: `"Phase 7 V1.A pass 3 commit shape; hint-NPC repeat line; verbatim from legacy" | "Phase 7 V1.A pass 3 commit shape; hint-NPC repeat line; phase-8 new line; not final."`

The 12 lines:

1. State 1 — flag `pig_revealed_crisis`: *"You should talk to Mr. Pig first. He's the loudest crisis in the room."*
2. State 2 — flag `met_murrow`: *"Mr. Murrow will know what the case is actually about. He's somewhere between the files and disappointment."*
3. State 3 — flag `has_law_binder`: *"You're looking for the procedural binder. I tried lifting it once and briefly saw another dimension."*
4. State 4 — flag `recruited_crab`: *"If it's a service problem, Crab will have an opinion. He always has an opinion."*
5. State 5 — flag `has_rights_memo`: *"The rights memo may be near Whimsy. Try Café Paragraf — or wherever someone is talking too loudly about fairness."*
6. State 6 — flag `recruited_whimsy`: *"Whimsy is useful if pointed at the right legal issue. Try asking him about fair hearing."*
7. State 7 — flag `halina_met` (NEW): *"Mrs. Sikorska is in the meeting room. She brought her own folder."*
8. State 8 — flag `archive_research_complete` (NEW): *"Mr. Murrow is in the archive with the binder. He's been making the disappointed-page-turn sound."*
9. State 9 — flag `court_ready`: *"Mr. Murrow should check the case before court. He has a special face for missing documents."*
10. State 10 — flag `won_court`: *"If Mr. Murrow says you're ready, go north to the District Court. And maybe drink water."*
11. State 11 — flag `received_swine_postcard`: *"Something arrived from Mr. Swine. The stamp looks expensive and irresponsible."*
12. State 12 — default (post-postcard): *"For the first time today, nothing is actively on fire. I give it twelve minutes."*

**`data/dialogues/asia_hint_states_ch1.json` (NEW; optional)**

Pseudo-logic mapping flag → line for the implementation's `get_asia_hint()` call. Schema-match `judge_district_ch1.json`. Encodes the priority-ordered first-unmet-flag-wins logic from `story.txt` lines 1245–1288.

---

## Manifest update (per pack §M)

`narrative_revision/phase_7_packs/00_pack_manifest.md`:

1. V1.A row in Chapter 1 table: status ⏸ → ✅.
2. Pack index: `⏸ **V1.A** — Asia hint states` → `✅ **V1.A** — Asia hint states`.
3. No further renumber required. No bible / audit / beat-sheet edits required.
4. Chapter-1 vertical pack work concludes fully on V1.A commit. Chapter 2 begins with V2.1.

After commit: run `tools/voice_audit.py`. Resolve any flags.
