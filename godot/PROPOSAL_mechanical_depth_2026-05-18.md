# Mechanical-Depth Proposals — Revised

Six-item brainstorm originally framed as "transform the RPG into a more engaging and mechanically robust experience." Reworked here against project canon: PROPOSALS.md §§9–11, PLAN.md §Standing decisions and §Out of scope, `minigames.txt`, and the Halina trust-meter architecture from Session 29.

Framing concern that runs through the original brainstorm: most items convert narrative texture into mechanical pressure, and three of them duplicate systems already approved. Pig & Swine has committed to soft failure (no progress blocks), one closed Casebook resolver, and exactly two committed mini-games. New meters, new mini-games, and JRPG party-slot abilities all cut against those commitments. The items below survive only if they clarify or surface existing systems, or extend them in a strictly additive way.

Labels follow PROPOSALS.md convention: **CUT** (dismiss), **KEEP** (already canon, no work), **DEVELOP** (revised mechanic worth specifying), **DEFER** (good idea, wrong sprint).

---

## 1. Firm-stability meter — CUT

The original proposal: a global stability stat that disables the printer, breaks the coffee machine, blocks NPC assistance, and is restored by client fees (Sikorska's 5,000 zł as a tangible boost).

Three problems make this unworkable as written.

The Ch1 moral question per PROPOSALS.md §11 is *does procedure suffice?* If a fixed fee from Sikorska materially saves the firm, the procedural reset starts paying rent in cash, and the chapter collapses into a cathartic-rescue beat — exactly the shape forbidden by §9 ("the cathartic-exposure shape is explicitly forbidden"). The "we're broke" framing is supposed to be planted in Ch1 and ruptured by the Beat 11 ledger glimpse in Ch3. Pre-loading a stability meter spends that gunpowder four chapters early.

"Printer refuses to print some arguments" is a silent content-cut failure mode. The player will not know which arguments they were denied, which violates the soft-failure rule (PLAN.md §Standing decisions: court-loss never blocks; weak win is the floor). Soft failure means the player always advances and always sees the payoff scene at some grade. A meter that quietly removes options does the opposite.

The "label Asia's sandwich urgent" beat is good writing canon and should survive as a one-line interactable or dialogue option. It does not need a mechanic behind it.

What survives from the original: the firm's penury continues to express itself through *specific* canonical interactables — the printer running joke, the coffee machine objecting, Mr. Pig's pacing. These are scene-specific texture, not a global resource.

---

## 2. Phase 1 → Phase 2 carry-over visibility — DEVELOP

The original proposal mixed two things: a "Judicial Tolerance Stat" and manual evidence equipping.

The Judicial Tolerance Stat already exists as `judicial_patience` per PROPOSALS.md §10. The Phase 2 closing-argument resource maps exactly to what the brainstorm described: ambitious speeches cost patience, procedural-math citations preserve it. No work needed beyond what §10 already authorizes.

Manual evidence equipping is redundant. The Phase 1 → Phase 2 carry-over is load-bearing precisely *because* it is implicit: how the player questioned witnesses sets the fact-flags, and the fact-flags gate which citations are available in Phase 2. Adding an equip step on top duplicates a choice the player already made.

The legitimate gap the proposal pointed at is *visibility*. Right now nothing surfaces to the player which fact-flags they established in Phase 1 or which Phase 2 citations those flags unlocked. The carry-over works mechanically but reads as opaque.

**Develop:** a Phase 2 UI affordance — call it the *Trial Record panel* — that, when the closing round opens, shows the live fact-flags from Phase 1 and the citations they unlocked, color-coded against the citations that remain locked because the underlying fact was never established. Cheap UI work, high comprehension value, zero new mechanics. Specification lives alongside `data/court_rounds/_schema.md`; Code owns implementation in `battle_screen.tscn` / `battle_controller.gd`.

---

## 3. Coffee buff with court-side consequence — DEVELOP, bounded

The buff is already canon: `Procedurally Alert` / `Over-Caffeinated` per `minigames.txt`. The legitimate critique inside the original proposal: the buff is currently flavor-only — there is no observable consequence in court for which grade the player brewed.

What works as a bounded extension:

- **S/A-grade brew** unlocks a *cosmetic-plus-small-bonus* move variant for one Phase 2 citation. Mechanically: a one-time `judicial_patience` cushion (≈ +1) on a single citation, paired with a Whimsy-flavored line. The grade affects *flavor* and a small numeric edge; it does not gate any win condition.
- **D/F-grade brew** adds a vibration animation on Cula's portrait and a one-time `judicial_patience` debit on the first weak move played, surfaced as an in-court Mrożek-register flavor line. No dialogue options are locked.

What gets rejected: the original proposal's "F-grade locks dialogue options near the case board" violates `minigames.txt`'s explicit rule that "neither outcome blocks progress." Buffs nudge; they never gate. The buff exists to make the optional mini-game feel like it mattered, not to punish the player who skipped it.

Scope: this is one judgment-card-shaped writing task plus a tiny `effectiveness.gd` hook. Lands inside the existing Sprint 6 polish window.

---

## 4. Filable incapacity fallback with relational cost — DEVELOP

The strongest item in the original brainstorm. Well-aligned with the Halina trust-meter architecture from Session 29 (eight chapter1 flags, SAVE_VERSION 11, bonus evidence escalation, reveal at trust ≥ 5).

The original proposed cost was twofold: Crab withdraws his "walking of the post," and Halina locks out high-trust evidence. The relational cost half is the right shape — it honors the Ch1 moral spine *does procedure suffice?* by letting the player file a procedurally-available but ethically-wrong argument and pay for it in trust, not in defeat. The case is still winnable on procedure alone; the win is just weaker.

The Crab-withdrawal half needs reformulation. The original framed it as "Crab walks off, time-pressure mechanic kicks in." Real-time pressure is not a mechanic the project has built and PLAN.md §Out of scope doesn't reach for it. The cost should be diegetic and reversible to author:

- **Filing the incapacity argument** sets a new chapter1 flag `incapacity_filed` and pushes Halina trust to ≤ 1 (below the reveal threshold).
- **Crab's withdrawal** translates to specific Phase 1 interactions becoming unavailable for the remainder of the round — his "second pair of eyes" stops surfacing factual defects in witness statements. Concretely: 1–2 Phase 1 press-options keyed to Crab assistance no longer appear.
- **Client reaction** uses a new Halina state at trust ≤ 1 with the canonical line: "The case is not about whether I can read." Locks the high-trust bonus-evidence path already specified in Session 29.

Net effect: the player files, wins on procedure alone, and walks out with no badge, a Halina trust score that closes the bonus evidence, and a Crab line that lands cold in the Day-One Summary. Soft failure preserved; ethical branch real.

Authoring shape: one new state in `halina.json`, one new flag plus migration in `chapter1.json` (SAVE_VERSION bump per the migration test pattern), two Phase 1 press-options gated by `crab_active`. Document the branch in `data/court_rounds/_schema.md`.

---

## 5. Archive interactable density — KEEP as writing, CUT as mini-game

The original proposed a hidden-object search phase in the Archive Room with Asia's password as a key. Two reasons this fails as a mini-game.

First, PLAN.md §Out of scope is explicit: Coffee Brewing and Document Chase are the two committed mini-games. A Ch1 archive search adds a third type. Worse, it pre-empts Document Chase (Ch2) — both are search-and-find loops, and shipping the looser version first weakens the mini-game whose mechanic is the search-and-find.

Second, "Asia's password" reduces Asia from hint-state NPC (per PROPOSALS.md §5, `asia_hints.json`) to key-dispenser. That contradicts her established function and breaks the hint-state authoring pattern that already shipped.

What survives from the proposal: the *interactable density* of the Archive Room. The "panic-level alphabetization" framing is excellent writing canon and should land in-scene. The mechanic is standard interactable design, not a mini-game.

**Develop:** the Archive Room ships with 5–8 inspectable shelves and cabinets, each with one flavor line, one of which contains the Procedural Binder. One Asia hint-state already in `asia_hints.json` points the player toward the right cabinet when the player is on the binder-pickup step. No password gate. Total work: writing 5–8 short interactable lines plus an Area2D placement pass. Sits inside Sprint 3 (Investigation loop) without expanding it.

The contradiction-spotting layer mentioned in PLAN.md §What gets built once vs per-chapter ("Chapter 3's contradiction-spotting and time-pressure layers") is the right home for richer archive mechanics if the interactable density alone reads thin. Defer richer mechanics to Ch3, where the system is already planned.

---

## 6. Three Phase 1 junior signatures — DEVELOP

The original proposal treated the four office characters as a JRPG party with distinct ability slots: Asia as Cooldown Manager, Crab as second-pair-of-eyes, Whimsy as rhetorical-framing/judge-distractor, Murrow as procedural anchor. Two of those (Crab, Murrow) already match canonical recruitment beats. Two (Asia, Whimsy) need rejection or reshaping.

Asia as "Cooldown Manager" invents office crises that need cooldowns, then assigns Asia to manage them. The mechanic justifies itself. Drop. Asia's role is hint-state NPC and transit-system warmth (per PROPOSALS.md §11 character-voice push); she does not appear in court.

Whimsy as "distracts the Judge from decorative gaps in the evidence" is the dangerous one. It permits rhetoric to substitute for evidence, which directly contradicts the judge's load-bearing rule in `story.txt` ("a feeling is not an exhibit"). Whimsy's rhetoric must *combine with* evidence — rhetorical reframing of a Phase 2 citation that *is* already unlocked by a Phase 1 fact-flag. Rhetoric without underlying facts costs `judicial_patience`; it does not substitute for the missing fact.

The reformulated proposal: **three Phase 1 junior signatures**, expressed as keyed press-options inside the witness-confrontation sub-rounds.

- **Crab** — *factual-defects spotter*. While `crab_active`, certain witness statements show an extra "press: factual defect" option that establishes a specific fact-flag (address/renumbering, doręczenie zastępcze posture, lease countersignature). Crab's signature is the cleanest of the three because the recruitment beat already names this function.
- **Whimsy** — *rhetorical reframe*. While `whimsy_active`, certain Phase 1 press-options offer a "reframe" variant that increases `witness_cooperation` payoff on success but costs `judicial_patience` if the witness resists. High-risk, high-reward, off-procedural register. Whimsy never unlocks a fact-flag the underlying questioning cannot reach.
- **Murrow** — *procedural anchor*. Passive: when `judicial_patience` drops below a threshold mid-round, Murrow's portrait surfaces a re-anchor line and restores a small amount of patience. One-shot per round. Mirrors his canonical role without converting him into an active party member.

Authoring shape: each signature is one or two press-option records per Phase 1 sub-round, plus per-character recruitment flags already in `chapter1.json`. The three-character signature set scales to later chapters by adding sub-round content, not by adding new systems.

---

## Scope and priority

Of the six original items, two are pickups requiring fresh design work, two are bounded extensions of existing systems, and two are cuts.

| # | Item | Verdict | Sprint home |
|---|---|---|---|
| 1 | Firm-stability meter | **CUT** | — |
| 2 | Phase 1 → Phase 2 carry-over visibility (Trial Record panel) | **DEVELOP** | Sprint 5 (Court + payoff) |
| 3 | Coffee buff with court-side consequence | **DEVELOP, bounded** | Sprint 6 (Polish + writing pass) |
| 4 | Filable incapacity fallback with relational cost | **DEVELOP** | Sprint 4 or 5 (after trust-meter v1 stabilizes) |
| 5 | Archive interactable density | **KEEP as writing, CUT as mini-game** | Sprint 3 (Investigation loop) |
| 6 | Three Phase 1 junior signatures | **DEVELOP** | Sprint 4 (Casebook Battle System v1) |

None of the four developments require a new core system. Items 2 and 6 land inside Sprint 4–5, item 4 sits on top of the existing trust meter, item 3 sits on top of the existing coffee buff. Items 1 and 5 (as proposed) get rejected with the standing reject-line: "out of scope per PLAN.md §Out of scope."

## Status

Drafted 2026-05-18 in Cowork. Not yet integrated into PROPOSALS.md. Recommend a single editorial pass to promote items 2, 3, 4, and 6 into numbered PROPOSALS.md entries (§§12–15) before any sprint picks them up. Items 1 and 5 (the cuts) do not need PROPOSALS.md entries — they restate existing PLAN.md §Out of scope discipline.
