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

## Status (post-approval, 2026-05-04)

User approved all proposals. Language decision: **English version first; Polish translation may follow.**

| # | Item | Status | Notes |
|---|---|---|---|
| 1 | Casebook is load-bearing; no wild encounters; closed taxonomy; resolver formula | **DONE** | Decisions baked into `PLAN.md` and `AGENTS.md`. `data/tag_taxonomy.json` and `scripts/systems/battle/effectiveness.gd` skeleton committed. |
| 2 | Cut premature district scenes; cut pixel-bound table; clarify "visible" for locked routes | **PARTIAL** | Decisions baked into `PLAN.md` (deferred districts) and `AGENTS.md` (signpost convention). `world.txt` itself still contains the over-specified table — pending dedicated editorial session. |
| 3 | Keep Coffee + Document Chase; defer Scooter and Ski; reframe Final Printer as Casebook battle | **PARTIAL** | Decisions baked into `PLAN.md` (out-of-scope-permanently) and `AGENTS.md` (forbidden patterns). `minigames.txt` still describes Scooter/Ski/Final Printer as mini-games — pending dedicated editorial session. |
| 4 | Split `story.txt` into authoritative spec vs dialogue samples | **PENDING** | 90k-token rewrite. Requires a dedicated session. Until done, agents read `story.txt` as-is and treat sample lines as voice reference, not committed game text. |
| 5 | Asia hint-state table | **PENDING** | Needs reading the Asia sections of `story.txt` and enumerating 8–10 hint states keyed to `chapter1.json` `quest_step_id` values. Should be done before the Chapter 1 dialogue-writing sprint. |
| 6 | Chapter 5 beat list | **DEFERRED** | Not urgent. Lock before *Chapter 4* implementation begins. |
| 7 | Consolidate `design/` into the canon | **PENDING** | One editorial session. Approach (a) recommended: port useful material into the four `.txt` files; freeze `design/`. |
| 8 | Spec gaps: save slots, court-loss, tutorial visibility, language, accessibility | **DONE** | All five settled in `PLAN.md` §Standing decisions and `AGENTS.md` §Stack invariants. Language: English-first. |

## Pending work, prioritized

The remaining `.txt` editorial work is one to two dedicated sessions. Suggested order when you want to do it:

1. **Asia hint-state table** (Proposal 5). Smallest, most blocking — Chapter 1 dialogue-writing sprint cannot ship a polished Asia without it. ~30 minutes.
2. **`world.txt` cleanup** (Proposal 2). Cut the pixel-bound district table; replace the 22-scene listing with the Chapter 1–2 corridor only; codify the signpost-convention for locked routes. ~60 minutes.
3. **`minigames.txt` cleanup** (Proposal 3). Remove Scooter Racing and Ski Slalom sections (replace with a one-paragraph "deferred" note); rewrite the Final Printer section as a Casebook-battle spec. ~60 minutes.
4. **`design/` consolidation** (Proposal 7). Port the Taste Standard examples, voice tables, and visual style canon from `design_bible.md` into `story.txt` (as appendices) or a new `style_canon.txt`; freeze `design/`. ~90 minutes.
5. **`story.txt` split** (Proposal 4). Largest job. Read the file in full, identify the spec/sample boundary, write `dialogue_samples.txt`, leave `story.txt` as authoritative beats only. ~3 hours of focused work, probably split across two sessions.
6. **Chapter 5 beat list** (Proposal 6). Not urgent — wait until Chapter 3 is in progress before drafting.
