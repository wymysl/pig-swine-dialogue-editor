# Editorial Proposals on the Source Spec

This file holds my editorial calls on the four root `.txt` files. Each proposal is one of three types:

- **CUT** — material that's redundant, bloated, or unrealistic for a one-developer-plus-agents project.
- **DEFER** — material that's good but should not be built before Chapter 1 ships.
- **DEVELOP** — places where the spec is thin and I'd recommend extending it before agents start coding.

Nothing here is applied yet. Once you mark each item KEEP / CUT / DEFER / DEVELOP, I'll do the actual editing pass on the `.txt` files (or write the development extensions).

The proposals below are based on a sampling read of the four files — `story.txt` is ~90k tokens, so I have not read every beat. Items marked with † are based on inference from sampled sections; I'll verify against the rest of the file when you greenlight a pass.

---

## 1. The Casebook Battle System is the most important thing in the project, and the riskiest

The Casebook Battle System (`battle_mechanics.txt`) is the single best idea in the spec. Pokémon-style legal-argument battles with three-tag effectiveness (Article + Principle + Context) is genuinely original and gives every chapter an obvious mechanical loop. **Recommendation: KEEP. Make it the load-bearing system.** But:

**CUT — wild encounters in the overworld.** `battle_mechanics.txt` mentions wild-argument encounters as a way to grind judgments and Casebook entries outside court. For a hobby project this is the kind of feature that consumes infinite agent time tuning encounter rates and grind balance. Cut wild encounters entirely. Battles only happen in scripted court rounds and a small number of scripted advocate-challenge encounters. The Casebook fills via fixed in-world rewards (each chapter delivers 2–4 judgments through quests).

**DEFER — Casebook collection completion as a goal.** The "collect 'em all" framing is fun but creates pressure to write 50–100 fully-fledged judgments. For Chapter 1, ship 3–5 judgments (one starter, two from the procedural binder, one optional from the rights memo). If the player ends Chapter 1 with a small Casebook that's clearly going to grow, that's enough.

**DEVELOP — judgment and move taxonomy.** The three-tag system needs the actual taxonomy enumerated before code can implement it. Right now `battle_mechanics.txt` shows examples (article_8, home, proportionality) but doesn't list the closed set. Before any Casebook code ships, write `data/tag_taxonomy.json` with: every Article tag (1–18 ECHR + Polish constitutional articles), every Principle tag (proportionality, individual_assessment, procedural_fairness, ...), every Context tag (home, family_life, expression, assembly, fair_trial, ...). Closed list. Code reads from it. New tags require an artifact.

**DEVELOP — effectiveness resolver formula.** "Super effective / effective / not very effective / no effect / backfires" needs a numeric resolver, not just narrative buckets. Propose: each opponent argument has 3–5 tags with weights summing to 1.0; each player move has 3–5 tags with weights summing to 1.0; effectiveness score = dot product, mapped to the five buckets at thresholds [0.7, 0.4, 0.15, 0, <0]. Backfires happens when the move's primary tag is on the opponent's *strength* list, not its weakness list. This is straightforward to test and easy to tune.

---

## 2. The 128×128 overworld is fine as a coordinate system, expensive as a build target

`world.txt` is right that 128×128 should be the coordinate system from day one. But it then describes 6 districts × 6 routes × ~10 interiors as a target structure, which is ~22 scene files of terrain content. **Recommendation: KEEP the coordinate system; CUT the upfront scene scaffolding.**

**CUT — premature district scenes.** Do not create `legal_quarter.tscn`, `old_town.tscn`, etc. as empty scaffolds. For Chapter 1 we need: `office_street.tscn`, `paragraf_lane.tscn` (just the section the café is on), and one tiny stub for "the visible-but-locked direction in question". Other districts arrive when their chapter does.

**KEEP — the locked-route discipline.** The "Pokémon-style sense of world expansion" requires the player to *see* the locked routes from minute one. Keep the route blockers with their flavor lines. But each blocker only needs to point in a direction; the district behind it doesn't need to exist as a scene yet.

**CUT — the explicit district size table.** `world.txt` includes a table of district pixel bounds (Office Hub x 44–62, y 48–64, etc.). This is over-specified for a build that hasn't started. Replace with a one-paragraph description of relative positions and let Art + Code lay it out organically. The table becomes useful in Chapter 3 or so; until then it just makes agents think they have to build to it.

**DEVELOP — what "visible" means for a locked route.** The spec says routes should be visible but blocked. It should also specify: how much of the locked route is rendered? One screen-edge of dummy tiles? A signpost only? An Area2D that triggers a flavor line as soon as the player approaches? Pick one convention and apply it consistently. My recommendation: a signpost or NPC at the choke point, with `locked_text` flavor; the route itself is not rendered until its chapter unlocks.

---

## 3. The mini-game roster is too large for the project to afford

`minigames.txt` lists Coffee Brewing, Document Chase, Scooter Racing, Ski Slalom, Final Printer. Five mini-games is a lot of bespoke scenes. **Recommendation: KEEP Coffee + Document Chase; DEFER Scooter Racing and Ski Slalom; reframe Final Printer.**

**KEEP Coffee Brewing.** The rhythm-timing version in `minigames.txt` is a good first mini-game and the spec is detailed enough to implement directly. Fits Chapter 1 as optional buff.

**KEEP Document Chase.** Required for Chapter 2 per `story.txt`. The "stamp 10 of 15 papers in 30s" mechanic is simple and doesn't require new infra.

**DEFER Scooter Racing and Ski Slalom.** These are Chapter 4 (Swine returning from Japan) flavor and they are genuinely hard to make funny — racing mini-games either feel cheap (auto-runner) or burn weeks (driving model). Ship Chapter 4 without them, replace with brief travel-narrative cutscenes or a one-screen interactable that tells the joke faster. If after Chapter 4 ships you miss the racing mini-game, build it then.

**DEVELOP Final Printer as a Casebook battle, not a mini-game.** The Final Printer Boss Battle is the climax of the printer running joke, but `minigames.txt` doesn't make clear what genre it is. Recommendation: make it a Casebook battle against an industrial-printer opponent with absurd argument-strength values, where the player has accumulated specific judgments over four chapters that finally apply. This honors the printer arc, reuses the load-bearing system, avoids inventing a one-off mini-game for the climax. The narrative payoff is that the firm's office printer (which has been making sad noises for four chapters) is *not* the antagonist — the industrial printer is.

---

## 4. Story.txt is doing two things that fight each other: it's a design doc and it's a draft

†Based on what I sampled, `story.txt` mixes (a) authoritative beat-by-beat chapter design and (b) sample dialogue lines that read as drafts. **Recommendation: split into two files.**

- `story.txt` becomes the design beat structure — what happens, in what order, what NPCs do, what gates are required. Authoritative.
- `dialogue_samples.txt` (new) holds illustrative lines for tone reference — Mr. Pig opening, Asia hint states, Murrow case briefing, etc. These are *examples*, not committed game text; the real game text lives in `data/dialogues/dialogues.json` written by Design agents using these samples as voice reference.

This stops agents from quoting `story.txt` lines verbatim into the JSON (which would skip the Taste Standard pass) and makes it clearer when the human is updating the spec vs the example library.

---

## 5. Asia's role needs one more clarification

Asia is a great addition. `story.txt` describes her as "repeatable hint NPC" with progress-keyed states. **DEVELOP — write the explicit hint-state table.** The spec gives examples but doesn't say what Asia says when the player is between known states (e.g., after collecting the binder but before recruiting Crab). Recommendation: enumerate 8–10 hint states in `story.txt` that map cleanly to chapter1.json `quest_step_id` values, plus 2–3 idle flavor lines that play when no progress-specific hint applies. Then Design has a clear authoring target.

---

## 6. The chapter arc is good but Chapter 5 is underspecified relative to its scope

†Chapter 5 ("save the entire legal district") is the climax. From sampling I see the Final Printer reference and the "Pig & Swine was always the firm worth saving" thesis, but I don't see a clear act structure for what the player actually *does* in Chapter 5. **DEVELOP — write the Chapter 5 beat list at the same density as Chapter 1.** Without it the project will plan for 4 chapters' worth of work and then discover Chapter 5 needs as much work as the rest combined. This isn't urgent; do it after Chapter 1 ships. But before *Chapter 4* ships, Chapter 5's structure should be locked.

---

## 7. The design canon is duplicated

Some material that lives in `design/design_bible.md` (Taste Standard, character voice profiles, running jokes, visual style canon, audio canon, court design principles) appears to have been carried into `story.txt` partially. **Recommendation: do an explicit consolidation pass.** Either (a) port everything useful from `design/` into the four `.txt` files and freeze `design/`, or (b) keep `design/design_bible.md` as a separately-loaded "voice and style" reference and drop those topics from the `.txt` files. I recommend (a) — one source of truth is better than two near-equivalent ones. This is a one-session editorial task once you greenlight it.

---

## 8. Things the spec doesn't address that it probably should

These are gaps I noticed. None are blockers; all should be settled before the relevant chapter is implemented.

- **Save slot count.** One save slot or three? `story.txt` doesn't say. Recommendation: one slot, autosave on chapter transitions and at quest milestones, plus one manual save in the case bag. New Game prompts to overwrite.
- **Failure recovery for the entire run.** If the player loses Chapter 1 court, what happens? `minigames.txt` is clear that mini-game failure is soft. The spec is less clear about court-loss. Recommendation: court-loss never blocks chapter completion; produces a weaker variant (less reputation, no badge, weaker Swine postcard). Chapter 1 specifically: weak win is the floor.
- **Tutorial visibility.** New player needs to learn movement, interact, dialogue, docket, case bag, casebook. The spec implies "Asia teaches naturally" but doesn't decide whether there's an explicit overlay or not. Recommendation: a one-line floating prompt above the player for the first instance of each input ("[Space] to interact"), then never again. No modal tutorial. No popup.
- **Multilingual content.** Polish-legal flavor is core. Are any actual Polish strings rendered, or is the whole game in English with Polish institutional names? Recommendation: English UI, Polish institution names spelled correctly (KPC, doręczenie zastępcze) with no diacritic substitution, no other Polish strings until i18n exists. MY DECISION: LET'S MAKE AN ENGLISH VERSION; POLISH TRANSLATION MAY FOLLOW.
- **Accessibility.** Pixel art is fine, but text contrast and color choices need a minimum bar. Recommendation: every UI text element passes WCAG AA contrast against its background; no information conveyed by color alone (e.g., judgment effectiveness shown by both color and text label).

---

## 9. Thematic reframe — crisis of values as the spine

The project has committed to a substantive thematic reframe. The game is now about a crisis of values, with Pig & Swine's human-rights ethos held in tension with its internal labor practices. The spine, as a single organizing question: **"does it matter why someone helps you, if they help?"** Mr. Pig is rewritten as a half-right idealist whose voluntary austerity is also a class blind spot; the juniors become a stance-trio (true believer / cynic / opportunist) rather than three character backstories; a new principal client is added — a rich white-collar defendant whose case tests whether the firm's universal-principles ethos survives contact with someone who weaponizes it; and the project commits to a funny-in-hindsight surface that requires re-traversal of spaces and a mid-game structural inflection. The ending is no-cathartic-resolution; the cathartic-exposure shape (firm exposed, juniors win, union triumphs) is explicitly forbidden.

**Scope.** This is not a Proposal-1-through-8-sized editorial call. It touches `story.txt` chapter beats, `style_canon.txt` voice and tone, `data/voice_references/` for characters whose stances are now sharper, and a chapter-by-chapter audit. It does not touch the Casebook Battle System, the world structure, or the Godot build's Sprint cadence.

**Status.** Decisions captured in chat brainstorming, 2026-05-05. Detail in `../narrative_revision/00_decisions.md`. Methodology for executing the reframe (phased: audit → bibles → beat sheet → re-traversal map → adversarial pass → writing) currently in chat history only; will be promoted to `../narrative_revision/methodology.md` before phase 2 begins. No `.txt` editing has happened yet — the reframe is at the decision-and-bible-stage; the writing phase comes after the per-character contradiction bibles stabilize.

**Pre-work that should not be lost.** A previously proposed fourth junior named Camilla — "blonde, brilliant, humble" — was rejected for lack of mineable contradiction. Logged so the addition does not quietly return. The white-collar client survives review and joins the canonical client roster.

---

## 10. Court Round splits into two phases (witness fact-finding → closing argument)

`battle_mechanics.txt` treats Court Rounds as undifferentiated turn-by-turn exchanges between player principles and opponent arguments. Polish trial structure separates witness fact-finding from closing argument (*mowy końcowe*), and Chapter 1's spec in `story.txt` already implies this split (client meeting → archive research → court readiness → win three rounds). **Recommendation: DEVELOP — make the split explicit in the battle controller and in each Court Round's data file.**

A Court Round becomes two phases, both implemented as sub-controllers within `battle_controller.gd`:

**Phase 1 — Fact-finding.** One or more witness-confrontation sub-rounds. Player presses statements or presents evidence. Resource: a new `witness_cooperation` counter per witness (distinct from `judicial_patience`). Quality of play determines how much of the pre-encoded "full truth" the player establishes, which sets case-state flags consumed by Phase 2.

**Phase 2 — Closing argument.** One sub-round before the judge, modeled on Polish *mowy końcowe*. Judge raises counter-questions ("Article 6 doesn't apply, these aren't criminal proceedings — distinguish"); player cites principles from the Casebook. Resource: `judicial_patience` as already specced. Available citations are gated by Phase 1 flags. A judgment can sit in the Casebook and still be unciteable in closing if the underlying fact was never proved at trial.

The load-bearing design move is the Phase 1 → Phase 2 carry-over. If the carry-over is absent, the closing round collapses to flashcards. The carry-over is what makes a sloppy questioning round actually cost the player when they reach the judge, and it lets the procedural reset in Chapter 1's spec follow from gameplay instead of from a scripted win/lose script.

**Chapter scope.** Procedural and ECHR-substantive citations are not mutually exclusive. Chapter 1 leans procedural — KPC Article 135-bis § 2 is the load-bearing remedy per `story.txt` Beat 9 archive research — and ECHR flavor is welcome where it fits (an Article 8 family-life thread woven around the wrongful-eviction frame, for instance). Later chapters increase the substantive proportion as the Casebook fills and the meta-plot widens (Plotek thread, chapter-3 ledger inflection); landmark cases such as Engel and Salduz come online when the cases earn them. The two-phase structure itself is chapter-agnostic.

**Authoring shape.** Each Court Round data file at `data/court_rounds/<chapter>_<round>.json` carries (a) a Phase 1 block: witness statements, evidence-gated press/question options, `witness_cooperation` budget, fact-flags set by outcomes; (b) a Phase 2 block: judge counter-questions, available principle citations keyed to Phase 1 fact-flags, `judicial_patience` deltas, weak/strong-victory branch.

**v1 cut still holds.** The two-phase split is additive to the existing v1 cut from `battle_mechanics.txt`: one encounter type (Court Round), one or two judgments × 3–4 principles per chapter, no ally support, no stance-flavored move lines, no Wild Arguments (already permanently out of scope per PLAN.md). Allies, stance flavor, and the full taxonomy remain long-term targets in `battle_mechanics.txt`.

**Status.** Proposed 2026-05-12 in a Cowork conversation that began with "the game is too much walking and reading." Not yet integrated into `battle_mechanics.txt`. Pre-work: Design sketches a one-page `data/court_rounds/_schema.md` before Code starts PLAN.md §Vertical slice plan step 4, so `battle_controller.gd` implements both sub-controllers from day one. Retrofitting Phase 1 onto a Phase-2-only prototype is the order most likely to derail the slice.

---

## 11. Narrative arc structure — five spines and a five-act shape

The chapter content in `story.txt` is largely written, but the structural relationship between chapters has been implicit until now. Cowork conversation 2026-05-12 produced an explicit shape that names what each chapter is doing and what the inter-chapter spine carries. **Recommendation: KEEP the existing chapter content; DEVELOP the structural framing in `style_canon.txt` and (eventually) `story.txt` so the arc is legible to the writer who picks up phase-7 voice work.**

Five spines run in parallel at different rates:

**Episodic plot (Rumpole / Mortimer).** Case per chapter, each self-contained with a clear win or weak-win. The player can stop at any chapter break and feel they've seen something complete.

**Mystery (Tokarczuk re-traversal).** What's actually going on with the firm's finances and Mr. Pig's framing. The "we're broke" planting in Ch1, the Beat 11 ledger rupture in Ch3, the Ch4 family-photo retraversal, the Ch5 incomplete resolution (Murrow closes the ledger; the player infers).

**Moral question per chapter (Dekalog).** Each chapter centers one moral question the case forces.

- Ch1 — *Does procedure suffice?* The Sikorska procedural reset wins the case; the harm doesn't unmake itself. The Ch4 corridor sighting (see below) earns the question retroactively.
- Ch2 — *Do the firm's universal principles survive contact with someone who can pay for them?* (Plotek's first detention visit.)
- Ch3 — *What does voluntary austerity owe imposed poverty?* (The Assigned Case: Kacper — 19, homeless, ex foster-care — runs concurrent with Beat 11 ledger glimpse and STUB founding. The class blind spot named in §9 thematic reframe lands here in plot form: the firm glimpses its hidden reserve while Cula defends someone whose poverty is not chosen.)
- Ch4 — *What does the firm owe — clients, juniors, itself?* (Family-photo retraversal + Swine's return + Sikorska corridor.)
- Ch5 — *Does the firm deserve to survive?* (Final Hearing. The answer is never asserted.)

**Character (Kundera).** Cula moves from outsider precision to inside-the-firm complicity. The three-branch ending is computed from accumulated flags. The juniors lock in their stance-trio positions by Ch2 and develop across chapters in what they reveal; backstory is not the engine. Mr. Pig's half-right idealism unravels without collapsing.

**Surface comedy (Mrożek).** The firm's day-to-day procedural absurdity continues throughout. Maritime metaphors, the printer running joke, the Tram 17 Oracle, Asia's transit-system practical warmth. The texture that keeps the moral spine from going heavy.

**The act-shape that emerges:**

- **Act I (Ch1) — Arrival.** Cula joins the firm. Procedure wins. The "broke" framing is planted.
- **Act II (Ch2) — Test.** Plotek introduces moral pressure. The juniors take stances.
- **Act III (Ch3) — Inversion.** The Assigned Case: Kacper (19, homeless, ex foster-care; ex officio appointment; *areszt śledczy* visit with stance choice). Mid-game structural inflection runs concurrent — the ledger glimpse ruptures the player's understanding of the firm's "we're broke" framing while Cula is defending someone whose poverty is involuntary. STUB founding. Night register.
- **Act IV (Ch4) — Retraversal.** Earlier spaces and characters seen again with new meaning. The mystery clicks into place. Cula's ending crystallizes. Sikorska corridor sighting (see below).
- **Act V (Ch5) — Hearing.** Final Casebook battle. Three-branch ending. Murrow closes the ledger. No catharsis, no exposure-payoff.

The structural fingerprint of the inspirations (per `style_canon.txt` §9): a Tokarczuk shape (re-traversal at III/IV) with a Kundera ending (irony, three branches, no catharsis), Hrabal voice running through Mr. Pig's interiority, Mrożek surface comedy, a Dekalog moral spine, and a Rumpole episodic structure.

**Sikorska Ch4 corridor sighting — texture.** The plant exists in canon (Ch1 Beat 8 epigram *"You go to a lawyer like you go to a doctor: too late"*; `cardiologist_plant_landed` flag; "recolors at Ch4 corridor sighting" references at `story.txt` lines 608, 640, 1164). What the scene should land: Cula encounters Halina in the district-court corridor between hearings. She is visibly worse than in Ch1 — the eviction action continued past the procedural reset (appeal, remand, or follow-up petition; phase-7 voice work picks the specific procedural posture). She talks about her cardiologist. The Ch1 epigram is referenced again, this time with the second half (the doctor) live. She does not blame the firm. The procedural reset was real. The harm continued anyway. Cula's reaction: silent, observational, Kundera-essayist register. He stays in the corridor and does not speak.

**Tram 17 Oracle.** The recurring chorus NPC on Marszałkowska. Function, geographic-joke note, sketch lines per chapter, and restraint rule are codified in `style_canon.txt` §8 ("The Tram 17 Oracle (recurring chorus NPC)") — one cryptic line per chapter mapped to the moral question above.

**Character voice — literary-register pushes.** Per-character pushes mapping each cast member to a literary register (Cula → Kundera, Mr. Pig → Hrabal, Murrow → Mrożek, Crab → stance-trio technical, Whimsy → Rumpole, Asia → Tokarczuk/Duszejko, Mr. Swine → Ch5 load-bearing sincerity) are added inline to `style_canon.txt` §2 "Voice references" as "Inspirations push" bullets per character.

**Status.** Proposed 2026-05-12 in Cowork. Codification distributed across files this session: this proposal (structural framing), `style_canon.txt` §2 per-character inline pushes, `style_canon.txt` §8 new Tram 17 Oracle sub-section. No `story.txt` edit yet — the act-shape and Sikorska corridor texture are decisions awaiting a dedicated editorial session to fold into `story.txt` per the existing pattern.

**Pre-work.** None blocking. The structure can be referenced as-is. The eventual `story.txt` editorial pass should: (a) add an "Arc structure" header section near the top of `story.txt` naming the five-act shape and moral questions; (b) flesh out the Ch4 Sikorska corridor sighting scene at beat level using the texture above; (c) place the Tram 17 Oracle encounter in the world-text of Marszałkowska routes.

---

## Status (post-approval, 2026-05-04)

User approved all proposals. Language decision: **English version first; Polish translation may follow.**

| # | Item | Status | Notes |
|---|---|---|---|
| 1 | Casebook is load-bearing; no wild encounters; closed taxonomy; resolver formula | **DONE** | Decisions baked into `PLAN.md` and `AGENTS.md`. `data/tag_taxonomy.json` and `scripts/systems/battle/effectiveness.gd` skeleton committed. |
| 2 | Cut premature district scenes; cut pixel-bound table; clarify "visible" for locked routes | **DONE** | Decisions baked into `PLAN.md` (deferred districts) and `AGENTS.md` (signpost convention). `world.txt` has been cleaned up to reflect these decisions. |
| 3 | Keep Coffee + Document Chase; defer Scooter and Ski; reframe Final Printer as Casebook battle | **DONE** | Decisions baked into `PLAN.md` (out-of-scope-permanently) and `AGENTS.md` (forbidden patterns). `minigames.txt` has been updated to reflect these decisions. |
| 4 | Split `story.txt` into authoritative spec vs dialogue samples | **DONE** | Dialogue samples extracted to `dialogue_samples.txt` and `story.txt` cleaned up. |
| 5 | Asia hint-state table | **DONE** | Written and incorporated into `asia_hint_states_ch1.json` and merged into the runner. |
| 6 | Chapter 5 beat list | **DEFERRED** | Not urgent. Lock before *Chapter 4* implementation begins. |
| 7 | Consolidate `design/` into the canon | **DONE** | Ported into `style_canon.txt` and `design/` was removed. |
| 8 | Spec gaps: save slots, court-loss, tutorial visibility, language, accessibility | **DONE** | All five settled in `PLAN.md` §Standing decisions and `AGENTS.md` §Stack invariants. Language: English-first. |
| 9 | Thematic reframe (crisis of values as the spine) | **PENDING** | Decisions captured in `../narrative_revision/00_decisions.md`. Phased methodology in chat; bible-writing and chapter-audit phases not yet started. No `.txt` edits yet. |
| 10 | Court Round splits into two phases (witness → closing); load-bearing fact-flag carry-over; `witness_cooperation` counter for Phase 1 | **DONE** | `data/court_rounds/_schema.md` sketch completed. `battle_controller.gd` structure established. |
| 11 | Narrative arc structure: five spines + five-act shape with moral-question-per-chapter mapping; Sikorska Ch4 corridor texture; Tram 17 Oracle chorus on Marszałkowska | **DONE** | Integrated into `style_canon.txt`. |

## Pending work, prioritized

The remaining `.txt` editorial work is one to two dedicated sessions. Suggested order when you want to do it:

1. **Thematic reframe (Proposal 9)**. Phased methodology in chat; bible-writing and chapter-audit phases not yet started.
2. **Chapter 5 beat list** (Proposal 6). Not urgent — wait until Chapter 3 is in progress before drafting.
