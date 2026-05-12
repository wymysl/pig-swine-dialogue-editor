# Narrative Revision — Decisions Reached

**Date:** 2026-05-05
**Status:** committed via `godot/PROPOSALS.md §9`
**Method:** extracted from chat brainstorming; supersedes earlier in-conversation drafts. No `.txt` editing has happened yet — this file is the decision snapshot, not the implementation.

---

## The thematic spine

The game is about a crisis of values. Pig & Swine prides itself on protecting human rights, equality, and the lawyer's ethos, while the firm's actual operation is shot through with contradictions the player gradually surfaces. The spine, as a single question that organizes the cast:

**Does it matter why someone helps you, if they help?**

Four constituencies ask this question in different registers, and the four answers are all true at once:

- **Mr. Pig** asks it sincerely. His sincerity is part of his exploitation.
- **The juniors** ask it bitterly. They are the ones doing the helping, and they know what it costs them.
- **The clients** ask it gratefully. Most don't care about the firm's internal politics; they got their hearing won.
- **The union (STUB/PUTKA)** asks it cynically. The help is real, and the help is a wage-suppression engine.

The game **poses the question; it does not answer it**. The player ends with a clearer view of the trade-offs and no verdict. The cathartic-resolution ending — firm exposed, juniors win, union triumphs — is **forbidden**, because it answers the question wrong and is the protective-irony failure mode in disguise.

---

## Mr. Pig's portrait

Not a hypocrite who has fooled himself. A man who has correctly identified that running a human-rights firm in Warsaw at all requires absurd discipline, who keeps his own salary low to prove the discipline is symmetric, and who refuses lucrative corporate retainers when offered. The retainer-refusal must happen on-screen, decisively, in a moment where the player feels the cost.

His blind spot is structural and biographical. **Structural**: his austerity is voluntary while the juniors' is structural. He can stop being austere any time; they can't. He doesn't see this. **Biographical**: Mr. Pig comes from a wealthy multi-generational family of Warsaw advocates. His father was an established advocate; the family kancelaria has been in operation across at least three generations; Pig's expensive secondary schooling and aplikatura tutelage were inside the family network and paid for by family. He nonetheless tells "back in my day" lectures across the game about working eighteen-hour days, begging for opportunity, and surviving on a sandwich-and-the-room. **The lectures are not lies in his head.** The hours and the discipline were real; the family safety net that made them survivable is invisible to him. He has narratively recast a comfortable-with-effort upbringing as authentic struggle.

**The chapter-5 family-photo discovery is the focal recoloring moment.** The framed family photo on Pig's desk has been visible since chapter 1 as ordinary office decoration. In chapter 5 Beat 0 retraversal, examination of the photo plants the discovery: a younger Pig surrounded by multiple lawyer-robed family members in front of a stately kancelaria. Cula's observation line is brief and observational; no character editorializes; the player carries the meaning.

**Writing implication.** Scenes must stage his idealism as genuinely admirable in early chapters, then later legible as a class blind spot AND a biographical blind spot, without retroactively erasing the admiration. The player should still like him in chapter 5 while disagreeing with him about everything that matters. The harder version. The cynical-marketer version is rejected.

## The firm's actual financial state (numbers)

Phase-4 decisions committed:

- **Junior salaries: at or near Polish minimum wage** (~60,000 PLN gross/year per junior). Cula, Crab, Whimsy all at this level. Asia paid comparably.
- **Annual entry-level wage burden: ~240,000-280,000 PLN** (4 staff at minimum-or-near-minimum).
- **Operating account reserve at chapter-4 inflection: a substantial buffer, several hundred thousand PLN** — approximately one full year of doubled junior salaries. The reserve has been steady for months. The number lands the wage-suppression as plainly unjustified. *(Per phase-6 Hit #9 looseness pass: the specific number — currently 285,400 PLN — lives in `beats/chapter_3.md` as the single source of truth. This file describes the shape of the number, not the figure, to reduce coupling.)*
- **Pro-Bono Stub redirections (Swine, undisclosed to Pig): ~95,000 PLN over 4 years** distributed across diverse recipients: Stowarzyszenie Pomocy Lokatorom Warszawskim (primary), a refugee legal aid center, a domestic violence shelter's legal fund, an environmental rights group, plus smaller secondary recipients. Roughly 40% of one junior's annual salary spread over four years — meaningful but not the larger picture. (Phase-6 Hit #13 revision: the recipient list is diversified rather than single, to avoid the plot-symmetry too-tidy reading.)

**The numbers tell a layered story.** The firm has been comfortably solvent. Pig's "we cannot pay rent" framing is a performance. Swine's redirections account for some of the apparent financial pressure but not for the reserve's existence. The juniors at minimum wage could have been raised meaningfully and still left substantial buffer. None of this is visible to Pig; the spine commits to him not seeing it across all five chapters.

---

## The juniors — three stances, not three traumas

A trio, not four. Three is a comedy ensemble; four is a workplace. Differentiation is by stance toward the central question, not by personal backstory.

- **True believer — Cula (the player).** Takes the mission seriously, defends Mr. Pig, gets exploited the worst, slowly discovers the gap. The most painful arc, which is also the protagonist's arc. His stance starts fixed; the player's choices shape *how* he resolves the contradictions he encounters — stays a true believer with eyes open, slides toward Whimsy's cynicism, exits toward Crab's opportunism. None of those endings is graded as right.
- **Cynic — Whimsy.** Clocks the exploitation immediately, mostly correct, ineffective and small. Right and a loser.
- **Opportunist — Crab.** In it for résumé polish, not particularly damaged by the situation, lateral-moves out at the right moment. Probably the most professionally competent person in the room because their reputation is the product.

Each junior is right about the others and wrong about themselves. Comedy comes from the misalignment. None is the hero. None is the villain. The opportunist is **not** the bad one.

**Risk to manage in writing.** The true-believer perspective gets more screen time than the other two by virtue of being the protagonist's. Crab and Whimsy must read as stances-from-the-inside, not as foils. They need scenes that render their stance with density, not just react to Cula's.

### Considered and rejected

- **Vessel option.** Cula as a blank protagonist with three NPC juniors carrying the stances. Rejected: requires a fourth junior (the Camilla problem returns), produces the flat-protagonist failure mode RPGs default into.
- **Wild option.** Cula as opportunist (player as careerist). Considered, not chosen — bolder and possibly more thematically interesting (the opportunist sees clearly because they're not invested), but harder to write within RPG protagonist conventions and risks player alienation. Logged as an alternative if the true-believer reading falters during bible work.

**Final stance assignments (Crab = cynic, Whimsy = opportunist) get pinned in phase 3 bible work.**

---

## The white-collar client (new principal client)

A rich white-collar criminal. Cula visits him in detention. He is polite, possibly charming, conversational. The menace is structural, not personal — he can phone-call a junior's mother into a tax audit, get a former colleague blackballed, end a career from his cell. The danger isn't in the room with him; it's in his network outside the room.

The firm has genuine grounds to defend him on at least one narrow charge. He may be partly the victim of an overzealous prosecutor with political ambitions. He is not a pure monster. The case is the test of whether the firm's universal-principles ethos survives contact with someone who weaponizes it. The player's stomach should turn while the firm helps him anyway, on principle, justifiably.

---

## Camilla — rejected (logged so it does not quietly return)

A fourth junior — "blonde, brilliant, humble" — was proposed and rejected.

**Reason.** No internal contradiction for the writing to grip. "Brilliant and humble" is a description without an edge; the character drifts toward audience-proxy / Mary-Sue territory and flattens thematic complexity by becoming the Right Answer. Roster economics: a fourth junior costs ~33% more reactive dialogue across every plot beat for diminishing thematic return. The trio is tighter and funnier.

**Conditional re-entry.** If a fourth junior is ever added, she must arrive with a contradiction the game can use — e.g., the brilliant one Mr. Pig genuinely confides in, who is therefore the most devastated by the eventual reveal because she has been closest to it and missed it; or the one who has mastered the performance of humility so thoroughly she can't tell anymore whether she means it. "Brilliant and humble" at face value is not enough.

---

## The clients (cast composition)

Mixed, deliberately. Not uniformly desperate-and-sympathetic (which would make the wage exploitation unambiguously villainous) and not uniformly entitled or game-playing (which would make the firm quixotic). Most clients are recognizably ordinary people with real grievances and ordinary flaws — some grateful, some not, some who'll leave a one-star Google review after winning their case. The firm helps them all anyway. That is the version where the central question stays open.

---

## Tonal commitments

**Register: bureaucratic-absurd**, not gallows. EU human rights compliance forms are a permanent gold mine. Mr. Pig's earnest speeches that read as accidentally damning on third hearing. Client cases that are tragic and absurd at once. The union as low-stakes labor comedy — strikes nobody notices, demands granted because they were already going to happen, leverage that exists only on paper.

**Excluded.**
- Cruelty humor.
- Punching down at clients.
- Protective irony — the writer signaling distance from caring. This is the failure mode of theme-heavy comedy and kills the register entirely. The moment the game signals "we're too clever to mean this," it's lost.

The pigs-in-suits framing **buys permission** for theme-heavy content that would feel preachy in a realistic register. Use the snouts; don't apologize for them.

---

## STUB/PUTKA (the union)

Both necessary and ridiculous. Materially useful and symbolically diminished. Helps wages and slows the work. Real leverage on paper, mostly performative in practice. **The union is not the answer to the central question.** If it slides into noble-collective-action territory, the question has been answered and the texture is dead. Keep the joke in it.

---

## Structural commitments

**Funny-in-hindsight.** The surface text must be funny on first read AND meaningful on second read. This requires re-traversal: rooms cannot be single-use, NPCs cannot be one-quest vending machines, and a mid-game structural reveal must retroactively recolor earlier content. This is a level-design constraint, not just a writing one.

**Mid-game inflection.** Pinned to chapter 4 in principle. Specific beat to be pinned in the chapter beat-sheet pass. Most likely candidate: the moment the firm's actual financial state becomes legible to the player, or Mr. Pig's voluntary austerity becomes readable as a class blind spot rather than a moral stance.

**Ending posture.** No cathartic resolution. Two acceptable shapes:
1. A player choice (stay / leave / take over / unionize / blow it up) defensible from any angle, ungraded.
2. A small private win that does not resolve the structural questions — you helped this one client, and that mattered, full stop. The firm continues. Mr. Pig continues. You continue.

The cathartic-exposure ending is forbidden as noted above.

---

## Discipline cost (acknowledged)

The crisis-of-values frame requires every character to contradict themselves consistently (not randomly) across five chapters, every reveal to recolor prior scenes, every joke to do double work. This is a hard standard. It is the bet the project is making. The biggest risk is whether the prose can sustain double work for five chapters; the setting and cast are unusually well suited to it.

---

## Open questions (resolve in later phases)

- ~~Final confirmation of Crab = cynic, Whimsy = opportunist (currently tentative).~~ **Pinned 2026-05-05: Crab = opportunist, Whimsy = cynic.**
- Specific beat for the chapter-4 inflection. → phase 4, beat sheet.
- Specific shape of the chapter 6 ending. → phase 4, beat sheet.
- The white-collar client's specific charges, name, and the firm's specific narrow defense. → phase 3, his bible.
- Client roster composition — how mixed, where they sit class-wise. → phase 4, beat sheet.

---

## Recoloring layer priority (PHASE-6 ADDITION FOR HIT #19)

Phase-4 work added six accreting recoloring layers operating across the game. Phase 6 flagged the cumulative tracking burden risk. **Phase 6 commits an explicit priority ranking** so phase-7 production can budget against it:

**Critical (must work — non-negotiable for the spine):**
1. **Mr. Pig's "we're broke" register → chapter-4 inflection.** The reserve number contradicts the framing pattern. Without this, the spine has no concrete evidence.
2. **The chapter-5 family-photo discovery.** The biographical-blind-spot reveal that recolors all the lectures.
3. **Mr. Pig's firm-survival celebration ordering** (firm-first, client-second). The pattern across all five chapters' celebration scenes.

**Significant (should work — strengthen the spine):**
4. **The Pro-Bono Stub** at chapter 5 Beat 8 + full reveal at chapter 6 Beat 10. Adds layers without resolution.
5. **Mr. Pig's "back in my day" lectures.** Five lectures across the game; recoloring lands cumulatively.

**Decorative (could shrink without breaking the spine):**
6. **Plotek's chapter-4 structural reach manifestation** (the Asia audit-mention line specifically). The chapter-2 first visit + chapter-4 second visit + chapter-5 procedural win + chapter-6 newspaper footnote already carry the principle-test thread; the chapter-4 ambient manifestation is a strengthening detail rather than a load-bearing item.

If phase-7 production constraints force shrinking, **cut from Decorative first**. Plotek's chapter-4 ambient manifestation can be reduced or removed without breaking the spine. The chapter-2 first visit and the chapter-5 procedural win + chapter-6 footnote are sufficient.

---

## Status of the methodology document

Methodology promoted to `narrative_revision/methodology.md` (2026-05-05). Phase 1 complete. Phases 2-5 complete. Phase 6 first pass complete (22 hits flagged). Phase 6 remediations applied. Second pressure-test pass pending.

---

## Phase 8 — post-playtest rewrite (added 2026-05-07)

Phase 8 was triggered by stranger-playtest of Chapter 1. Three findings drove the rewrite:

1. **The first issue felt like a fetch quest.** Original Beat 2-3 structure gave the player legal tools before they had met or felt the case's stakes. The client was offstage by design.
2. **Pacing felt rushed.** Each beat delivered its function and exited. No breathing room for character or consequence.
3. **Characters appeared punch-line-y.** Each NPC was doing a register-job and exiting. Phase-4 reframings were applied as labels rather than as space to unfold.

Mechanics, world structure, and the legal spine itself were not flagged. The procedural-defect / procedural-reset legal spine remained canonical.

### Phase-8 deliverables (locked and shipped)

**A — Chapter 1 rewrite (the planting chapter, post-playtest).**

The Chapter 1 audit was supplemented by `narrative_revision/audit/chapter_1_v2.md`. The phase-4 "no new beats" rule was knowingly overridden — playtest evidence trumped pre-playtest scope discipline; the curation board's "playtest before extending" gate had been passed. Two new beats added:

- **Beat 8 — Client meeting at office.** Halina Sikorska (new chapter-1 client) arrives at the firm's dedicated meeting room (NEW interior — phase-8 addition; sub-area within Pig & Swine office). Cula leads the interview with three load-bearing dialogue stances: sympathetic / blunt-procedural / technical. Each stance surfaces different bonus evidence (Mrs. Wójcik's witness statement / postal return-to-sender slip / 1962 lease + 1987 inheritance paperwork). Required evidence surfaces regardless of stance. The cardiologist plant lands once during the meeting — Halina mentions a rescheduled cardiology follow-up due to eviction stress. The fee discussion: 5,000 PLN fixed fee, not a player choice. The literary epigram in any stance: *"You go to a lawyer like you go to a doctor: too late."*
- **Beat 9 — Archive Room research.** Cula and Murrow at the Archive Room. Murrow narrates Article 135-bis § 2 KPC clause-by-clause, applying the rule to Halina's specific facts. Three to four sentences per clause. Output: case theory crystallized.

All existing beats received breathing-room expansion via character-dwell dialogue options (2-3 per scene, no quest impact, each producing a register-revealing line). All eight phase-4 plants preserved. Three new plants introduced: Halina as character; the cardiologist plant; the fee plant.

**β reappearance commitment for Halina:** Chapter 4 (was Ch3 — printer conspiracy) corridor sighting. Approximately 5 lines exchanged. Halina is grateful, visibly diminished. The procedural reset bought her a rehearing; the rehearing she won; and it didn't matter, because the months between Ch1 and Ch4 were enough to do what the eviction would have done. The literary epigram from Ch1 recolors: by Ch4 both halves of the metaphor have come true. **No legal resolution, no narrative resolution.** The withholding-of-articulation discipline carries the moment.

**Article 135-bis § 2 KPC (fabricated; project-canonical text).** Project convention: real KPC article numbers may be cited where their real content fits the case; fabricated numbers use the -bis suffix and sit plausibly near real KPC topical neighbors. The convention applies forward across all chapters.

**English-version dialogue convention (sharpened).** The English-version uses Polish only for proper names of people and places (and PLN currency). No Polish greetings, address forms, common nouns, or idioms in dialogue. Sharpens V1.3 §A.5's "zero-to-one Polish flavor word per scene" rule. Pre-existing canonical content (e.g., Pig's *aplikatura* lecture) is grandfathered; new work follows the strict rule.

**B — Compact criminal-defense Chapter 3 (new chapter inserted).**

A new compact chapter inserted between Chapter 2 (Waldek's eviction defense) and the prior Chapter 3 (printer conspiracy, now Chapter 4). The chapter introduces criminal-defense register to the spine via an ex officio appointment forced on the firm.

- **Client:** Kacper Mazurek (new tenth bible). 19-year-old, homeless, no schooling, foster-care trauma background. Charged with burglary (*kradzież z włamaniem*, KK Art. 279).
- **Outcome:** 1 year imprisonment, suspended for 3 years' probation under KK Art. 70 § 2 *młodociany*. The two constraints converge: the statutory minimum for Art. 279 § 1 (1 year) is also the maximum suspendable under Art. 69 § 1 (1 year). The win is partially Pyrrhic — keeping Kacper out of prison sends him back to the homelessness he was trying to escape.
- **Six beats, ~25-30 minutes runtime.** Office anger (Pig's fury at ex officio assignment + Asia's operational briefing) → walk to detention center (NEW small interior — visitor room within an *areszt śledczy*) → detention scene with Kacper (the load-bearing scene; the canonical line *"Two years? I can do that. Easy."*) → return to office for case prep with Crab → court (phased criminal hearing; three sub-phases) → office return (no celebration; depleted register) → printer-stinger (relocated from Ch2-end to Ch3-end, bridges to Ch4).
- **Whimsy is absent throughout.** Working on Plotek's case; his absence pairs with his presence in the renumbered Ch5 Plotek arbitration. Character development in negative space — the player learns Whimsy won't take indigent criminal defense.

**β reappearance commitment for Kacper:** Chapter 6 finale corridor cameo. Approximately 3-4 lines or non-verbal recognition. Kacper is at the courthouse on a new charge; same calculating-direct register; doesn't blame Cula. The two β returns rhyme — wronged client (Halina) and over-helped client (Kacper) both end up worse than where Cula's intervention left them.

**C — Chapter renumbering cascade.**

Old Ch3 (printer conspiracy / inflection) → new Ch4. Old Ch4 (Mr. Swine returns / recoloring) → new Ch5. Old Ch5 (The Final Brief / synthesis) → new Ch6. The compact criminal chapter takes the new Ch3 slot. All references throughout `story.txt`, `world.txt`, `battle_mechanics.txt`, `narrative_revision/`, and `phase_7_packs/` updated via cascade sed in Stage 13 (story.txt + world.txt + battle_mechanics.txt) and Stage 8 (narrative_revision/ continuity sweep).

### New plant-inventory items added in phase 8 (for re-traversal map)

- **Halina Sikorska as character** (Beat 8 client meeting); reappears in Ch4 corridor sighting.
- **Cardiologist plant** (Beat 8); pays off in Ch4 corridor (visible diminishment, possibly cane).
- **Fee plant** (Beat 8 → Beat 13); 5,000 PLN; firm-survival anchor; compounds with cardiologist plant in Ch4.
- **Article 135-bis § 2 KPC** (Beat 9); project-wide article-numbering convention established.
- **Halina's literary epigram** (Beat 8); recolors at Ch4 corridor sighting.
- **Pig & Swine office meeting room** (NEW interior; sub-area within main office; Beat 8 venue).
- **Kacper Mazurek as character** (Compact Ch3 detention scene); reappears in Ch6 corridor cameo.
- **The "Two years easy" moment** (Compact Ch3 Beat 3); chapter's emotional pivot; recolors at Ch6.
- **Whimsy's absence pattern** (Compact Ch3, all six beats); Plotek folder environmental plant on Whimsy's desk; pairs with Whimsy's Ch5 Plotek presence.
- **The fee-as-loss texture** (Compact Ch3 Beat 1 + Beat 6); the firm loses money on this case; opposite to Halina-fee in Ch1; feeds Ch4 inflection's financial-picture reading.
- **The pre-broken lock** (Compact Ch3 Beat 4 + Beat 5 Phase 1); defense angle.
- **Areszt śledczy visitor room** (NEW interior; single-use; Compact Ch3 Beat 3 only).

### Phase-8 deliverable status

15 stages completed (10 original Halina-rewrite stages + 5 compact-chapter stages, executed concurrently and renumbered to a single 1-15 sequence in the project's task list). Stage 7 (phase-7 V1.* voice-pack updates + V1.4 new draft) and the V3.* compact-chapter voice packs remain as future work — see `phase_7_packs/00_pack_manifest.md` for the post-phase-8 pack count (54 packs total, ~109-140 hours).

The recoloring-layer priority section above is unchanged in priority but expanded in scope: H1-H4 remain Critical; H5-H6 remain Significant; the new V3.* compact-chapter packs are introduced as a chapter-vertical tier, not horizontal — they don't add a new recoloring layer, they extend the β technique into criminal-defense register.
