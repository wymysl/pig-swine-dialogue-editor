# Phase 7 pack manifest

**Purpose:** the complete list of phase-7 drafting packs. Each pack is a self-contained context-bundle for a specific phase-7 session, designed to be pasted/uploaded into a fresh ChatGPT or Claude conversation to produce a focused chunk of dialogue.

**Pack format:** each pack is a single .md file in `narrative_revision/phase_7_packs/`. Self-contained (excerpts from the bibles, beat sheets, style canon, and ai_voice_constraints inlined). The user pastes/uploads the pack as the conversation's first context, then issues the drafting prompt at the bottom of the pack.

**Pack-building methodology** (for packs the user assembles themselves; H1 is fully prepared as a worked example):

1. **Header:** session goal, why this session, estimated session length.
2. **§A General AI tells:** copy from `ai_voice_constraints.md §1` — same in every pack.
3. **§B Per-character constraints:** for each character speaking in the scene, copy from `ai_voice_constraints.md §2/§3`. Include their canonical samples, syntax disciplines, will-not-say list, and AI-tell vulnerabilities.
4. **§C Style canon excerpts:** copy the sections from `style_canon.txt` relevant to the scene type (e.g., §6 court design for court scenes, §8 Warsaw atmosphere for outdoor scenes).
5. **§D Beat sheet excerpt:** copy the canonical specification from `narrative_revision/beats/chapter_N.md` for the relevant beat(s).
6. **§E Bible row excerpt(s):** copy the relevant chapter row(s) from each speaking character's bible.
7. **§I Drafting prompt template:** the actual prompt to issue to the model. Use §4 of `ai_voice_constraints.md` as a starting template; customize for the scene.
8. **§J Hostile-critique prompt** (for second model): adapt H1's §J template; second model uses the same pack as context.
9. **§K Output expectations:** what success looks like for this scene.

**Working rhythm:**
- Open a new conversation per pack.
- First model drafts (typically Claude Opus for spine-critical, GPT-5 for higher-volume).
- Second model critiques against the pack.
- Arbitrate disagreements yourself.
- Read aloud. Scrub. Commit.
- Move to next pack.

**Authority hierarchy:** style_canon.txt > bibles/*.md > beats/*.md > ai_voice_constraints.md > the pack file. When the pack and a source disagree, source wins. Update the pack to match.

---

## Tier 1 — Priority horizontal packs (do these first)

These are the spine-critical phase-7 items that protect the project's most-fragile commitments. Author them first; the rest of phase 7 builds on the discipline established here.

### H1 — Round 5 four-line cluster (chapter 6)

**Status:** ✅ fully prepared (`H1_round_5_cluster.md`).

**Goal:** draft the four-line cluster at chapter-6 Round 5 (Cula's procedural-remedy opening + Whimsy's flourish + Pig's canonical sincere line + judge's remedy announcement, plus Swine's testimony and judge response).

**Why first:** Critical-hit phase-7 expression (per pressure_test.md Hit #18). Cathartic-resolution failure mode is the most-protected spine commitment.

**Estimated session length:** 2-3 hours.

**Speaking characters:** Cula, Whimsy, Mr. Pig, Mr. Swine, Supreme Court Judge.

---

### H2 — Mr. Pig's "back in my day" lectures (chapters 1-4 + chapter-6 absence)

**Status:** ✅ fully prepared (`H2_pig_lectures.md`).

**Goal:** author all four "back in my day" lectures together (Beat 8 ch 1, mid-chapter ch 2, Beat 11 ch 4, Beat 0 ch 5) plus the chapter-6 Beat 14 lecture-absence half-line. The lectures must escalate or vary; they must read sincere on first pass; they must recolor cumulatively after the chapter-5 Beat 0 family-photo discovery.

**Why second:** the lecture pattern is one of three Critical-tier recoloring layers (per `00_decisions.md` priority ranking). Authoring together ensures the variation lands.

**Estimated session length:** 3-4 hours (more time per line because pattern coherence matters across five chapters).

**Speaking characters:** Mr. Pig only (with brief reaction lines from juniors as needed).

**Files to draw from:** `ai_voice_constraints.md` §2 Mr. Pig section + §4 lecture cluster template; `bibles/pig.md` (full); `beats/chapter_1.md`, `chapter_2.md`, `chapter_3.md`, `chapter_4.md`, `chapter_5.md` (Beat 8, Beat 10/15, Beat 11, Beat 0, Beat 14 sections respectively); `style_canon.txt §1` Pig pass examples + §2 voice rules.

---

### H3 — Cula-Murrow staging (Beat 11 chapter 5 + Beat 14 chapter 6)

**Status:** ✅ fully prepared (`H3_cula_murrow_staging.md`). **Note: this pack is largely visual scripting / stage direction, not dialogue. The user should write much of this themselves with the model assisting on framing language.**

**Goal:** specify the staging for the chapter-4 Beat 11 inflection (Murrow interrupted by phone; Cula glimpses ledger; single-sided acknowledgment on Murrow's return) and the chapter-6 Beat 14 final image (Murrow at desk closes ledger as Cula passes; shared spatial moment without eye contact).

**Why third:** the spine's most delicate writing-discipline item. The user reviews directly; the model's role is supportive on framing language, not load-bearing.

**Estimated session length:** 1-2 hours.

**Files to draw from:** `ai_voice_constraints.md §4` Cula-Murrow staging template; `bibles/murrow.md`, `bibles/cula.md`; `beats/chapter_3.md` Beat 11; `beats/chapter_5.md` Beat 14.

---

## Tier 2 — Other horizontal packs

These cover cross-chapter consistency patterns. Author after the Tier 1 priorities.

### H4 — Mr. Pig's chapter-end celebration ordering (chapters 1-5)

**Status:** ✅ fully prepared (`H4_pig_celebrations.md`).

**Goal:** author the firm-survival celebration line at each chapter's office-payoff scene (chapter 1 Beat 11, chapter 2 Beat 15, chapter 6 Beat 16, chapter 6 Beat 14 half-line). **Chapter 5 is the pattern-break** — Pig's chapter-4 sincere moment is the printer apology in Beat 15, not a firm-survival celebration. The firm-first / client-second ordering must be consistent across the four chapters that have a celebration; chapter 6 Beat 16 is the strongest pattern moment because it precedes the chapter-6 retraversal recoloring.

**Estimated session length:** 1-2 hours.

**Speaking characters:** Mr. Pig only.

---

### H5 — STUB founding scene + chapter-6 callbacks

**Status:** ✅ fully prepared (`H5_stub_founding.md`).

**Goal:** author the Beat 11.5 STUB founding scene (chapter 5, post-phase-6 relocation: Crab and Whimsy at the office, Cula via phone, Asia declines membership) plus the chapter-6 callbacks (faded printer sticker visible in office scenes; Crab's passing reference to "grievance #4 still unresolved"; the typo-ridden cork-board notice). **Critical discipline: the joke is the scale; STUB is comic-deflationary, not historically grand; visual elements + ONE Crab line is the chapter-6 budget.**

**Estimated session length:** 1-2 hours.

**Speaking characters:** Crab, Whimsy, Cula (via phone), Asia.

**Critical constraint:** style_canon §3 STUB rules — "comic-deflationary, not historically grand"; "the joke is the scale"; "two callbacks across the rest of the game; not a recurring punchline." **Do not strengthen.**

---

### H6 — Swine's postcards (chapters 1, 2, 3, 5)

**Status:** ✅ fully prepared (`H6_swine_postcards.md`).

**Goal:** author the **four canonical postcards** (chapter 1 final stinger, chapter 2 final stinger, chapter 5 chapter-5 hook with bill, chapter 6 Beat 14 "Greetings from Pig & Swine, Warsaw" reading-aloud-while-present). The chapter-5 Beat 16 "should be in the office tomorrow" line is in-person dialogue — covered separately in V5.8 chapter-vertical pack — not a postcard. The postcard formula ("Greetings from [place], [business opportunity], stay solvent") varies across the four; the chapter-6 postcard's place-twist (the office itself) is the comic-deflationary closure.

**Estimated session length:** 1-2 hours.

**Speaking characters:** Mr. Swine (postcard text only; chapter 6-5 in-person lines covered in vertical packs).

---

## Tier 3 — Vertical packs (per chapter)

These cover scene-by-scene drafting within each chapter. Author after Tier 1; Tier 2 can interleave with Tier 3.

**Recommended order:** chapter 1 (warm up the methodology) → chapter 2 (light reframe + Plotek thread) → chapter 5 (inflection chapter; spine-critical) → chapter 6 (recoloring chapter; retraversal-heavy) → chapter 6 (synthesis chapter).

### Chapter 1 — "The Financial Crisis"

| Pack | Beats | Goal | Speaking characters | Est. |
|---|---|---|---|---|
| **V1.1** ✅ | Beats 0-2 | Office opening; Asia welcome; Mr. Pig crisis reveal (rent claim only). | Cula, Asia, Mr. Pig | 1-2h |
| **V1.2** ✅ | Beats 3-5 | Find Murrow + address-form first-name beat; binder pickup; Crab recruitment (opportunist register). *Pass 6 supersedes pass 3 with phase-8 V1.4-canonical alignment (2026-05-08): Halina Sikorska eviction defense, apartment #7→#12, landlord-knowledge-via-2019-renewal-countersignature, Article 132 retained for Crab's service-and-knowledge deliverable per V1.4 division of labor.* | Cula, Murrow, Crab | 2h |
| **V1.3** ✅ | Beats 6-7, 10 | Café Paragraf; Whimsy recruitment (cynic register); coffee tutorial; readiness check (printer-lease claim + first lecture from H2). *Phase-8 V1.5/V1.6-canonical alignment 2026-05-08: readiness check renumbered Beat 8 → Beat 10 (post-phase-8 Beats 8-9 are V1.4 Halina/Archive territory; V1.3 jumps from Beat 7 to Beat 10). Drafted dialogue lines remain canonical; V1.5 imports the readiness-check lines verbatim.* | Cula, Whimsy, Murrow, Mr. Pig, Barista | 2-3h |
| **V1.4** ✅ | Beats 8-9 | Halina client meeting (three load-bearing dialogue stances: sympathetic / blunt-procedural / technical; cardiologist plant; fee discussion; literary epigram) + Archive Room research (Murrow narrates Article 135-bis § 2 clause-by-clause). | Asia, Cula, Halina, Crab, Whimsy, Mr. Pig, Murrow | 3-4h |
| **V1.5** ✅ | Beats 10-11 | Court readiness check (Murrow's mechanical handover; Pig's printer-lease aside; Pig's first H2 lecture; stance-aligned Cula confirm) + walk to District Court (judgmental pigeons; Halina greeting at the steps). *Pass 7 commit shape 2026-05-08; phase-8 lockstep alignment edit to V1.4 pass 4 (stoop-conditional dropped).* | Murrow, Mr. Pig (Beat 10 only), Cula, Crab, Whimsy, Halina (brief Beat-11 greeting) | 1-2h |
| **V1.6** ✅ | Beat 12 | Three court rounds (Round 1 defective service with stance-aligned bonus evidence; Round 2 fair hearing with Whimsy flourish; Round 3 modest remedy with stance-aligned Cula ask; District Court Judge dry-surprise across all three rounds; remedy announcement procedurally grounded in Article 135-bis § 2). *Pass 5 commit shape 2026-05-09; pass 1 plus four §J review/arbitration passes baked in.* | Cula, Crab, Whimsy, District Court Judge, landlord's counsel (functional); Halina silent presence; Murrow silent in gallery | 2-3h |
| **V1.7** ✅ | Beats 13-14 | Post-court office payoff (firm-survival celebration from H4 + missing-retainer claim + ledger update); Swine postcard from H6. | Cula, Mr. Pig, Asia, Murrow, Crab, Whimsy | 1-2h |
| **V1.A** ✅ | Asia hint states | All Asia hint-state branches for chapter 1. | Asia | 1h |

---

### Chapter 2 — "The Eviction Defense"

| Pack | Beats | Goal | Speaking characters | Est. |
|---|---|---|---|---|
| **V2.1** | Beats 0-1 | Post-Ch1 office state (Pig's "we're broke" continuation); Waldek intake. | Cula, Mr. Pig, Asia, Murrow, Crab, Whimsy, Waldek | 2h |
| **V2.2** | Beat 1.5 | Neutral office texture beat + Plotek case-file arrival + Pig's principle-acceptance + juniors' brief reactions. | Mr. Pig, Cula, Crab, Whimsy, Murrow, Asia | 1-2h |
| **V2.3** | Beats 2-7 | Murrow framing; Tenants' Row; Waldek's apartment; Kowalski + Zielinska witness interviews. | Cula, Murrow, Waldek, Kowalski, Zielinska | 3-4h |
| **V2.4** | Beat 8 | Landlord's Office; Administrator Beton; first Grzyb appearance. | Cula, Beton, Grzyb, Crab, Whimsy | 2h |
| **V2.5** | Beat 8.5 | Plotek first detention visit (Cula + Murrow accompanying; legal-landscape access only). | Cula, Plotek, (Murrow silent) | 2h |
| **V2.6** | Beats 9-12 | Document Chase; office return; Evidence Board introduction; readiness check. | Cula, Mr. Pig, Asia, Murrow, Crab, Whimsy | 2-3h |
| **V2.7** | Beats 13-15 | Walk to Housing Court; three rounds; victory; payoff (incl. Pig celebration H4 + chapter-4 hook). | Cula, Grzyb, Judge, Crab, Whimsy, Waldek, Kowalski, Zielinska | 3h |
| **V2.A** | Asia hint states | Chapter 2 Asia hint-state branches. | Asia | 1h |

---

### Chapter 4 — "The Assigned Case" (NEW; compact criminal-defense chapter; phase-8 expansion)

| Pack | Beats | Goal | Speaking characters | Est. |
|---|---|---|---|---|
| **V3.1** | Beat 1 | Office: Mr. Pig's fury at ex officio assignment (anger-register variant of distractable-anxious facet); Asia's operational briefing ("State pays a fixed amount per case. It won't cover two lawyers. You'll go alone — wear something warm, the visitor rooms run cold."). Plotek folder environmental plant on Whimsy's desk. | Mr. Pig, Asia, Cula | 1-2h |
| **V3.2** | Beats 2-3 | **Largest single voice-pack effort in the chapter.** Walk to detention center (minimal staging; no narration recommended). Detention scene with Kacper Mazurek — three-stance dialogue carrier (sympathetic / procedural / direct), the canonical "Two years? I can do that. Easy." line, biographical surfacings per stance, exit courtesy ("Thank you, counselor."). Strict audit constraints: Kacper must not read pitiable or aggressive; Cula has no internal-narration line at the "2 years easy" moment (silence carries the moment); withholding-of-articulation discipline. | Cula, Kacper Mazurek | 3-4h |
| **V3.3** | Beats 4-5 | Office: case prep with Crab (scenting-leverage register; canonical line: "The lock was already gone. The patrol report says he didn't run. The inventory says coat, sandwich, banknotes. We can fight the breaking element."). Murrow's brief procedural reminder. Court hearing — three phases (contest *włamanie* / contextualize / argue suspended sentence). Phase 2 strict audit: no pleading for mercy, no lecturing about systemic poverty; observational factual presentation only. Phase 3 verdict cites KK Art. 279 § 1 + Art. 69 § 1 + Art. 70 § 2. Whimsy is absent — no Whimsy lines in this pack. | Cula, Crab, Murrow, Court Judge (compact-chapter NPC) | 3h |
| **V3.4** | Beat 6 + Ch5 hook | Office return: ambiguous aftermath (no celebration; depleted register; Whimsy still absent). Mr. Pig resignation ("Done. Good. Next."). Asia muted-cheerful. Murrow archival-placement line ("Filed under suspended."). Crab CV-item comment. Coffee machine sound muted. Then the relocated **Chapter 5 hook** (printer-stinger moved from old Ch2-end position to new Ch4-end; Mr. Pig "straightens up" reaction; sets `chapter4.complete = true` and `current_chapter = 4`). | Mr. Pig, Asia, Murrow, Crab, Cula | 1-2h |
| **V3.A** | Asia hint states | Compact chapter Asia hint-state branches (small set; chapter is short, Asia mostly off-screen between Beats 1 and 6). | Asia | 1h |

**Total Chapter 4 packs:** 5 packs · ~9-12 hours.

**Critical phase-7 audit points for Chapter 4** (apply to every V3.* pack):

- Kacper must read as guarded street-smart, not slow, not naive, not pitiable, not aggressive. The "2 years easy" line is accurate, not deflective. (See `bibles/kacper_mazurek.md`.)
- Cula has no internal-narration line at the "2 years easy" moment. The withholding-of-articulation discipline carries the chapter's emotional weight.
- Whimsy is absent throughout. **No Whimsy lines in any V3.* pack.** His absence is character development in negative space; the player notices via the environmental Plotek folder plant in V3.1, not via Cula commentary.
- Mr. Pig's anger register at Beat 1 is a register-shift within his existing distractable-anxious facet; do not introduce a new fourth facet. Maritime metaphors recede (the anger is too pointed for them).
- Asia's briefing must NOT use first-person-collective pronouns that include herself in the lawyer group ("two of us" forbidden; "two lawyers" correct). Per `bibles/asia.md` discipline.
- Phase 2 hearing argument is observational, not advocative. No pleading for mercy. No lecturing about systemic poverty.
- Phase 3 verdict cites the three canonical articles (KK Art. 279 § 1 statutory minimum, Art. 69 § 1 max suspendable, Art. 70 § 2 *młodociany* probation range 2-5y, settled at 3y).
- Beat 6 explicitly has **no celebration, no badge, no postcard**. Structural inverse of Ch1 Beat 13 and Ch2 celebration.

---

### Chapter 5 — "The Printer Conspiracy" (spine-critical)

| Pack | Beats | Goal | Speaking characters | Est. |
|---|---|---|---|---|
| **V4.1** | Beats 0-3 | Beat 0 continuation; printer screams; Bajtek arrival; Server Room. | Cula, Mr. Pig, Murrow, Crab, Whimsy, Asia, Bajtek | 3h |
| **V4.2** | Beats 4-4.5 | Contradiction tutorial with Bajtek; Plotek second detention visit (Cula alone; biographical mother-mention). | Cula, Bajtek, Plotek | 2h |
| **V4.3** | Beats 5-8 | Business District unlock; Print Shop investigation; Szpon first appearance; first hostile contradiction. | Cula, Crab, Whimsy, Szpon, Print-shop worker | 3h |
| **V4.4** | Beats 9-10 | Office return; basement-unlock reluctance; Pig & Swine Basement; Hidden Reroute Device + Asia structural-reach hint. | Cula, Mr. Pig, Murrow, Asia, Crab, Whimsy, Bajtek | 2-3h |
| **V4.5** | Beat 11 | Urgent filing prep + INFLECTION (covered partially by H3 Cula-Murrow staging; this pack handles the dialogue around the staging — Pig's third lecture from H2; team filing-assembly dialogue). | Cula, Mr. Pig, Murrow, Crab, Whimsy, Bajtek, Asia | 2-3h |
| **V4.6** | Beat 11.5 | STUB founding (covered by H5 — this pack reference only). | — | (in H5) |
| **V4.7** | Beats 12-14 | Deadline Dash cutscene; District Court arrival; three-round court (cross-examination at higher stakes); victory states. | Cula, Crab, Whimsy, Szpon, Bajtek, Murrow, Judge | 3-4h |
| **V4.8** | Beat 15 + Ch6 hook | Printer apology (Pig's tears, undefended); Murrow files STUB napkin; chapter-5 hook (Swine postcard with bill from H6). | Mr. Pig, Bajtek, Crab, Whimsy, Murrow, Asia | 2h |
| **V5.A** | Asia hint states | Chapter 5 Asia hint-state branches. | Asia | 1h |

---

### Chapter 6 — "Mr. Swine Returns" (recoloring chapter)

| Pack | Beats | Goal | Speaking characters | Est. |
|---|---|---|---|---|
| **V5.1** | Beat 0 | Retraversal beat (focal: family-photo Cula observation; ambient: case board + cork board + ledger area + Asia desk; Pig's idle line + fourth lecture from H2). | Cula, Mr. Pig, Asia, Murrow, Crab, Whimsy | 2-3h |
| **V5.2** | Beats 1-3 | Arbitration papers arrive; Mr. Swine returns; initial questioning. | Cula, Mr. Pig, Mr. Swine, Murrow, Crab, Whimsy, Asia | 3h |
| **V5.3** | Beats 4-6 | Route to Airport Road; Warsaw Airport; Japanese Embassy (Tanaka). | Cula, Airport Clerk, Ms. Tanaka, Mr. Swine | 2-3h |
| **V5.4** | Beats 7-8 | Penthouse approach + interior; Pro-Bono Transfer Stub discovery (CRITICAL — Pig genuine surprise; Murrow not-surprise; Swine cheerful-evasion). | Cula, Mr. Pig, Murrow, Mr. Swine, Crab, Whimsy, Penthouse Doorman | 3-4h |
| **V5.5** | Beat 9 | Ski Slalom: Memory on Ice cutscene (three outcome tiers). | Mr. Swine, Cula | 1-2h |
| **V5.6** | Beat 10 | Office return retraversal + Plotek warrant suppression announcement + Dual Attorney introduction. | Cula, Mr. Pig, Asia, Murrow, Crab, Whimsy | 2-3h |
| **V5.7** | Beats 11-15 | Arbitration Hearing Room; four rounds; victory states. | Cula, Mr. Swine, Resort Counsel (Yamada), Arbitrator, Whimsy, Crab, Murrow | 4h |
| **V5.8** | Beat 16 | Payoff: Swine partly explains himself (CRITICAL — Pig's conflicted reaction; Swine's attempt-and-fail; Cula distributed-flag branch; Pig celebration from H4). | Cula, Mr. Pig, Mr. Swine, Murrow, Crab, Whimsy, Asia | 3-4h |
| **V5.9** | Ch6 hook | District consolidation notice arrives. | Mr. Pig, Murrow, Crab, Whimsy, Mr. Swine, Asia | 1h |
| **V6.A** | Asia hint states | Chapter 6 Asia hint-state branches. | Asia | 1h |

---

### Chapter 6 — "The Final Brief" (synthesis chapter)

| Pack | Beats | Goal | Speaking characters | Est. |
|---|---|---|---|---|
| **V6.1** | Beats 0-1 | Cumulative office state retraversal; district served; six-character reaction set (Pig firm-first ordering). | Cula, Mr. Pig, Murrow, Crab, Whimsy, Mr. Swine, Asia | 2-3h |
| **V6.2** | Beats 2-3 | Protest Square unlock; returning NPCs (Waldek, Kowalski, Zielinska, Barista, Archivist, Grzyb); Grzyb's reluctant-ally register. | Cula, Waldek, Kowalski, Zielinska, Grzyb, Barista, Archivist | 3h |
| **V6.3** | Beats 4-5 | City Hall investigation; contradiction-spotting at higher stakes (City Official; Plotek-network detail in Procurement Link evidence). | Cula, Crab, City Official | 2-3h |
| **V6.4** | Beats 6-9 | Industrial Printer Room; Final Printer boss battle; Szpon confrontation. | Cula, Bajtek, Crab, Whimsy, Murrow, Szpon | 3-4h |
| **V6.5** | Beat 10 | Swine's full secret reveal (CRITICAL — Crab places ledger; Murrow not-surprise; Pig genuine emotion; Swine attempt-and-fail; ratioed sincerity). | Cula, Crab, Murrow, Mr. Pig, Mr. Swine, Asia, Whimsy | 3-4h |
| **V6.6** | Beat 11 | Team Assembly; ally-slot assignments; Asia final brief index. | Cula, Murrow, Asia | 2h |
| **V6.7** | Beats 12-13 (R1-R4) | Walk to Supreme Court; Round 1 (defective notice); Round 2 (proportionality with Waldek); Round 3 (technical suppression with contradictions); Round 4 (conflict of interest with Grzyb). | Cula, Murrow, Waldek, Bajtek, Crab, Grzyb, Szpon, Supreme Court Judge | 4h |
| **V6.8** | Round 5 | Round 5 four-line cluster (covered by H1 — this pack reference only). | — | (in H1) |
| **V6.9** | Beat 14 | Ending sequence — returning NPC final lines; Grzyb beige card; Szpon newspaper headline; Plotek newspaper footnote; printer final message; Pig interrupted speech (NOT in lecture register); Swine postcard from H6; final image (Murrow closes ledger from H3); branch staging variants; credits cards. | Cula, Mr. Pig, Mr. Swine, Murrow, Crab, Whimsy, Asia, Waldek, Kowalski, Zielinska, Bajtek, Grzyb | 4-5h |
| **V6.A** | Asia hint states | Chapter 6 Asia hint-state branches. | Asia | 1h |

---

## Pack count and total effort estimate

- Tier 1 priority horizontal: **3 packs** (~6-9 hours)
- Tier 2 horizontal: **3 packs** (~3-6 hours)
- Tier 3 vertical chapter 1: **8 packs** (~14-17 hours) — *V1.5 ✅ committed 2026-05-08; V1.6 ✅ committed 2026-05-09*
- Tier 3 vertical chapter 2: **8 packs** (~17-20 hours)
- Tier 3 vertical chapter 4: **5 packs** (~9-12 hours) — NEW; phase-8 compact criminal chapter (Kacper)
- Tier 3 vertical chapter 5: **9 packs** (~20-25 hours)
- Tier 3 vertical chapter 6: **10 packs** (~22-26 hours)
- Tier 3 vertical chapter 6: **10 packs** (~25-30 hours)

**Total: ~56 packs · ~113-147 hours of focused phase-7 work.**

At 5-10 hours per week of part-time work, phase 7 is **3-6 months of effort** for one developer. The methodology helps you not redo work; it doesn't make the work small.

If production constraints force shrinking, the phase-6 priority ranking (`00_decisions.md` "Recoloring layer priority" section) governs cuts:
- Critical (must work): H1, H2, H3, H4 — keep all.
- Significant (should work): H5, H6 — keep.
- Decorative (could shrink): the Plotek-thread packs (V2.5, V4.2 partially, V5.6 partially) — could compress to fewer scenes.

---

## Working-document conventions

As you complete each pack, commit the dialogue to:
- `data/voice_references/<character_id>.jsonl` — append the new lines per character. Run `tools/voice_audit.py` after each pack.
- `data/dialogues/<npc_id>.json` — for chapter-specific NPCs; build out as you complete chapter-vertical packs.
- A working scratch file `narrative_revision/phase_7_drafts/chapter_N.md` — for in-progress chapter dialogue before final commit.

After each pack:
- Update the manifest with completion status (✅ done / 🚧 in-progress / ⏸ paused).
- Append session notes (what worked, what to adjust in next pack) to a phase-7 working log.

---

## Pack index (alphabetical, completion status)

- ✅ **H1** — Round 5 four-line cluster (`H1_round_5_cluster.md`)
- ✅ **H2** — Pig's "back in my day" lectures (`H2_pig_lectures.md`)
- ✅ **H3** — Cula-Murrow staging (`H3_cula_murrow_staging.md`)
- ✅ **H4** — Pig's chapter-end celebration ordering (`H4_pig_celebrations.md`)
- ✅ **H5** — STUB founding + chapter-6 callbacks (`H5_stub_founding.md`)
- ✅ **H6** — Swine's postcards (`H6_swine_postcards.md`)
- ✅ **V1.1** — Chapter 1 office opening + Pig crisis reveal (`V1.1_office_opening_pig_crisis.md`)
- ✅ **V1.2** — Find Murrow + binder + Crab recruitment (`V1.2_find_murrow_binder_crab.md`) *(pass 6 supersedes pass 3 with phase-8 V1.4-canonical alignment, 2026-05-08; ✅ status preserved)*
- ✅ **V1.3** — Café Paragraf + Whimsy + coffee + readiness check (`V1.3_cafe_whimsy_coffee_readiness.md`)
- ✅ **V1.4** — Halina client meeting + Archive Room research (`V1.4_halina_meeting_research.md`)
- ✅ **V1.5** — Court readiness check + walk to District Court (`V1.5_court_readiness_and_walk.md`) *(pass 7 committed 2026-05-08; phase-8 lockstep alignment edit to V1.4 applied)*
- ✅ **V1.6** — Three court rounds at the District Court (`V1.6_court_rounds.md`) *(pass 5 committed 2026-05-09; pass 1 plus four §J review/arbitration passes baked in; new dialogue file `data/dialogues/judge_district_ch1.json`; new voice-reference file `data/voice_references/dialogue_samples_landlord_counsel_ch1.jsonl`; "Landlord's Counsel" added to `tools/voice_audit.py` CANONICAL_SPEAKERS)*
- ✅ **V1.7** — Post-court office payoff + Swine postcard (`V1.7_post_court_payoff.md`) *(pass 5 committed 2026-05-09; pass-4 arbitration baked in; new dialogue file `data/dialogues/postcard_swine_ch1.json`; JSONL appended: mr_pig (6 lines), asia (2 lines), mr_murrow (1 line), crab (1 line), whimsy (2 lines), dr_a_cula (2 lines), mr_swine (2 lines))*
- ✅ **V1.A** — Asia hint states (chapter 1) *(pass 3 committed 2026-05-09; 12 hint-state lines appended to `dialogue_samples_asia.jsonl`; new dialogue file `data/dialogues/asia_hint_states_ch1.json`; chapter-1 vertical pack work concludes)*
- ⏸ **V2.A through V6.A** — chapter-vertical packs (35 entries remaining; assemble per the table above; includes the phase-8 compact-chapter V3.1–V3.A entries below)
- ⏸ **V3.1 through V3.A** — phase-8 compact-chapter packs for Chapter 4 — "The Assigned Case" (Kacper Mazurek's case; 5 entries; see Chapter 4 table)
- 📌 **Phase-8 horizontal-pack chapter-renumbering note** — H1, H2, H3, H4, H5, H6 pack file contents reference the OLD chapter numbering (chapter 4 inflection, chapter 5 retraversal, chapter 6 finale). Stage 8 continuity sweep updates these to chapter 5 inflection / chapter 6 retraversal / chapter 6 finale. Until that sweep runs, the manifest table holds the canonical post-phase-8 numbering; pack file content takes second priority.

---

## End of manifest

This manifest is a working document. As you progress through phase 7, update completion status, refine pack scope, and add session notes. The manifest is the project plan; the packs are the sessions.
