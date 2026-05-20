---
critic: narrative-and-dialogue
date: 2026-05-19
scope: full game state
stance: hostile critique
---

# Narrative & Dialogue — Hostile Critique, 2026-05-19

## Verdict

The writing has the components of a prestige legal-comedy and the discipline of a project that talks about discipline a lot. Chapter 1 ships with one outright authoring bug at a first-meeting beat, an interior voice pack for the protagonist that is unreachable in play, a trust meter that rewards a stance the writing claims is one of three equals, and address-form drift the project already documented and chose not to fix. The reference points are Disco Elysium and Pentiment; the current execution is closer to a writers' room that has filed thirty bibles and shipped seven.

## Findings

### F1 — Murrow speaks Cula's interior monologue at first meeting

**Flaw:** `godot/data/dialogues/murrow.json:16` ships the first-meeting `after_pig` state with a single line: `{"speaker": "murrow", "text": "[This must be Mr. Murrow. Young and promising. I've read his profile on Ionkionked.]"}`. The bracketed interior — "This must be Mr. Murrow" — is plainly Cula's thought about Murrow, attributed to Murrow speaking about himself in the third person. The brand "Ionkionked" is a LinkedIn parody, which `style_canon.txt §Reject patterns` rules out under "modern internet voice."

**Why this fails:** A speaker-tag misattribution at the first beat a player will encounter with the firm's archivist is the single most expensive sentence-level mistake the game can make. It corrupts every subsequent inference the player draws about Murrow's voice. Compound that with a brand-gag the project's own canon bans, and the line fails the Taste Standard on Clever (no real referent), Alive (no human says this), and Future-proof (the social network will date).

**Remediation:** In `murrow.json` `after_pig`, change `speaker` on line 16 to `cula_internal` (registered per the cula.json speaker table) and rewrite the bracketed line to drop "Ionkionked." A clean substitution: `{"speaker": "cula_internal", "text": "[Murrow. Reading glasses, blue spine on the second shelf. Cula. Identify, hand off, do not bow.]"}`. Re-run `tools/voice_audit.py`.

**Severity:** S1

### F2 — Address-form drift survives in shipped JSON and the file confesses it

**Flaw:** `godot/data/dialogues/asia_hint_states_ch1.json:46-48` carries the line `"If it's a service problem, Mr. Crab will have an opinion."` and the file's own `_comment` admits the violation: "Note: Asia uses 'Mr. Crab' here; her bible says she addresses Crab by first name — this is a known asymmetry in the v3 canonical file preserved verbatim." Line 55 ("The rights memo may be near Mr. Whimsy.") and 62 ("Mr. Whimsy is useful if pointed at the right page.") repeat the violation. `murrow.json:90` has Murrow say "Mr. Crab is the second pair of eyes you want" — Murrow uses bare "Crab" with the juniors per `style_canon.txt §Murrow` (no honorific to peers).

**Why this fails:** `godot/AGENTS.md §Address forms in dialogue` calls a line that violates the rules a Taste-Standard failure "automatically." The asia_hint comment "preserved verbatim" is the design role telling QA the rule was knowingly broken and the violation was committed anyway. That is not preserving canon; that is laundering it.

**Remediation:** In `asia_hint_states_ch1.json`, replace "Mr. Crab" → "Crab" on line 48; replace "Mr. Whimsy" → "Whimsy" on lines 55 and 62. In `murrow.json`, replace "Mr. Crab is the second pair of eyes" → "Crab is the second pair of eyes" on line 90. Add a `voice_audit.py` Rule G that flags `Mr. Crab|Mr. Whimsy` in any speaker whose bible specifies bare-form, scoped to the firm's juniors. Re-run.

**Severity:** S2

### F3 — The V1.6 court-rounds pack canonizes "Doctor Cula," which the protagonist's bible explicitly bans

**Flaw:** `narrative_revision/phase_7_packs/V1.6_court_rounds.md:73-74` instructs: "The bench addresses Cula as 'Counsel' or 'Doctor Cula' depending on register slot" and "if Murrow speaks in the courtroom, he uses 'Doctor Cula.'" `narrative_revision/bibles/murrow.md:162` states: "'Doctor Cula' is non-canonical." `narrative_revision/bibles/murrow_voice_spec.md:93` repeats: "'Doctor Cula' is non-canonical and is not used." The shipped `murrow.json` v3 `_provenance` block also asserts: "'Doctor Cula' is non-canonical and not used." The draft `godot/data/dialogues/_drafts/murrow_decoys_2026-05-16.json:13, 158, 173` carries three "Doctor Cula" lines built against the V1.6 instruction.

**Why this fails:** The project is running two contradictory address-form authorities. The bibles ban the form; the pack endorses it. Drafts written against the pack will keep regenerating banned lines, and one of them is sitting in `_drafts/` ready to be promoted. The project's own court-round source-of-truth is teaching its writers to fail the audit.

**Remediation:** Edit `V1.6_court_rounds.md` lines 73, 74, 256, and any sibling, replacing "Doctor Cula" with "Dr. A. Cula" (bench formal slot) or "Cula" (Murrow's post-invitation register) per Murrow's voice spec. Update `tools/voice_audit.py` Rule B so the lookbehind that currently excludes "Dr. Cula." excludes only the title abbreviation, not the spelled-out form. Spelled-out "Doctor Cula" should fail the audit unconditionally.

**Severity:** S2

### F4 — Cula's interior voice pack ships orphaned from the runtime

**Flaw:** `godot/data/dialogues/cula.json:6` carries an `_authoring_note` that opens: "Cula's dialogue file is dispatched ONLY by the family-photo interactable. Beat states authored here are reachable only after engineering fan-out into the appropriate NPC files." The file is 64KB. It contains Cula's interior reactions for Beats 1, 2, 3, 4, 5, 7, 8, 9, 10, 12, 13, 14 — the entire chapter — plus the Kundera step-back beat, the cardiologist silent reaction, three stance-keyed remedy responses, and forty-odd dwell replies. None of it is wired. The note ends: "fan-out is a tracked engineering task."

**Why this fails:** A shipped voice pack that isn't reachable from the runtime is not voice work. It is documentation that looks like content. Design has produced the Kundera-mode line "I notice that I do not yet know whether the firm is teaching me, or whether the case is teaching me" and the postcard rejoinder "Japan, ski resorts, arbitration, no immediate downside. I distrust every noun in that sentence" — both load-bearing for the chapter's interior register — and the player will hit a family photo or hit nothing. The reference points (Disco Elysium, Pentiment, Citizen Sleeper) all hinge on the protagonist's interior register being where the player lives. This game's protagonist is silent.

**Remediation:** Open a Code artifact to fan out cula.json's Beat-keyed states into the speaker:"cula_internal" line slots already present in `pig.json`, `murrow.json`, `crab.json`, `whimsy.json`, `asia.json`, `halina.json`, `judge_district_ch1.json`. The fastest path: a build-time script in `tools/` that reads cula.json, matches state IDs to the NPC file whose trigger flags align (`cula_b3_pig_*` → pig.json, `cula_b4_murrow_*` → murrow.json), and either inlines the speaker-tagged lines into the matching state's `lines` array or emits a separate `cula_internal_ch1.json` the dialogue runner walks alongside. Until that ships, Beat 9's Kundera moment is paper.

**Severity:** S2

### F5 — The trust meter rewards picking warmth, not building trust

**Flaw:** `godot/data/dialogues/halina.json:40-56, 202-222, 300-320` defines three rounds of three options each. Sympathetic options carry `trust_delta: 2`. Technical options carry `trust_delta: 0` or `1`. Blunt-procedural options carry `trust_delta: 0` or `1`. The reveal gate at `client_meeting_reveal` requires `halina_trust >= 5`. The arithmetic forces it: a player who picks sympathetic across all three rounds gets +6 and unlocks the landlord-intimidation disclosure; a player who picks blunt-procedural across all three rounds gets 0–1 and never unlocks it.

**Why this fails:** `story.txt §Beat 8` presents three stances as legitimate professional registers, each carrying its own bonus evidence. The trust meter is then layered on top in a way that mechanically penalizes the technical and blunt-procedural carriers with a worse hidden disclosure. The author tells the player "all three stances are valid"; the math tells the player "warmth is the right answer." This is the structural fault Disco Elysium avoids by decoupling skill checks from approval — the player should not be able to optimize warmth into information. The current shape also collapses the cardiologist plant (which lands regardless of stance) against the landlord-intimidation reveal (which lands only behind a warmth gate), making the most weighty disclosure in Chapter 1 contingent on the player's tonal preference rather than on what the client would plausibly disclose under what conditions.

**Remediation:** In `halina.json`, replace the monotonic `trust_delta` schedule with a non-monotonic one keyed to question quality, not stance. Specifically: r1 "Mrs. Wójcik — is she available" should award trust based on whether r0 surfaced Mrs. Wójcik already (continuity of attention earns trust); r2 "Has the landlord been in contact with you" should award trust regardless of stance because the question itself is the trust-signal. Pull bonus evidence by stance per the current design; pull the reveal by *coverage* (did Cula ask both the personal and the procedural in any round) rather than by total trust. Implementation: add a derived flag `halina_trust_high := (count of distinct register classes asked >= 2)` and gate the reveal on it. The fix preserves the trust meter's emotional shape and removes its predetermination.

**Severity:** S2

### F6 — Mr. Pig is a maritime singularity, not a character

**Flaw:** `godot/data/dialogues/pig.json:9-23` (first meeting) carries the lines "Bankruptcy requires paperwork, and our paperwork is currently underwater along with the rest of us," "Six weeks under the surface. The landlord knocks on the hull," "Can a firm sail while six weeks underwater?", "We float. In the way that boats with leaks float, which is to say, less every morning," and four more maritime-tinted clauses in the same state. `idle_flavor` adds "ship is not actively sinking," "exploratory gurgling noises," "We cannot sail into court with a hole in the hull." The retainer aside in `halina.json:432` adds "the Hennessy retainer phone has gone overboard" and "Small craft warning, Mr. Murrow." `style_canon.txt §Mr. Pig` calls the maritime tic "a flavor tic, not a defining frame — use sparingly: roughly one in four lines."

**Why this fails:** The rate in `pig_first_meeting` runs closer to two in three. Pig also has no register outside maritime metaphor plus self-undercut. The spec describes him as Hrabalian — "long sentences that wander into philosophy and recover with a maritime metaphor" — meaning the maritime is supposed to be the *landing*, not the *engine*. The current voice has Pig launch from the hull and stay there. A player who diagnoses Pig from his first state diagnoses only the tic. The first sincere line in Chapter 5 will have nothing to recede *from*.

**Remediation:** In `pig.json::pig_first_meeting`, cap maritime lines at 2 of 9 (currently 5–6). Replace at least two maritime lines with Hrabalian-digressive register without the metaphor anchor — examples: "Bankruptcy is for firms whose paperwork has caught up with them. We are luckier than that." / "I have, at this point, three meaningful conversations a day, two of which are with the printer." Reserve maritime escalation for the actual extinction beats — `post_meeting_pre_murrow` and the post-court Beat-13 celebration. Add a writer-side count rule to `tools/voice_audit.py`: max 1 maritime keyword per 4 consecutive Pig lines in any single state.

**Severity:** S2

### F7 — Cula introduces himself to Asia three different ways depending on the option picked, two of which contradict cula.json

**Flaw:** `godot/data/dialogues/asia.json:37-39` offers three player options for the Beat-2 desk approach: "Good morning. Dr. A. Cula, reporting for duty.", "Good morning, you must be Asia? Cula. The new hire. Pleasure to meet you.", "Dr. A. Cula, here to see Mr. Pig." The middle option introduces him as bare "Cula." `cula.json:42-44` `cula_b2_asia_greeting` carries the canonical first encounter: "Good morning. Dr. A. Cula. First day. I was told to ask for reception, coffee, or forgiveness." The `_comment` immediately above asserts: "He does NOT introduce himself as 'Doctor' casually — uses the title because Asia is reception and a formal first encounter."

**Why this fails:** Two files own Cula's first words to Asia, and they disagree about whether he uses the title. The friendly option also tags Asia by name ("you must be Asia?") before any beat establishes that Cula has been told her name — a small continuity break. "Reporting for duty" is military pastiche; Cula is a doctorate-holding aplikant on his first day, not a conscript. The dry option ("here to see Mr. Pig") removes the first-meeting acknowledgement of Asia entirely and skips the social texture `godot/AGENTS.md §First-meeting introductions` mandates.

**Remediation:** In `asia.json::asia_b2_approach_choice`, rewrite the three option strings so all three include "Dr. A. Cula" as self-identification (cula.md §casual-context rule: title used for formal first encounters). Suggested replacements: (professional) "Good morning. Dr. A. Cula. First day." / (friendly) "Good morning. Dr. A. Cula. I gather I am the new hire who was promised." / (dry) "Good morning. Dr. A. Cula. Mr. Pig is expecting me." Delete `cula.json::cula_b2_asia_greeting` and let `asia.json` own the Cula self-introduction at this beat (per asia.json's existing pattern of inlining cula speaker lines). Verify the cardiologist-of-files joke ("I was told to ask for reception, coffee, or forgiveness") is preserved in whichever variant carries it.

**Severity:** S2

### F8 — Whimsy bleeds into Crab's fact-finding lane

**Flaw:** `godot/data/dialogues/whimsy.json:18-20` has Whimsy say: "Before the music, a fact you may want. I keep a folder of who-owns-what. Marginal pastime. Occasionally useful. Your landlord sold the building in two thousand and eighteen. The new owner is a property concern out of Mokotów." This factual disclosure is Whimsy's surfacing of decoy D3 (standing / wrong party). `style_canon.txt §Crab` defines Crab as the firm's investigator: "Notices first: the inconsistency. Always." `style_canon.txt §Whimsy` defines Whimsy as the rhetorical chaos engine: "Notices first: the dramatic possibility. Will not say: anything boring. If forced to be technical, he will sneak a metaphor in anyway." A civic-records hobby that produces ownership-transfer facts is exactly Crab's notice-the-inconsistency mode, dressed in a "marginal pastime" gloss.

**Why this fails:** The decoy mechanic needed a surfacing voice for D3 and the v4 motion-packet rewrite handed it to Whimsy because Crab was already loaded with E1–E4. The economic move shipped at the cost of voice differentiation: Whimsy now does two things — rhetoric, and a kind of fact-finding the bible reserved for someone else. The single-line diagnosis test the brief asks for will misfire here.

**Remediation:** In `whimsy.json::before_meeting`, replace the property-transfer surfacing with a fair-hearing rhetorical anchor that points Cula *back* at Crab for the ownership question. Suggested rewrite of lines 18–20: "Before the music, a thread. Crab will want to ask who owns the building today. Owners change. Notices, alas, do not." This keeps Whimsy in his rhetorical lane and transfers D3 surfacing to Crab. Then in `crab.json`, add a new state `crab_property_transfer_offer` gated on `recruited_crab && surfaced_property_transfer_thread`, where Crab himself produces the 2018 transfer and the standing decoy. Cost: two new states, one removed paragraph. Voice integrity restored.

**Severity:** S2

### F9 — The Beat 13 Pig celebration speech is missing from pig.json

**Flaw:** `godot/data/dialogues/cula.json:637` `cula_b13_pig_celebration_response` quotes Pig's celebration speech in its `_comment`: "Pig's firm-first / client-second celebration speech ('We have survived another impossible thing. The client — yes, the client — also survived.')." `godot/data/dialogues/pig.json` has 8 states total: first meeting, post-Pig, met-Murrow, has-binder-only, two coffee reactions, has-binder-and-memo, and `idle_flavor`. There is no Beat 13 state for Pig at all. The line Cula is reacting to in cula.json does not exist anywhere in pig.json.

**Why this fails:** The Beat 13 firm-first / client-second speech is the chapter's emotional payoff for Mr. Pig — the moment the player is supposed to register that this firm celebrates its own survival before the client's. Cula's voice-pack reaction is authored to land against the speech; the speech itself is unauthored. Even if the player hits Pig at Beat 13, they get either an idle_flavor line ("ship is not actively sinking") or the has_binder_and_memo line. The chapter's spec calls for a sincere-incompetent reframe; the file ships without one.

**Remediation:** In `pig.json`, add a state `pig_b13_celebration` with trigger `chapter1.court_won_procedural_reset == true && !chapter1.beat13_complete`, marked `once: true`, with on_dismiss `chapter1.pig_b13_seen = true`. Lines: the canonical celebration speech the cula.json comment paraphrases, with the firm-first / client-second ordering load-bearing. Suggested shape: "Dr. A. Cula! We have survived another impossible thing. The firm sails on. The client — yes, the client — also survived. Both, mercifully, in that order." Order the state before `has_binder_and_memo` so it takes priority. Update `cula_b13_pig_celebration_response` trigger to depend on `pig_b13_seen`.

**Severity:** S2

### F10 — The Halina reveal fires before the rebuke when both qualify

**Flaw:** `godot/data/dialogues/halina.json` orders states as: `client_meeting_close` (state 11), `client_meeting_reveal` (state 12), `halina_post_meeting_decoy_incapacity_cold` (state 13), `post_meeting_ch1` (state 14). The dialogue runner walks in JSON order and picks first-matching. A player who reached `halina_trust >= 5` AND triggered `chapter1.decoy_incapacity == true` will see Halina's warm intimidation disclosure (state 12) before her cold incapacity rebuke (state 13), because the reveal's trigger evaluates true first.

**Why this fails:** The cold rebuke is a behavioral correction; the reveal is an earned disclosure. Dramatically the rebuke must land first — Halina cannot warmly trust Cula with two months of prior contact while she is also formally asking him to withdraw an argument that called her incapacitated. The current ordering tells the player she trusts him, then tells the player she has been let down. The sequence is inverted.

**Remediation:** Swap the JSON order of states 12 and 13 in `halina.json`. Move `halina_post_meeting_decoy_incapacity_cold` before `client_meeting_reveal`. Both keep `once: true`. After the rebuke fires once and `decoy_incapacity` resolves (either by retraction logic added in Code or by leaving the flag set as a record), the reveal can fire on the next interaction if its conditions still hold. This is a one-line reorder; verify in `tests/test_dialogue_state.gd` that both states still fire under the conjoint condition and in the right order.

**Severity:** S3

### F11 — The judge's six remedy variants collapse to one register

**Flaw:** `godot/data/dialogues/judge_district_ch1.json` carries six remedy-announcement states for Round 3: `judge_b12_remedy_strong_technical`, `judge_b12_remedy_strong`, `judge_b12_remedy_standard_technical`, `judge_b12_remedy_standard`, and four narrow variants. Five of six open with "Counsel." Four of six close with the canonical formula "Notice will be served in the ordinary course." The two strong variants share the opener "Against several expectations, counsel has produced a coherent submission on all four elements of Article 135-bis, paragraph two, of the Code of Civil Procedure." The variation across outcomes is procedural content, not register. The judge's affect — dry, faintly amused, lowered-expectations — is identical in the warmest case (strong-technical) and the coldest (icy_silence on incapacity).

**Why this fails:** A first-court-win is one of Chapter 1's two emotional peaks. If the bench's register is identical across "barely earned it" and "earned it cleanly with the bonus evidence the player worked for," the player learns that performance does not change the temperature of the room. The "dry-surprise" canonical voice rests on the surprise being *visible*. Currently the bench acknowledges the lease record in one extra sentence on technical strong and that is the entire register reward. The judge is six remedy paragraphs; she should be six different small heats.

**Remediation:** In `judge_district_ch1.json`, rewrite the strong-technical and strong-non-technical variants so they diverge in opener tone, not just in the noted exhibits. Strong-technical should carry an audible shift — a half-beat of bench surprise before the formal remedy ("Counsel. The court will note that briefly: the underlying record is unusual in its completeness for a motion of this kind. The submission stands."). Strong-non-technical should retain "Against several expectations" but add a small register lift in the close ("Dr. A. Cula. You may consider this a good first day."). Narrow-overbroad should run colder than narrow-thin. Blunder-recovered should be flatter than narrow-thin, not warmer. Six remedy paragraphs, six visible heats. Also: deduplicate the `on_dismiss` blocks across all remedy states (every one currently writes `chapter1.court_won_procedural_reset` twice — minor engineering bug surfaced by reading the file end-to-end).

**Severity:** S3

## Standing concerns

The project's JSON `_comment` blocks routinely tell the writer (and the audit) that "the discipline IS the response" — meaning the team has correctly noticed that good writing dramatizes restraint, and has then written a meta-note explaining the restraint. Watch for self-consciousness about restraint hardening into a tic of its own.

Beat 8 is a single-room scene of approximately fifteen player choices (stance + three rounds × three options + dwell options + close), spec-rated at 8–12 minutes. The "Pokémon-style starter town" framing in `story.txt §Chapter 1` and the fifteen-choice client meeting are pulling against each other. Either Beat 8 needs to be shorter, or Chapter 1 needs to stop calling itself a starter chapter.

The post-Stage-15 voice-pack catalogue (54 packs, 109–140 hours estimated) is approaching a content-debt configuration where the writers' time goes into spec rather than into the JSONs the runtime actually loads. The Cula-orphan problem in F4 is the first visible symptom; the V1.6 / Murrow-bible contradiction in F3 is the second.
