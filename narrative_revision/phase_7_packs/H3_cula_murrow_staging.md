# Phase 7 Pack H3 — Cula-Murrow staging (Beat 11 + Beat 14)

**Goal:** specify the staging for two silent moments that carry the spine's most delicate writing-discipline:
1. **Chapter 4 Beat 11 inflection.** Murrow interrupted mid-update by phone; Cula glimpses the ledger entry (operating-account reserve, 285,400 PLN); Murrow returns and registers internally that the ledger has been visible (single-sided acknowledgment). No dialogue, no music sting, no camera flourish.
2. **Chapter 6 Beat 14 final image.** Murrow at his desk finishing a notation (chapter-6 case proceeds added a small line; reserve has gone up slightly); Cula passes; Murrow closes the ledger and places it in the drawer; both file the moment without explicit eye contact.

**Why this is one of the first sessions:** the spine's most delicate writing-discipline item. Per phase-6 Hit #20: doubled unspoken-acknowledgment moments make both more fragile; phase-6 commits the chapter-4 acknowledgment as single-sided (Murrow notices internally, Cula does not see him notice) and the chapter-6 final image as shared-spatial without explicit eye contact. **The user reviews directly; the model assists on framing language.**

**This is largely visual scripting / stage direction, not dialogue.** No dialogue is authored in this session. The deliverable is two staging specifications written at the level of detail Godot scene scripts can use.

**Estimated session length:** 1-2 hours. Shorter than H1/H2 because there's less content; longer than expected because restraint is the work, and AI is least good at restraint.

**How to use this pack:** open a new Claude conversation. Upload this pack. Issue the §F drafting prompt at the bottom. Hand the result to a second model with §G for hostile critique. **You should expect to write much of the staging yourself; the model assists on word choice and beat sequencing.**

---

## §A — General AI tells (relevant subset for staging)

Most general AI tells apply to dialogue. For staging specs, the relevant scrub items:

- **No music sting** for either moment. AI tends to suggest emotional underscoring at narrative beats. **Cut.** Both moments use ambient audio only (per style_canon.txt §5: "Music changes on room transition. Crossfade defaults are in world.txt; do not invent per-room overrides without flagging them."). Neither Beat 11 nor Beat 14 final image requires a music change.
- **No camera flourish.** No zoom-in, no slow pan, no cinematic emphasis. The visual is normal staging. The player notices because the player is paying attention; the engine does not signal.
- **No internal narration.** Cula does not have a thought bubble, monologue, or text overlay describing what he sees. The visual is the visual.
- **No "and that's when X realized" register.** AI loves to write staging notes that diagnose the moment's significance for the reader. **Cut.** The staging notes describe what happens visually; the significance is invisible to the engine.
- **No dramatic pauses written in.** A staging spec that says "[long pause]" or "[meaningful silence]" is doing AI work. The player's experience of the pause is determined by the engine's pacing; the spec describes what is on screen.
- **No "the player feels..." asides** in the staging notes. The notes describe the camera, the character blocking, the object states. The player's emotional response is a consequence; it doesn't get described.

**Stylistic disciplines for staging specs:**

- Concrete describable elements: where each character is, what their sprite is doing (idle, walking, sitting), what objects are in frame, what state those objects are in (ledger open, drawer closed, lamp on).
- Time annotations in seconds where relevant (e.g., "Murrow's absence: ~60 seconds of in-game time").
- Trigger conditions (e.g., "When Cula's collision box enters the area defined by Murrow's desk_proximity zone, set chapter4.glimpsed_ledger_anomaly = true").
- No subjective language. "The moment lands quietly" is not staging; "Murrow's sprite returns to its idle pose; no animation flourish" is staging.

---

## §A.5 — Language convention (English version, applies to ledger entry text)

**The visible ledger entry at Beat 11 is the only player-facing text in either of these scenes.** Phase 4 specifies the entry as **"Konto operacyjne — saldo bieżące: 285 400 PLN"** (operating account — current balance: 285,400 PLN). This is one of the project's deliberate Polish-flavor texture moments — the ledger is a real Polish-accounting document and reads as such.

**For the English version: the visible Polish text is acceptable** because (a) it's brief, (b) the meaning is clear from context (the number is the load-bearing content; the player understands "operating account current balance" from the structure even without translation), and (c) the Polish anchors the scene to the Warsaw setting visually. **The English-localization rule does not require translating the ledger entry's on-screen text** — the entry is set dressing, not dialogue.

**However:** if the staging spec calls for an English subtitle / glossary tooltip / accessibility caption that translates the entry for the player, that is acceptable and recommended. Phase 7 visual scripting decides whether to provide an English gloss alongside the Polish ledger entry.

**For all other staging text in this pack (notes, descriptions, trigger conditions, engine notes): English only.** The staging spec is a working document; it is in English. Polish-borrowed legal vocabulary (sąd rejonowy, pełnomocnictwo, etc.) does not appear in the staging notes.

**Reminder of the broader project rule:** dialogue in the English version does not borrow Polish-legal vocabulary. See `ai_voice_constraints.md §1.5` for the full language convention.

---

## §B — Per-character constraints

### Murrow (the silent character in both scenes)

**Voice essence:** understated, archival, faintly amused. **In both scenes Murrow says nothing.** The scenes' design depends on his silence.

**Will not say (in either scene):**
- Anything to Cula about the ledger.
- Anything reassuring or acknowledging.
- Anything emotional.
- Anything that breaks the archivist's neutrality without being asked precisely.
- "I knew you'd see it eventually" or similar acknowledging-the-glimpse meta-reference.

**Will not do (visually):**
- Make eye contact with Cula in either scene.
- Stop his work to acknowledge Cula.
- Pause meaningfully in a way the player would interpret as theatrical.
- React to Cula's presence with any animation beyond his ordinary idle.

**AI tells most vulnerable to (visual scripting):**
- **Reaction shots.** AI will write "Murrow looks up at Cula" or "Murrow's eyes meet Cula's." **Cut both.** Murrow does not look at Cula in either scene. In Beat 11, Murrow's "internal observation" of the ledger having been visible is conveyed by his sprite glancing at his own desk on return — not at Cula. In Beat 14, Murrow's awareness of Cula passing is conveyed by his closing the ledger as Cula enters the camera frame — not by looking at Cula.
- **Theatrical pauses.** AI will write "[Murrow pauses]" or "[Murrow holds a beat]." Cut. Murrow's normal pace is what the player sees.
- **Emotional cues.** "Murrow looks pained" / "Murrow's expression softens." Murrow's portrait does not appear in either scene; he is on-screen only as his pixel-art office sprite. No facial expressions are conveyed.

**Quick-reference for staging:** Murrow is at his desk. He moves through ordinary work. Phone rings (Beat 11) — he steps out. Returns; resumes. Beat 14: at his desk, makes a notation, closes the ledger, drawer, returns to other work. **In both scenes he never looks at Cula.**

---

### Cula (the player character in both scenes)

**Voice essence:** observational, dry, restrained. **In both scenes Cula says nothing.** No internal narration, no thought bubble, no observation line.

**Will not say (in either scene):**
- Anything about the ledger.
- Anything to Murrow.
- Any thought-text or internal monologue.
- Any line at all.

**Will not do (visually):**
- Stop walking when he sees the ledger entry. Cula's path past Murrow's desk is normal traversal pace.
- Look at Murrow when Murrow returns (Beat 11).
- Pause at the ledger after seeing it. The glimpse is the moment; Cula continues.
- Visibly react in any way the player would interpret as theatrical.

**AI tells most vulnerable to (visual scripting):**
- **Internal narration text overlay.** AI may suggest "Cula thinks: that number doesn't match what Pig has been saying..." or similar. **Cut categorically.** The player sees the entry; Cula does not articulate.
- **Pause animation when Cula passes the desk.** AI may suggest the player's character pauses. Cut. Normal traversal.
- **Reaction shots / sprite expressions.** Cula's sprite does not have a special "noticed-something" animation. Same idle pose / walk cycle as always.
- **Cula looking at Murrow when Murrow returns (Beat 11).** Cut. The acknowledgment in Beat 11 is single-sided — Murrow registers; Cula does not visibly receive.
- **Cula speaking under his breath.** Cut. He is silent.

**Quick-reference for staging:** Cula is the player character; the player controls his movement. The Beat 11 glimpse triggers automatically when Cula's path passes Murrow's desk during the open-ledger window. The Beat 14 final image triggers when Cula's path enters the camera frame around Murrow's desk in the ending sequence. **Cula's sprite shows no special reaction animation in either scene.**

---

## §C — Beat sheet excerpts (the two scenes)

### Chapter 4 Beat 11 — INFLECTION (post-phase-4 + phase-6 staging)

**(From `narrative_revision/beats/chapter_3.md`. Excerpt of the inflection's beat-by-beat sequence.)**

> ### Setting
>
> - **Time:** late evening. One of the canonical nocturnal beats per `style_canon.txt §8`.
> - **Location:** Pig & Swine Office, work area near Murrow's desk.
> - **Personnel present:** Cula, Crab, Whimsy, Murrow (briefly absent — see step 2 below), Mr. Pig (in his corner having a maritime crisis), Asia (on the phone with the courier service), Bajtek (assembling the technical statement).
> - **Mood:** urgency under fatigue.
> - **Lighting:** lamps on. Coffee machine has been unplugged (Asia's second unplugging this year — `style_canon.txt §3`).
>
> ### Beat structure (the inflection)
>
> The filing-prep scene runs ~2-3 minutes of in-game time:
>
> 1. **Setup.** Murrow announces what's needed for the filing... [Pig delivers his **third "back in my day" lecture** here — handled in Pack H2.]
>
> 2. **Murrow is interrupted mid-update** (Phase-6 Hit #8 revision). The phone rings — Asia is on the other line transferring a courier callback that needs Murrow's signature confirmation. Murrow says something brief and short-declarative: *"One moment."* He steps out of the work area to take the call at reception. **He does not close the ledger because he intends to return immediately.**
>
> 3. **Mr. Pig in his corner.** Maritime metaphor at peak. [Pig's lecture-3 maritime line — handled in Pack H2.]
>
> 4. **Cula moves to the case file cabinet.** Crab and Whimsy are on the other side of the work area, assembling the technical exhibits. Cula crosses near Murrow's desk to reach the cabinet. **The ledger is open in Cula's path of natural movement.** The page is visible.
>
> 5. **THE GLIMPSE.** Cula's eye catches the page for the moment it takes to walk past it. **What Cula sees:** an entry near the top of the visible page reading **"Konto operacyjne — saldo bieżące: 285 400 PLN"** (operating account — current balance: 285,400 PLN). Below it, the line has been carrying steady values for the previous several months. The handwriting is Murrow's, careful and consistent across months.
>
> 6. **The thought is shelved.** Cula does not stop. Cula does not look longer. Cula does not look at Mr. Pig. Cula takes the procedural notice from the case file cabinet and continues toward the team's working area.
>
> 7. **Murrow returns from the call** (Phase-6 Hit #10 + #20 revision — single-sided acknowledgment). He carries the courier-confirmation receipt. He sees Cula at the cabinet. **He glances at his own desk and registers that the ledger is still open — a half-second observation, internal to him.** He does not look at Cula; Cula does not look at him. The moment is single-sided: Murrow notices that someone has been past his desk while the ledger was visible. He files the observation. He picks up the stamp from his desk, places it back, and resumes his work. Cula returns to the team.
>
> 8. **Filing assembly.** The team finishes assembling. [Phase 7 voice work specifies short urgent-filing-prep dialogue for all four (Cula, Crab, Whimsy, Murrow). The dialogue is about the case, not about what just happened.]
>
> ### Phase-4 staging notes
>
> - **No music sting.** The inflection has no audio cue.
> - **No camera move.** The visual is normal staging.
> - **No flag-set notification.** A flag is set internally (`chapter4.glimpsed_ledger_anomaly = true`) but no UI surfaces it.
> - **The ledger entry remains visible after Murrow returns.** Murrow does not close it. Re-approaching Murrow's desk produces no additional dialogue.

### Chapter 6 Beat 14 — FINAL IMAGE (post-phase-4 + phase-6 staging)

**(From `narrative_revision/beats/chapter_5.md`. Excerpt of the final image's beat-by-beat sequence.)**

> 9. **(N) THE FINAL IMAGE — Option C, revised for phase-6 Hit #16.** Phase 4 commits the final image. **Phase 6 revision:** the chapter-6 ledger is visibly different from the chapter-4 ledger. Specifically: **Murrow is at his desk, finishing a notation. The chapter-6 case proceeds have just added a small line to the ledger; the reserve has gone up slightly.** As Cula passes, **Murrow closes the ledger and places it in the drawer.** The closing is the visual difference. The system has absorbed the chapter-6 win without changing.
>
> - The image is intimate rather than illicit: Murrow is present, working, professional. Cula is passing on ordinary office traversal.
> - **Cula sees the line being made and the ledger close.** Murrow sees Cula see; both file the moment. Neither speaks. The shared spatial moment carries the unspoken acknowledgment without explicit eye contact (per Hit #20 revision).
> - The structure persists. The chapter-6 win is in the ledger as a small entry. The reserve has grown. The wages will not change. Phase 7 visual scripting implements with restraint.
> - This is the spine's closing image. The chapter-4 inflection's specific object lands one final time, modified.
> - No music sting. No camera flourish. Brief.

---

## §D — Bible excerpts: Murrow + Cula relevant rows

### Murrow — relevant cross-chapter and per-scene notes

**(From `narrative_revision/bibles/murrow.md`.)**

> **Beat 11 — interrupted mid-update by a courier-callback phone transfer** (phase-6 revised staging for Hit #8). The chapter-4 inflection happens in the minute Murrow is absent. The ledger is open on his desk because he has been working from it during the urgent-filing prep and the phone call interrupts before he closes it. Cula glimpses it during that minute. **Murrow returns and registers — single-sidedly — that the ledger has been visible to someone walking past.** Per phase-6 revision for Hit #20: Murrow notices internally; Cula does not need to receive the look. The unspoken acknowledgment at this stage is one-sided. Phase 7 staging implements with restraint.

> **Beat 10 — no staged Cula-Murrow acknowledgment** (phase-6 revision for Hit #20). The original phase-4 plan offered three staging options for a Beat 10 confirmation moment between Cula and Murrow. Phase 6 flagged that pairing this with the chapter-4 inflection's eye-contact moment created two fragile staged moments competing for the spine's most delicate writing-discipline weight. **The chapter-4 single-sided acknowledgment is the only staged unspoken-acknowledgment beat in the game.** Beat 10 carries the moment via Murrow's archival placement of supporting ledger entries on the table + his "consistent with prior entries" line. No specific staging beyond that.

> **The Cula↔Murrow relationship.** The closest the game has to two characters seeing the structure together. Phase 7 voice work must hold the relationship at *unspoken acknowledgment*. Per phase-6 revision: the only staged moment is the chapter-4 Beat 11 single-sided acknowledgment (Murrow notices, Cula doesn't notice he noticed). The chapter-6 ending carries a shared spatial moment without explicit eye contact (Cula passes Murrow's desk; Murrow closes the ledger; the player feels the mutuality). Murrow does not mentor Cula on the spine's question; he is present, he files, he is precise when asked. Cula asks rarely. The relationship is mostly silence.

### Cula — relevant cross-chapter and per-scene notes

**(From `narrative_revision/bibles/cula.md`.)**

> **The relationship to Murrow.** Murrow knows what Cula knows by the end of chapter 6 — possibly by chapter 4 (when Cula glimpsed his ledger, Murrow registered it on his return, internally). Neither of them says anything about it. Per phase-6 revision: the chapter-4 acknowledgment is single-sided (Murrow notices, Cula does not notice he noticed); the chapter-6 ending image carries a shared spatial moment without explicit eye contact. The unspoken acknowledgment between them is the closest the game comes to two characters seeing the structure together — and it never surfaces in dialogue or staged eye contact.

> **The withholding of articulation.** Across chapters 3-5, Cula increasingly knows things he does not say. Phase 7 voice work must protect his restraint — he does not narrate his growing awareness. The player carries it.

---

## §E — Project visual conventions

The project is **top-down 2D pixel art** (Godot 4.6.2, GDScript). Per `style_canon.txt §4`:

- World tiles: 32×32 native, pixel art, nearest-neighbor, warm palette.
- NPC walking sprites: 32×48 native, pixel art, 4-direction, palette-snapped.
- Decorations / props: 32×32 to 96×96 native, pixel art, palette-snapped.
- **Dialogue portraits: 512×512 native, hand-illustrated, soft inking.**
- Casebook judgment cards: 512×512 native, hand-illustrated, slightly more formal than portraits.

**Critical for this pack:** in both Beat 11 and Beat 14 final image, **no dialogue portraits appear**. Both moments are silent; the player views the scene at the standard top-down camera. Murrow's facial expressions do not surface (he is on-screen as his 32×48 pixel-art sprite only). The ledger entry at Beat 11 must be visible/legible at the top-down camera scale — this likely means a brief overlay or a zoom-relative inset, OR the ledger's contents being readable on the world-tile asset itself. Phase 7 visual scripting (in collaboration with the art pipeline) decides which.

**Camera conventions:**

- The default camera follows the player character (Cula).
- Camera moves on room transitions only (per world.txt music/transition rules).
- No special camera moves authored for either of these scenes.
- The "glimpse" at Beat 11 must work with the standard player-following camera — either Cula's path naturally puts the ledger in frame, or the glimpse is conveyed via a small environmental UI element (an inspectable detail; an overlay; a brief textual notification that doesn't surface to the player as a UI tooltip).

**Trigger / flag conventions:**

- Set `chapter4.glimpsed_ledger_anomaly = true` when Cula's collision box enters the proximity zone around Murrow's desk during the open-ledger window (between phone-rings and Murrow-returns).
- Set `chapter6.murrow_closes_ledger_seen = true` when Cula's path enters the camera frame during the Beat 14 ending sequence (after Pig's interrupted speech).

---

## §F — Drafting prompt template

**Once the model has loaded the above context, issue this prompt:**

```
You are writing the staging specifications for two silent visual moments in Pig & Swine RPG. These are the spine's most delicate writing-discipline moments. NO DIALOGUE is authored in this session — the deliverable is two staging specifications written at the level of detail Godot scene scripts can use.

The two moments:

1. CHAPTER 3 BEAT 11 — the inflection. Murrow interrupted by phone (Asia transferring a courier callback). Murrow steps out to reception. Ledger remains open on his desk because the interruption was sudden. Cula crosses near the desk in normal traversal. Cula's eye catches the ledger entry "Konto operacyjne — saldo bieżące: 285 400 PLN". Cula does not stop. Cula proceeds to the case file cabinet. Murrow returns. Murrow glances at his desk and registers internally that the ledger has been visible. Murrow does NOT look at Cula. Cula does NOT look at Murrow. Both file the moment. Work continues.

2. CHAPTER 5 BEAT 14 — the final image. Murrow at his desk, finishing a notation. The chapter-6 case proceeds have just added a small line to the ledger; the reserve has gone up slightly. Cula passes Murrow's desk on his way through the office in the ending sequence. Murrow closes the ledger and places it in the drawer. Cula sees the line being made and the ledger close. Murrow sees Cula see; both file the moment. Neither speaks. Shared spatial moment without explicit eye contact.

For each scene, produce a staging specification with:

A. SETTING — location, time, lighting, ambient audio (no music sting), other personnel visible in the scene.

B. CHARACTER POSITIONS / BLOCKING — where each character starts, where each character ends, any ordinary sprite animations (idle, walk, sit). NO special animations for the moments themselves.

C. OBJECT STATES — the ledger (open / open with entry visible / closing / closed in drawer); the phone (Beat 11); the desk; any other relevant props.

D. BEAT SEQUENCE — numbered steps, each describing what is on screen and what triggers it. Time annotations in seconds where relevant. Trigger conditions for any flags being set.

E. EXPLICIT CONSTRAINTS — what does NOT happen visually (no eye contact in either scene; no music sting in either scene; no camera move; no internal narration; no theatrical pauses; no reaction shots; no facial expressions surfaced via portraits).

F. ENGINE NOTES — how the engine should implement the moments (player-following camera; collision box triggers; flag setting; ambient SFX continuity).

Constraints:
- NO DIALOGUE in either scene. If you find yourself writing a line of dialogue, stop and replace with staging.
- NO internal narration / thought bubbles for Cula.
- NO eye contact between Cula and Murrow in either scene.
- NO music sting in either scene.
- NO camera flourish, zoom, or special movement.
- NO subjective language in the staging notes ("the moment lands quietly," "the player feels..."). Describe what is on screen.
- Each scene's specification should be ~30-60 lines of staging notes.

After drafting:
- Confirm both scenes have NO dialogue.
- Confirm Murrow does not look at Cula in either scene.
- Confirm no music sting / camera flourish.
- Confirm the visible difference between the two ledger images: Beat 11 ledger is open, Beat 14 ledger is being closed.
- Run §A scrub for AI tells in staging language.

Output format:
- Section header per scene.
- Subsections A-F per scene as listed above.

Begin.
```

---

## §G — Post-draft hostile-critique prompt (for second model)

**After getting the first draft, paste this pack + the first draft + this prompt:**

```
You are critiquing the attached staging specifications for chapter-4 Beat 11 inflection and chapter-6 Beat 14 final image in Pig & Swine RPG against the constraints in the pack above.

The Critical risk these moments must avoid:
- Any dialogue introduced into either scene.
- Any internal narration or thought bubble for Cula.
- Any explicit eye contact between Cula and Murrow.
- Any music sting or camera flourish.
- Any theatrical pause or reaction shot that signals the moment's significance to the player.
- Any subjective staging language ("the moment lands," "the player feels," etc.).
- Any reaction animation that breaks Murrow's or Cula's ordinary sprite pose.
- Confusion between the two ledger images (Beat 11 must be open; Beat 14 must be closing).

Critique against:
- §A general AI tells (search the staging notes for each).
- §B per-character will-not-do constraints for visual scripting.
- §C beat sheet excerpts (the canonical specifications).
- §D bible excerpts (Murrow's neutrality; Cula's restraint).
- §E project visual conventions (top-down 2D; no special camera moves; ledger entry must be conveyable at standard scale).

For each issue you find, output:
- Scene cited (Beat 11 or Beat 14).
- Section/step cited.
- Failure mode it represents.
- Recommended fix (specific replacement text or removal).

Be hostile. The user reviews this directly. Pad nothing.

Output format: numbered list of issues organized by scene. No preamble. Begin.
```

---

## §H — Output expectations

A successful staging specification has:

- Two complete scene specs (Beat 11 + Beat 14), each ~30-60 lines.
- Each spec covers: setting, character positions, object states, beat sequence (numbered), explicit constraints (negative space — what doesn't happen), engine notes.
- NO dialogue in either scene.
- NO internal narration / thought bubbles.
- NO eye contact between Cula and Murrow in either scene.
- NO music sting.
- NO camera flourish.
- NO theatrical pauses.
- The visible difference between the two ledger states is clear (Beat 11 open; Beat 14 closing).
- The flag-setting conditions are specific enough to implement (collision box / proximity zone / camera frame entry).
- Murrow's "single-sided observation" in Beat 11 is conveyed by his sprite glancing at his own desk — not at Cula.
- The Beat 14 "shared spatial moment" is conveyed by Murrow closing the ledger in synchrony with Cula entering the camera frame — not by eye contact.
- Read-aloud test (for the staging spec, not for player experience): the spec describes what is on screen. No subjective language.
- AI scrub: no "delve," "tapestry," "essence," "moment lands," "player feels," etc.

---

## §I — Files this pack draws from

For reference / deeper context:

- `narrative_revision/ai_voice_constraints.md` — full version (this pack uses excerpts from §1, §2 Murrow + Cula sections, §4 Cula-Murrow staging template).
- `narrative_revision/bibles/murrow.md` — Murrow's full bible.
- `narrative_revision/bibles/cula.md` — Cula's full bible.
- `narrative_revision/beats/chapter_3.md` — Beat 11 inflection specification.
- `narrative_revision/beats/chapter_5.md` — Beat 14 final image specification.
- `narrative_revision/pressure_test.md` — Hits #8, #10, #16, #20 detail.
- `style_canon.txt §4` — visual style canon.
- `style_canon.txt §5` — audio canon (no music sting context).
- `world.txt` — overworld structure, music/transition conventions.

---

## §J — User-author note

Per the manifest: **this pack is largely visual scripting / stage direction, not dialogue. The user reviews directly; the model's role is supportive on framing language, not load-bearing.**

The cleanest workflow for H3 specifically:

1. Run §F drafting prompt with the first model.
2. Read the output yourself FIRST, before sending to the second model. **The model is not trustworthy on restraint.** Look specifically for:
   - Dialogue that crept in.
   - Internal narration for Cula.
   - Eye contact between Cula and Murrow.
   - "Reaction shots" or "meaningful pauses."
3. Edit the model's output yourself to remove these failure modes.
4. THEN send the edited version to the second model for hostile critique against this pack. The critique is now confirming your edits, not catching the first model's failures.
5. Apply the critique. Read aloud.
6. Commit the staging specifications to a working file (recommended: `godot/scenes/staging_notes/beat_11_inflection.md` and `beat_14_final_image.md` — phase-7 implementation will use these).

The model is least good at restraint; you're the most reliable author for these two moments. The pack supports you; you do the work.

---

## End of Pack H3

Once Beat 11 and Beat 14 staging specs are complete, the Tier 1 horizontal priority work (H1 + H2 + H3) is done. The spine's Critical-tier commitments now have phase-7 expression in draft. You can move into Tier 2 (H4 — celebration ordering, H5 — STUB founding + callbacks, H6 — postcards) or start Tier 3 chapter-vertical work (V1.1 onward).

The methodology muscle is now built. Subsequent packs follow the same structure (header → §A general AI tells → §B per-character constraints → §C/§D beat sheet + bibles → §F prompt → §G critique → §H expectations → §I files). H1 and H2 are worked examples for dialogue-heavy packs; H3 is the worked example for staging-heavy packs.
