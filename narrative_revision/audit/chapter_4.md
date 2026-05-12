# Audit — Chapter 4: "The Printer Conspiracy"

**Source:** `story.txt` lines 2650-3901
**Date:** 2026-05-05
**Auditor:** narrative_revision phase 2
**Tag legend:** (K) keep · (R) reframe · (C) cut · (?) uncertain

**Summary tally**
- K: ~85% of beats
- R: ~13% (the chapter-4 inflection beat addition; Crab/Whimsy stance alignment in contradiction scenes; Mr. Pig's specific financial-fear callbacks)
- C: 0
- ?: 2% (one structural choice flagged for phase-4 decision)

**This is the most important chapter for the spine.** The mid-game inflection lives here — in Beat 11 specifically, immediately before the STUB/PUTKA founding. The existing material already creates the conditions for the inflection (Mr. Pig's "maritime crisis about toner costs," Murrow's ledger, the juniors comparing notes during the union founding) without explicitly staging the player's realization. Phase 4 work must add the inflection as a specific beat in Beat 11 without weakening Beat 11.5.

**Key structural finding:** STUB/PUTKA's founding is *already* perfectly calibrated for the spine. The canon language — "comic-deflationary, not historically grand," "do not over-mine the joke," "Murrow finds the napkin and files it under 'personal effects, see also: morale' without comment" — is precisely the union-as-necessary-and-ridiculous tone the spine wants. **Do not strengthen the union founding.** The temptation will be to give it more weight; the canon's restraint is what makes it land.

---

## Opening framing (lines 2650-2687)

- (K) **"Chapter 4 is the systems chapter."** Mechanics focus: contradiction spotting, technical investigation, deadline pressure, adversarial cross-examination.
- (K) **"No random failure. No hard fail for the scooter race. No contradiction should require guessing. Every contradiction must be preceded by a clearly collected evidence item."** Soft-fail discipline locked.
- (K) Business District + Print Shop + Pig & Swine Basement unlock. Spatial expansion.
- (K) **"Chapter 1 and Chapter 2 made the city expand toward people and homes. Chapter 4 expands east, toward business, glass, machinery, and rival firms."** Tonal shift — the chapter introduces *external threat* (rival firm) which is necessary thematic counterweight to the *internal threat* (the union founding). Both threats exist; both are real.

---

## Beat 0 — Immediate continuation from Chapter 3 (lines 2690-2725; phase-8 update)

**(Phase-8 transitional update.)** Pre-phase-8, Chapter 4 (then Ch3) followed Chapter 2 directly via the printer-stinger embedded in Ch2's tail. After phase-8, the printer-stinger has been relocated to the end of Chapter 3 (the new compact criminal chapter — Kacper's case), so Chapter 4 now follows Chapter 3 directly. The Beat 0 trigger is `chapter3.complete == true and chapter4.started == false` (was `chapter2.complete == true`). Story.txt's Beat 0 specification was updated in Stage 13; this audit references the new transition. The printer-stinger content itself is unchanged — only its host chapter shifted.

- (K) Direct continuation from chapter-2 stinger. Mr. Pig freezes; Crab and Murrow react.
- (K) Initial flags. Asia line.

---

## Beat 1 — The printer screams (lines 2729-2768)

- (K) Player begins in office. Printer produces ominous pages without speaking.
- (K) Five-character reaction set (Pig / Murrow / Crab / Whimsy / Asia). Phase 7 voice-reference work aligns Crab/Whimsy to pinned stances.
- (K) Evidence collection (deadline_notice, misprinted_filing).
- (K) **Deadline Notice description:** "A court notice confirming an urgent filing deadline. The kind of paper that looks harmless until it destroys your week." Bureaucratic-absurd at peak.
- (K) Murrow points toward Bajtek.

---

## Beat 2 — Call Sysadmin Bajtek (lines 2771-2801)

- (K) Bajtek introduction as technical guide.
- (K) Voice rules per style_canon §2 (competent, tired, terse, allergic to mysticism). **Outside the firm-internal-politics locus** — Bajtek is a sympathetic outside expert who works with the firm but isn't of it. Important: this gives Cula a non-firm relationship that carries through the chapter, modeling for the player that competence-without-investment is possible.

---

## Beat 3 — Pig & Swine Server Room (lines 2804-2845)

- (K) Spatial introduction. Visual identity.
- (K) **Printer Log Fragment:** "Shows print jobs being redirected at impossible hours. The printer may be innocent, which is devastating for office morale." Funny-on-first-read; the printer-as-character arc continues.
- (K) Backup Drive: "It contains fewer screams than expected and more timestamps than anyone wanted." Bureaucratic-absurd.

---

## Beat 4 — Contradiction Spotting tutorial (lines 2848-2900)

- (K) Mechanical introduction. Cooperative tutorial with Bajtek before adversarial use against Szpon.
- (K) Contradiction-scene data structure (statement IDs, contradiction_evidence, success_flag). Mechanically clean.
- (K) "The logs are the least emotional witness in the room." Bajtek voice locked.

---

## Beat 5 — Business District unlocks (lines 2903-2920)

- (K) Spatial expansion. Corporate lawyer / courier / print-shop worker NPCs add district texture.

---

## Beat 6 — Print Shop investigation (lines 2923-2956)

- (K) External confirmation. Repair Invoice and Ink Batch Label as evidence.
- (K) **Ink Batch Label description:** "The same ink batch appears on Pig & Swine's suspicious replacement paper. Not conclusive, but the paper trail is starting to sweat." Excellent.

---

## Beat 7 — Advocate Szpon appears (lines 2959-2978)

- (K) Antagonist introduction. Style_canon §2 voice rules apply ("elegant, predatory, over-controlled. Never raises voice. Lies carefully").
- (K) **Szpon as outside antagonist** — important for the spine. The chapter has *two* antagonists: Szpon (external) and the wage-suppression structure (internal). Szpon is unambiguously bad; the structure is the half-right thing the chapter is starting to surface. Both are present. Neither cancels the other.

---

## Beat 8 — First hostile contradiction: Szpon at Print Shop (lines 2981-3037)

- (K) Contradiction scene structure. Four statement options, one with `repair_invoice` as the contradiction key.
- (K) Mechanical victory flags.
- (R) Crab and Whimsy support lines (in [Court line samples]) — phase 7 stance alignment. Crab catches the lie because professional precision is his function (opportunist, leverage-aware); Whimsy's flourish is bitter accuracy theatricalized (cynic).

---

## Beat 9 — Return to Pig & Swine / unlock Basement (lines 3040-3066)

- (K) Evidence combination. Bajtek/Murrow/Crab/Mr. Pig/Asia/Whimsy reaction set.
- (R) **Mr. Pig's reaction line** (in [Court line samples]) — phase 7 should specify the framing. The basement-unlock moment is potentially a recoloring seed: Mr. Pig is reluctant to go to the basement (style_canon §3 doesn't dwell on this, but a man with something to hide would be reluctant). The reluctance can be played as comic anxiety on first read; on chapter-5 retraversal, it can read as something else. Phase 4 beat sheet should specify whether and how to plant this.

---

## Beat 10 — Pig & Swine Basement (lines 3069-3135)

- (K) Investigation climax. Visual identity, environmental jokes.
- (K) **Hidden Reroute Device description:** "A small device redirecting print jobs. It has one blinking light and the moral character of a tax haven." Excellent — passes the Taste Standard.
- (K) Optional evidence (Rival Firm Leaflet, Backup Printer Photo).
- (K) Basement reveal scene with the full team.
- (?) **Open question for phase 4:** does the basement contain anything OTHER than the reroute device that supports the chapter-4 inflection? The basement is a private firm space; if it contains, say, an old financial document, an unfiled retainer, or a stack of unopened bills that contradicts Mr. Pig's "we're broke" framing, the inflection could happen here naturally as Cula investigates. **Recommendation:** flag for phase 4 — do *not* add a discovery here that competes with the urgent-filing inflection (Beat 11), but consider whether a small *plant* (a single document or sight) here pre-loads the inflection. Conservative answer: leave Beat 10 clean; let the inflection live in Beat 11.

---

## Beat 11 — Urgent filing preparation (lines 3138-3161) — INFLECTION CANDIDATE

- (R) **THE CHAPTER-3 INFLECTION SHOULD LIVE HERE.** The existing canon describes the scene briefly: "Murrow has stepped out to find a stamp, Asia is on the phone, Mr. Pig is in the corner having a maritime crisis about toner costs." This is the moment to insert a quiet, specific beat in which **Cula sees something that punctures the firm's "we're broke" framing**.

The inflection beat should be:
- **Quiet.** No revelation cutscene. No music sting. A small thing Cula notices.
- **Specific.** A concrete document, number, or object — not a vague feeling. Something the player can later cite when they think back.
- **Ambiguous on first read.** Cula sees it, registers it as odd, then is interrupted by the urgency of the filing. The player carries the unresolved question into chapter 5.
- **Witness-shaped, not investigation-shaped.** The discovery should not feel like Cula "finding evidence." It should feel like *seeing something that wasn't hidden*.

**Two candidate forms (decide in phase 4):**

  A) **The ledger glimpse.** Murrow's ledger is open on the desk while he's gone to find a stamp. Cula glances at it (not investigating — just present). What's there contradicts something Mr. Pig has just said in his maritime crisis. E.g., a recent retainer payment that came in two weeks ago, a healthy reserve line, a paid-up account that Pig is currently performing panic about. Cula doesn't flag it; the urgency of the filing pulls focus. The player carries the moment.

  B) **The toner receipt.** Mr. Pig's "maritime crisis about toner costs" is the existing canon line. The candidate plant: Cula passes the supply cabinet and notices it's well-stocked with toner that was just delivered. Or sees the receipt for a recent bulk order. Mr. Pig's panic is genuine *as panic* but disconnected from the actual material situation — exactly the half-right portrait.

I prefer (A). Murrow as the in-world witness to the firm's actual financial state has been canonical since chapter 1; making him the inadvertent enabler of the inflection (he steps out, the ledger stays) sits well with his archival omniscience. (B) works but is more confrontational because it implicates Mr. Pig directly. (A) lets Mr. Pig's blind spot stay a blind spot — Cula sees structure, not malice.

- (K) Beat 11's existing seven-character reaction set survives. Phase 7 will flesh out individual lines.

---

## Beat 11.5 — STUB is founded (lines 3162-3180)

- (K) **Do not change.** This beat is already calibrated for the spine. The canon language is exemplary:
  - "they are doing all the actual lawyering, on no sleep, with the firm's printer literally being sabotaged by a rival, and the only payment so far this month has been a postcard from Mr. Swine" — material conditions stated plainly, not editorialized.
  - "Murrow is not invited; he is the institutional spine and would file for management if asked." — labor-relations marker that fits archival omniscience.
  - "Asia is offered membership and declines on grounds that 'front-desk staff have negotiating power that lawyers cannot match — I have the password to the photocopier.'" — deflationary, sharp, and actually correct about workplace dynamics.
  - "Murrow finds the napkin in Beat 15 and files it under 'personal effects, see also: morale' without comment." — funny-in-hindsight in plain sight; "morale" is the honest word.
  - "Do not over-mine the joke. Two or three callbacks across the rest of the game; not a recurring punchline." — the discipline that protects against the union becoming the answer.

This beat is the canonical embodiment of "necessary AND ridiculous." Phase 7 work should preserve every beat of this prose; voice references should align Crab and Whimsy's specific lines to their pinned stances, but the *shape* of the scene is locked.

**Critical note:** the inflection beat (proposed addition to Beat 11) and the STUB founding (Beat 11.5) must remain *independent* in the player's experience. The inflection is something Cula sees and shelves under urgency; the STUB founding happens because the juniors are tired and unpaid this month, not because of what Cula glimpsed. Player makes the connection retrospectively in chapter 5. **The two beats must not feel causally linked in chapter 4.**

---

## Beat 12 — Scooter Racing: Deadline Dash (lines 3183-3265)

**Note**: per `PLAN.md` and Proposal #3, Scooter Racing is **deferred** as a mini-game and reframed as a brief urgency cutscene. This audit treats it as the cutscene it is becoming.

- (K) The narrative function of the dash (urgency set piece, deadline real, three outcome tiers).
- (K) Three outcome tiers (clean / messy / failed-recovered) with soft-fail discipline.
- (K) "Asia arrives with a backup copy from the office" failure-recovery beat. **Asia continues to be the reliable structural presence the firm depends on.** Note this for retraversal: by chapter 5, Asia's having-a-backup-of-everything reads as the firm's actual financial-and-operational backbone, not as a quirk.
- (K) "If the player collapses in court with too many wrong answers and too little evidence, restart from the court preparation point, not from the whole chapter."

---

## Beat 13 — District Court arrival (lines 3268-3284)

- (K) Three clerk-line variants (clean/messy/failed-recovered).

---

## Beat 14 — Chapter 4 court sequence (lines 3287-3428)

- (K) Three-round structure with cross-examination addition.
- (K) **"Chapter 1: choose correct argument. Chapter 2: prepare evidence, then argue. Chapter 4: cross-examine testimony, catch contradictions, then argue remedy."** Mechanical progression.
- (K) Round 1 (technical irregularity) — Bajtek expert support, contradicts standard arguments.
- (K) **Round 2 contradiction scene** — two contradictions catchable (invoice + device), `round2_rival_link_strong` flag if both. Mechanical depth.
- (K) Round 3 (procedural prejudice and remedy).
- (R) Crab/Whimsy/Murrow/Bajtek support lines across all three rounds — phase 7 stance alignment. Crab's contradiction-spotting role is professionally opportunist; Whimsy's flourishes are bitterly cynical; Bajtek is the technical neutral.

---

## Victory states (lines 3431-3461)

- (K) Three tiers (strong / standard / weak). Soft-fail discipline. Even weak victory delivers the chapter narratively.

---

## Beat 15 — Payoff scene: apology to the printer (lines 3464-3501)

- (K) **Mr. Pig cries.** This beat is a *load-bearing display of his sincere idealism*. He is genuinely moved by having wrongly suspected the office printer; he genuinely cares about the people and things in the firm. **This beat is what makes the half-right portrait work.** A man capable of crying over a falsely-accused printer is a man whose idealism is real. The chapter-5 reveal will not invalidate this; it will sit alongside it. Both true at once.
- (K) Printer prints "OUT OF CYAN" mid-apology. Excellent timing.
- (K) Murrow files the STUB napkin under "personal effects, see also: morale" (referenced from Beat 11.5).
- (K) **"I would avoid giving the printer a permanent spoken personality. The joke is strongest if it remains ambiguous: maybe it is just printing status messages, maybe not."** Discipline.

---

## Chapter 5 hook — Swine postcard with bill (lines 3505-3525)

- (K) Postcard arrives attached to a bill. Asia/Pig/Murrow reactions.
- (K) Quest teaser. Chapter 5 transition. **The "small misunderstanding with a ski resort" hook is canonical and survives.**

---

## Chapter 4 NPC roles table (lines 3529-3543)

- (K) Cula, Asia, Murrow, Bajtek, Szpon, Printer, Judge, Print-shop worker rows.
- (R) **Mr. Pig**: "Comic stakes / Believes printer is sentient, fears deadline default, apologises emotionally." Survives. Note for phase 4: the "fears deadline default" — Mr. Pig's specific fears in this chapter are the toner costs, the deadline, the rival firm. **None of these are wrong, exactly.** The fears are real. The half-right portrait says: he is genuinely afraid AND the chronic fear-state has been maintaining the wage suppression. Both true.
- (R) **Crab**: "Factual analysis / Connects logs, invoice, device, deadline." Survives mechanically; align stance in voice references (opportunist's leverage-aware connecting, not crusading).
- (R) **Whimsy**: "Rhetorical chaos / Printer metaphors, court flourishes, comic support." Survives mechanically; align stance in voice references (cynic's theatrical distancing).

---

## Chapter 4 evidence and quest flags (lines 3547-3748)

- (K) all. Mechanical.

**Note for phase 4 inflection beat:** if the proposed Beat 11 inflection is added, a new flag will be needed. Suggested: `chapter4.glimpsed_ledger_anomaly` (boolean) or similar. This flag is *informational only* — it does not gate any chapter-4 progress. It is checked in chapter 5 retraversal to gate dialogue branches.

---

## Asia hint-state logic for Chapter 4 (lines 3752-3798)

- (K) all. Mechanical.

---

## Godot scene list (lines 3802-3823)

- (K) all. Mechanical/code.

**Note**: scooter_race.tscn is referenced; per PLAN.md it's a deferred mini-game now reframed as cutscene. Per the spine, the cutscene reframing actually serves the chapter better — fewer mechanical distractions in the chapter where the inflection lives.

---

## New system: Contradiction Spotting v1 (lines 3826-3881)

- (K) all. Mechanical/code.

---

## Chapter 4 implementation slice and acceptance criteria (lines 3884-3900)

- (K) all. Build order, completion criteria.

---

## Cross-cutting chapter-4 reframings to capture in phase 4 (beat sheet)

1. **The inflection beat (Beat 11 addition).** Cula glimpses Murrow's ledger or equivalent; sees a number that contradicts Mr. Pig's "we're broke" framing; is interrupted by urgency. Phase 4 must specify the exact form (option A / option B / something else) and the precise content visible to Cula.
2. **STUB founding stays unchanged.** No additions, no weight added. The discipline is in the restraint.
3. **The inflection and STUB founding must read as independent.** No causal link in chapter 4. Connection lands in chapter 5.
4. **Mr. Pig's specific financial fears (toner, deadline default, rival sabotage).** All real fears; none invalidated by the inflection. The half-right portrait says all are true at once.
5. **Beat 9 basement-unlock reluctance** — phase 4 should specify how to plant Mr. Pig's specific reluctance to enter the basement without telegraphing.
6. **Asia's backup-of-everything function** (Beat 12). Plant for chapter-5 retraversal — by chapter 5, Asia's reliability reads as the firm's actual operational backbone.

---

## Items requiring `data/voice_references/` updates (phase 7)

- `crab.jsonl` — Ch4 contradiction-scene support lines, basement reactions, court support, payoff lines in opportunist register.
- `whimsy.jsonl` — Ch4 court flourishes and contradiction support in cynic register.
- `pig.jsonl` — Ch4 maritime-crisis lines, basement reluctance, printer apology (sincere). Phase 4 may add an explicit inflection-anchor line if the ledger-glimpse form is chosen.
- `murrow.jsonl` — Ch4 ledger-related lines if option A inflection is chosen; the line he says before stepping out for the stamp.
- `bajtek.jsonl` (new) — full Ch4 voice authoring.
- `szpon.jsonl` (new) — full Ch4 voice authoring.
- `asia.jsonl` — Ch4 hint lines, backup-copy delivery line.

---

## Halina β corridor sighting (phase-8 addition)

**Slot:** somewhere within Chapter 4 — recommended placement: a brief courthouse-corridor encounter staged early-to-mid chapter, before the urgent-filing arc takes over. Phase-7 voice work for Chapter 4 specifies exact beat and adjacency.
**Length:** approximately 5 lines exchanged.
**Function:** the β recoloring of Halina's Chapter 1 case. Halina is at the courthouse "more often than I expected"; she is grateful, visibly diminished (cardiac plant from Ch1 Beat 8 paid off — possibly walking with a cane); she does not blame Cula. The encounter is brief, no narrative resolution, no legal resolution.
**Phase-7 voice work:** lines drafted in `bibles/halina_sikorska.md` for continuity; Chapter 4 voice pack (V4.* — TBD; likely V4.1 or V4.2 depending on adjacency choice) implements.
**Critical discipline:** Cula has no line that processes the encounter. The withholding-of-articulation discipline carries the moment. The literary epigram from Ch1 Beat 8 (*"You go to a lawyer like you go to a doctor: too late."*) recolors here without being repeated.
**Spec:** see `narrative_revision/audit/chapter_1_v2.md` β reappearance section + `bibles/halina_sikorska.md` Ch4 corridor section.

---

## Audit conclusion

Chapter 4 is **structurally ready for the spine**, with **one specific addition required**: the chapter-4 inflection beat in Beat 11. Everything else survives. **Phase-8 addition: Halina's β corridor sighting is staged within this chapter** (see section above; lines drafted in `bibles/halina_sikorska.md`). The chapter's mechanical depth (contradiction spotting, technical investigation, cross-examination) and its narrative depth (rival sabotage, false suspicion of the printer, the union founding) coexist without crowding each other.

Load-bearing items, in order of importance:
1. **Beat 11.5 — STUB/PUTKA founding.** Already canonical, already correctly tuned, do not strengthen.
2. **The proposed Beat 11 inflection beat.** Phase 4 must add this; the spine depends on it. Form to be decided (option A: Murrow ledger / option B: toner receipt).
3. **Beat 15 — Mr. Pig cries over the falsely-accused printer.** The proof of his sincere idealism. Without this, the half-right portrait collapses into cynic-marketer.
4. **The independence of Beat 11 and Beat 11.5.** The inflection and the union founding must not read as causally linked in chapter 4; the connection lands in chapter 5 retraversal.
5. **The dual-antagonist structure** (Szpon external, wage suppression internal). Both real, neither cancels the other.

**Phase 4 work for chapter 4 is the highest-stakes of the audit.** Get the inflection right and the rest of the spine clicks; get it wrong and chapter 5 has nothing to recolor against.
