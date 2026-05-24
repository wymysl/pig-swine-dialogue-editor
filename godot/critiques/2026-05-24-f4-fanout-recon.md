# F4 Cula fan-out — recon plan (no JSON edits)

**Status:** Recon only. Produced 2026-05-24 in response to "draft the F4
full-closure patch" with scope narrowed to per-file recommendations and no
JSON writes this round.

**Source artefact:** `tools/fanout_reports/fanout_cula_report.md` (75 states
inspected) plus first-hand read of `cula.json` and every target NPC file.

**Key finding the auto-report did not surface.** The `already_present`
heuristic in `tools/fanout_cula.py` only catches three signals: exact id
overlap, trigger-string substring overlap, and id-mention in target
`_comment` text. It misses the dominant pattern in shipped NPC files: Cula
lines authored INLINE as `{"speaker": "cula", "text": "..."}` slots inside
NPC states (the `pig_first_meeting`, `murrow_first_meeting`,
`crab.first_meeting_with_binder`, `whimsy.before_meeting`,
`halina.client_meeting_intro` flows). The report claims one or two states
per file are "already present"; the reality across the five in-scope files
is that **roughly half** of cula.json's content is already in the NPC files
in a different shape, and the F4 patch is therefore **smaller, sharper, and
more editorial** than a literal "inline all 41" diff.

This recon classifies every routable cula.json state into one of four
buckets and recommends an action.

---

## Buckets

- **DUPLICATIVE** — content already in target file (inline `cula` speaker
  lines), in a form that is functionally equivalent and stylistically
  consistent with the target's authored voice. Recommended action:
  **delete from cula.json**, do not inline a second copy. Keep cula.json's
  version only if there is a load-bearing voice difference the author
  intends to preserve as the canonical voice doc.
- **STYLISTIC_VARIANT** — content already in target file, but cula.json's
  version is materially different (longer, different beat, different
  register). Recommended action: **design review** — pick one or
  consciously author both as branched variants.
- **GAP** — content not in target file, and there is a defensible insertion
  point. Recommended action: **inline into target with specific anchor**.
- **NO_DISPATCH** — content has no NPC anchor (internal monologue, ambient
  observation, or beat without a dialogue dispatch point). Recommended
  action: **defer** to a separate dispatch-design pass (zone interactables,
  idle_flavor lift, ambient channel).

---

## asia.json (6 cula states)

`asia.json` already implements a complete `state_choice` discriminator
inside `asia_b2_welcome` with three Cula questions
(`dwell_tenure`/`dwell_always`/`dwell_where`) and three follow-up states
that carry the dwell content end-to-end. Cula's lines inside those states
are author-voiced. The cula.json b2-asia dwell states are stylistic
variants of the same beat.

| cula state | bucket | recommendation |
|---|---|---|
| `cula_b2_asia_greeting` | DUPLICATIVE | `asia_b2_via_behind` + `asia_b2_approach_choice` already carry Cula's "Good morning. Dr. A. Cula." opener verbatim. The cula.json second line ("I see you have all three in motion. I will start with reception.") is **not** in asia.json — that one half-sentence is a GAP. Recommend: inline only the second-line ack as a per-line `{"speaker":"cula",...}` slot inserted after the `professional`/`friendly`/`dry` response cluster, before `asia_b2_welcome`. Delete the rest of `cula_b2_asia_greeting` from cula.json. |
| `cula_b2_asia_dwell_options` | DUPLICATIVE | `asia_b2_welcome` already owns the options block with three dwell choices. Delete from cula.json. |
| `cula_b2_asia_dwell_tenure_reply` | STYLISTIC_VARIANT | `asia_b2_dwell_tenure` uses Cula's question "You seem to know where everything is." (4 chars). cula.json uses "Before I start anything I should probably break: how long have you been holding all of this together?" (different beat — direct question, register of asking-permission). **Design call:** the asia.json line is reactive to Asia's "I am, at this point, structural." line and works better in context. Recommend: keep asia.json as canon; delete cula.json variant. |
| `cula_b2_asia_dwell_today_reply` | STYLISTIC_VARIANT | `asia_b2_dwell_always` doesn't carry a Cula prompt line — the choice text "Is it always like this?" is the prompt. cula.json adds "Is it always like this, or have I picked a particularly loud morning?" as a Cula utterance. **Design call:** asia.json has only `{"speaker":"cula","text":"This is calm?"}` mid-state, which reacts to Asia's reply. Recommend: keep asia.json's reactive line as canon; do not inline cula.json's prompt-side line because the choice text already serves that function. Delete cula.json variant. |
| `cula_b2_asia_dwell_logistics_reply` | STYLISTIC_VARIANT | Parallel to above. `asia_b2_dwell_where` choice text is "Where do you keep things around here?" and Cula's reactive mid-state line is "And the photocopier password?" cula.json's "Practical question. Where do you keep the binder labels?" is a different framing (binder-specific). Recommend: keep asia.json; delete cula.json. |
| `cula_b13_asia_response` | GAP | `asia_b13_congratulation` ends with Asia's "Go find Mr. Pig." and offers two dwell choices. cula.json's "Thanks, Asia. Whatever you are sorting, please do not let me add to the pile until tomorrow." has no home. **Recommend:** inline as a per-line slot inside `asia_b13_congratulation` after Asia's "Go find Mr. Pig…" line and before the options block. Speaker `cula`, no state-level changes. |

**Net asia.json patch:** one half-sentence inlined into `asia_b2_via_behind` (or `asia_b2_welcome`); one Cula line inlined into `asia_b13_congratulation`. Five cula.json states queued for deletion.

---

## pig.json (8 cula states)

`pig_first_meeting` (state 1) ALREADY contains Cula's reactions inlined: "Mr. Pig. Good morning.", "Six weeks. Understood.", "I'll find him." cula.json's b3 lines are slightly fuller ("Mr. Pig. Cula. The reception sent me back.") — material upgrade. cula.json's `pig_dwell_*` trio has no analogue in pig.json.

| cula state | bucket | recommendation |
|---|---|---|
| `cula_b3_pig_first_encounter` | STYLISTIC_VARIANT | pig.json line 10 has "Mr. Pig. Good morning." cula.json has "Mr. Pig. Cula. The reception sent me back." + "I gather there is a great deal happening this morning." + "Would you like to start with the firm, the client, or the deadline?" The cula.json opener is canonical per AGENTS.md §First-meeting introductions (name + self-id + period); pig.json's bare "Good morning" technically violates the rule for a first-meeting opener. **Design call:** REPLACE pig.json's line 10 with cula.json's three-line opener. The current pig.json third line "Dr. A. Cula! Welcome." needs to follow as Pig's reply. Delete cula.json state after the replacement. |
| `cula_b3_pig_rent_reaction` | DUPLICATIVE | pig.json line 18 already has Cula's "Six weeks. Understood." inline. The cula.json second line ("I will take that as a fact and find Mr. Murrow.") is **not** in pig.json — that second beat goes missing in the current pig_first_meeting flow which jumps to "Anyway. I'm digressing." after Cula's "Six weeks. Understood." Recommend: inline cula.json's second line as a per-line slot between current pig.json line 18 ("Six weeks. Understood.") and line 19 ("Anyway. I'm digressing."). Delete cula.json state. |
| `cula_b3_pig_dwell_options` | GAP | pig.json has no dwell pattern post-`pig_first_meeting`. Inline as a new state `pig_b3_dwell_options` with trigger `chapter1.pig_revealed_crisis == true && !chapter1.met_murrow && chapter1.state_choice == ''`, ordered AFTER `pig_first_meeting` and BEFORE `post_meeting_pre_murrow`. State-level `"speaker": "cula"` so the prompt line reads as a Cula utterance. Options block writes `chapter1.state_choice`. |
| `cula_b3_pig_dwell_case_reply` | GAP | New state in pig.json: `pig_b3_dwell_case_reply` with trigger `chapter1.state_choice == 'cula_b3_pig_dwell_case'`. State-level `"speaker": "cula"`, `once: true`, `on_dismiss` clears `state_choice`. **Open design question:** Pig is expected to deflect to Murrow per the cula.json `_comment` — that means this state needs a Pig reply line too. Recommend authoring a 2-line pair (Cula question + Pig deflection) inside the new state. |
| `cula_b3_pig_dwell_okay_reply` | GAP | Same shape as above. The "Are you all right?" question per the cula.json `_comment` opens Pig's interior range. Author with a Pig reply. |
| `cula_b3_pig_dwell_swine_reply` | GAP | Same. Pig's reply plants the Beat 14 / Chapter 4 Mr. Swine thread per the `_comment`. |
| `cula_b10_pig_lecture_reception` | GAP | pig.json's `court_readiness_check` (in murrow.json) has a Pig "printer lease has come back as a kraken" line. cula.json's reaction line "Understood, Mr. Pig. We will keep the printer informed." needs to land in pig.json (or in murrow.json's readiness check). **Recommend:** add as inline `{"speaker": "cula", "text": ...}` slot inside `murrow.json::court_readiness_check` after the Pig "printer lease" line on line 164. Delete cula.json state. |
| `cula_b13_pig_celebration_response` | GAP | pig.json `pig_b13_celebration` `_comment` (line 60) references the cula.json reaction but the reply itself is not in pig.json. Inline as the last line of `pig_b13_celebration.lines[]` as `{"speaker": "cula", "text": "Temporarily saved is still saved, Mr. Pig…"}`. Delete cula.json state. |

**Net pig.json patch:** one replace (`pig_first_meeting` opener), three inserts (rent-reaction tail line; readiness-check Cula reply; b13 Cula reply), one new dwell-trio cluster (4 new states). Six cula.json states queued for deletion + 2 already-inline-equivalent.

---

## murrow.json (16 cula states)

The densest target. `murrow_first_meeting` already inlines Cula's opener and the friend-invitation calibration verbatim from cula.json. The dwell trio is the genuine gap. The b9 archive-room state machine doesn't exist in murrow.json yet — that's the deferred-by-F4 work.

| cula state | bucket | recommendation |
|---|---|---|
| `cula_b4_murrow_first_meeting_greeting` | DUPLICATIVE | murrow.json `before_pig` + `after_pig` options + `murrow_first_meeting` (line 56–68) already carry Cula's first-meeting greeting via the `murrow_choice` flow. cula.json's "Mr. Pig is currently in maritime conditions" line is **not** in murrow.json — but it pre-dates the Pig recruitment options refactor and may not fit the current `after_pig` choice mechanic. **Design call:** review whether to merge "maritime conditions" line into one of the three `after_pig` choice texts, OR drop. Recommend dropping (the v3 rewrite intentionally moved to the choice-based opener). Delete cula.json state. |
| `cula_b4_murrow_briefing_acknowledgment` | STYLISTIC_VARIANT | murrow.json `murrow_first_meeting` lines 63 and 65 carry Cula's mid-briefing question ("The resident at number seven. Does his accepting the notice cure service?") and post-briefing acknowledgment ("Thank you, Mr. Murrow."). cula.json has "Wrong-door service, fourteen days from actual notice, motion to set aside. I can carry that to Crab." — this is a DIFFERENT beat. The cula.json line is a Cula self-summary at the very end of the briefing, before the friend-invitation pivot. **Recommend:** inline as a per-line slot in `murrow_first_meeting` between line 65 ("Thank you, Mr. Murrow.") and line 66 ("It is Murrow, to friends."). Speaker `cula`. The summary lands the procedural shape and primes the Crab hand-off — load-bearing for the b4 → b5 transition. Delete cula.json state. |
| `cula_b4_murrow_first_name_acceptance` | DUPLICATIVE | murrow.json line 67 already has `{"speaker": "cula", "text": "Then it's Cula."}` verbatim. Delete cula.json state. |
| `cula_b4_murrow_dwell_options` | GAP | No dwell pattern in murrow.json. **Recommend** new state `murrow_b4_dwell_options` ordered AFTER `murrow_first_meeting` and BEFORE `post_briefing_pre_binder`. State-level `"speaker": "cula"`. |
| `cula_b4_murrow_dwell_tenure_reply` | GAP | New state with `"speaker": "cula"`, `once: true`. **Open design question:** Murrow's reply per cula.json `_comment` surfaces archival depth "without revealing Ch4 ledger content" — author Murrow's reply (1 line) inside the new state. Friend-form: bare "Murrow" (post-friend-invitation). |
| `cula_b4_murrow_dwell_pattern_reply` | GAP | Same pattern. Murrow reply expected per `_comment`: "More than I would like. The renumbering is unusual; the wrong-address tactic is not." |
| `cula_b4_murrow_dwell_client_reply` | GAP | Same. Murrow reply primes Beat 8 stance choice. |
| `cula_b9_murrow_first_clause_response` | NO_DISPATCH | The Beat 9 Archive Room scene has no interactable in shipped state. The F4 partial entry in 2026-05-19 SPRINT_LOG flags this: "the Beat 9 Kundera placement additionally depends on `chapter1.archive_research_complete` being set from a live state — currently the flag has triggers gating on it but no live state writes it." **Recommend defer** to a separate sprint that authors the Beat 9 dispatch (Archive Room interactable + Murrow archive scene states). All three `cula_b9_murrow_*_clause_response` states + `cula_b9_archive_setup` + `cula_b9_archive_close` + `cula_b9_kundera_beat` belong to that sprint, not F4. |
| `cula_b9_murrow_second_clause_response` | NO_DISPATCH | Same. |
| `cula_b9_murrow_third_clause_response` | NO_DISPATCH | Same. |
| `cula_b9_dwell_how_found_reply` | NO_DISPATCH | Same. |
| `cula_b9_dwell_used_before_reply` | NO_DISPATCH | Same. |
| `cula_b9_dwell_next_reply` | NO_DISPATCH | Same. |
| `cula_b10_readiness_check` | DUPLICATIVE | murrow.json `court_readiness_check` (line 156–171) already runs the readiness flow with Cula's "Murrow. We have the memo." line on line 161 and "Understood. Asia, has Mrs. Sikorska been told we're coming?" on line 169. cula.json's "Murrow. We have service, fairness, and a modest remedy…" two-line block is a DIFFERENT beat (Cula's opening of the readiness check). **Recommend:** REPLACE murrow.json line 160 ("Cula.") with cula.json's two-line Cula opener; then continue with current Murrow "Procedural binder. On file." Delete cula.json state. |
| `cula_b13_murrow_ledger_silent` | NO_DISPATCH | `silent: true`, `cula_internal` speaker. No dialogue line. Pairs with a visual ledger-update beat that has no shipped scene implementation. Defer until Beat 13 victory return scene is authored. |
| `cula_b13_brief_murrow_response` | GAP | "Murrow. Send me what you have on the next file. Tomorrow morning is fine." — this needs a Murrow scene state for Beat 13. **Recommend:** new state `murrow_b13_brief` with trigger `chapter1.court_won_procedural_reset == true && !chapter1.beat13_complete`. Author Murrow's question line too (the b13 close beat is currently silent in murrow.json). |

**Net murrow.json patch:** one inline insert (b4 briefing tail), one inline replace (b10 readiness opener), one new dwell-trio cluster (4 new states), one new b13 state. Six cula.json states queued for deletion. Six cula.json states deferred to a Beat 9 Archive scene sprint. One state deferred to a Beat 13 return scene sprint. Two duplicative states queued for deletion.

---

## crab.json (6 cula states)

Similar to Murrow: opener verbatim in target, dwell trio is the gap.

| cula state | bucket | recommendation |
|---|---|---|
| `cula_b5_crab_recruitment_pitch` | STYLISTIC_VARIANT | crab.json `first_meeting_with_binder` line 42 already has `{"speaker": "cula", "text": "Crab. I'm Cula. The procedural binder — Murrow said you'd want a second pair of eyes on the Sikorska service before fourteen hundred."}`. cula.json's two-line block is DIFFERENT (no binder mention, fuller case-summary opener). **Design call:** the crab.json line was deliberately rewritten in v4 to land the binder hand-off in one breath. cula.json's longer version is now stale. Recommend: keep crab.json as canon; delete cula.json state. |
| `cula_b5_crab_dwell_options` | GAP | No dwell pattern in crab.json. **Recommend** new state `crab_b5_dwell_options` ordered AFTER `first_meeting_with_binder` and BEFORE `crab_post_packet_names_article`. State-level `"speaker": "cula"`. Note: gates need careful ordering against the `chain: true` on `first_meeting_with_binder` — verify dwell options don't fire mid-chain. |
| `cula_b5_crab_dwell_background_reply` | GAP | New state. Crab's reply per cast canon (late 20s, peer to Cula): peer-to-peer, no flourish. Author Crab's 1-line reply. |
| `cula_b5_crab_dwell_why_here_reply` | GAP | Same. Crab's reply is brief and unsentimental per `_comment`. |
| `cula_b5_crab_dwell_case_opinion_reply` | GAP | Same. Crab's reply is leverage-aware, structural per `_comment`. |
| `cula_b13_crab_response` | GAP | "The address argument carried it, Crab. Most of the round was your reading." — needs a Crab b13 state. **Recommend:** new state `crab_b13_response` with trigger `chapter1.court_won_procedural_reset == true && !chapter1.beat13_complete`. Author Crab's "pretends not to be impressed" line (per Crab bible) as the lead-in, Cula's response as inline. |

**Net crab.json patch:** one new dwell-trio cluster (4 new states), one new b13 state. Six cula.json states queued for deletion.

---

## whimsy.json (7 cula states)

Identical pattern.

| cula state | bucket | recommendation |
|---|---|---|
| `cula_b7_whimsy_first_meeting` | DUPLICATIVE | whimsy.json `before_meeting` line 12 already has `{"speaker": "cula", "text": "Mr. Whimsy. Cula, Pig & Swine. We need a second voice in court tomorrow."}`. cula.json's second line ("There is a rights memo with coffee damage on it, and a hearing on Friday. I am told you are who I ask about a fair-hearing frame.") is **not** in whimsy.json — whimsy.json's parallel line 14 is "Notice went to an address the client left two years ago. The objection is in the papers; the record does not show it. Hearing at fourteen hundred." DIFFERENT framing. **Design call:** whimsy.json's framing was the v4 rewrite. Recommend: keep whimsy.json as canon; delete cula.json state. |
| `cula_b7_whimsy_procedural_vibes_response` | DUPLICATIVE | Report's heuristic flagged this as already-present via trigger overlap with `whimsy_coffee_reaction_perfect_pre_recruit` (false positive — coffee trigger is unrelated). Actual coverage: whimsy.json `before_meeting` line 13 has Whimsy's "Have you anything beyond procedural vibes" prompt and line 14 has Cula's reply ("Notice went to an address..."). cula.json's "Vibes won't carry it. The defect is service; the doorway is fair hearing; the article is in the binder." is a DIFFERENT reply — sharper, names the doctrine more crisply. **Design call:** which Cula reply lands the rights-frame correction better? whimsy.json's reply (longer, name-the-defect framing) won the v4 review. cula.json's reply is the older voice draft. Recommend: keep whimsy.json; delete cula.json state. |
| `cula_b7_whimsy_dwell_options` | GAP | No dwell pattern in whimsy.json. **Recommend** new state `whimsy_b7_dwell_options` ordered AFTER `before_meeting` and BEFORE `after_recruitment_client_upcoming`. State-level `"speaker": "cula"`. |
| `cula_b7_whimsy_dwell_office_reply` | GAP | New state. Whimsy reply per `_comment`: notes physical distancing. Author 1-line Whimsy reply. |
| `cula_b7_whimsy_dwell_case_read_reply` | GAP | Same. Whimsy treats case as rhetorical specimen. |
| `cula_b7_whimsy_dwell_office_visits_reply` | GAP | Same. Whimsy reply light. |
| `cula_b13_whimsy_response` | GAP | "I will look forward to the score, Whimsy. The written closing first, if you can." — needs Whimsy b13 state. **Recommend:** new state `whimsy_b13_response` with the proposing-a-musical Whimsy line + Cula's response inline. |

**Net whimsy.json patch:** one new dwell-trio cluster (4 new states), one new b13 state. Five cula.json states queued for deletion.

---

## halina.json (14 cula states)

The most extensively pre-authored target. The Beat 8 stance system + trust-meter + r0/r1/r2 architecture in halina.json makes most cula.json stance-keyed states DUPLICATIVE. The `cula_internal` speaker states have NO_DISPATCH — they need a separate channel.

| cula state | bucket | recommendation |
|---|---|---|
| `cula_b8_halina_arrival_greeting` | DUPLICATIVE | halina.json `client_meeting_intro` line 13 has `{"speaker": "cula", "text": "Good morning, Mrs. Sikorska. Dr. A. Cula. Please, sit. Thank you for coming in."}` and line 15 has `{"speaker": "cula", "text": "This is Mr. Crab and Mr. Whimsy. They have read the file. You know Mr. Murrow."}`. Verbatim coverage. Delete cula.json state. |
| `cula_b8_approach_choice` | DUPLICATIVE | halina.json `client_meeting_intro` (lines 22–30) already owns the options block with three stance choices. cula.json's version writes to `chapter1.state_choice` instead of `chapter1.client_meeting_stance` per the 2026-05-17 promotion fix in cula.json `_comment`. **However:** halina.json's options block writes `chapter1.client_meeting_stance` AND has `trust_path` AND `trust_delta` per choice — the cula.json version is missing trust mechanics. Recommend: keep halina.json; delete cula.json state. |
| `cula_b8_sympathetic_open` | DUPLICATIVE | halina.json `client_meeting_r0_response_high` line 37 has `{"speaker": "cula", "text": "Mrs. Sikorska, how are you holding up? The last three weeks must've been tough..."}`. Close match. Delete cula.json state. |
| `cula_b8_sympathetic_internal_fee` | NO_DISPATCH | `cula_internal` speaker, single line "Five thousand. That is most of her month." Halina.json `client_meeting_close` covers the fee beat but doesn't render Cula's internal reaction. **Recommend defer** to a "Cula internal channel" dispatch design (idle_flavor lift, or a dedicated post-state internal-monologue rendering pass in DialogueRunner). |
| `cula_b8_blunt_procedural_open` | DUPLICATIVE | halina.json `client_meeting_r0_response_blunt` line 58 has `{"speaker": "cula", "text": "Mrs. Sikorska. I wanted to ask about the notice first. Date, receipt, and who brought it to you."}`. Close match. Delete cula.json state. |
| `cula_b8_blunt_procedural_internal_fee` | NO_DISPATCH | Same defer as the sympathetic internal_fee. |
| `cula_b8_technical_open` | DUPLICATIVE | halina.json `client_meeting_r0_response_technical` line 78 has `{"speaker": "cula", "text": "Mrs. Sikorska. The lease chain. Walk me through it from the beginning."}`. Close match. Delete cula.json state. |
| `cula_b8_technical_internal_fee` | NO_DISPATCH | Same defer. |
| `cula_b8_dwell_options` | DUPLICATIVE | The b8 dwell pattern is handled in halina.json via the r1/r2 question rounds (`client_meeting_r1`, `client_meeting_r2`) which present further choices per stance. The cula.json apartment/referral/taught trio doesn't map cleanly onto halina's r1 (Wójcik / notice / renumbering) and r2 (landlord contact / cooperative office / renewal address) question banks. **Design call:** are the apartment/referral/taught dwells additional rounds (r3?), or are they superseded by the r1/r2 system? The halina.json architecture suggests superseded. Recommend: delete cula.json states unless a Design pass restores them as a "biographical" r3 round. |
| `cula_b8_dwell_apartment_reply` | DUPLICATIVE | Same. Halina's biographical content is already in `client_meeting_r0_response_high` (father's lease, 1962, Mrs. Wójcik). |
| `cula_b8_dwell_referral_reply` | GAP/DESIGN_CALL | "How did you find us?" plants Murrow's reputation outside the firm per `_comment`. Not in any current halina state. **Design call:** is this a worthwhile plant for Ch4? If yes, inline into `client_meeting_r2` or a new state. Recommend: surface to Design for go/no-go before authoring. |
| `cula_b8_dwell_taught_reply` | GAP/DESIGN_CALL | "What did you teach?" plants Polish-literature literary reference. Not in any current halina state. The halina bible may have this content; check `narrative_revision/bibles/halina_sikorska.md`. Same call as above. |
| `cula_b8_cardiologist_silent_reaction` | NO_DISPATCH | `silent: true`, `cula_internal`. The cardiologist plant beat in halina.json `client_meeting_close` line 211 ("I will need to reschedule with my cardiologist again. He is patient with me.") has no Cula reaction beat. Per cula.json `_comment`: "NO Cula reaction line. No italics, no clutched chest. The player either notices it or doesn't. This state is a deliberate silent:true entry." This is intentional silence — DELETE from cula.json (the discipline is already in the lack of Cula reaction in halina.json). |
| `cula_b8_literary_epigram_reaction` | GAP | "I will try to make the visit worth the timing, Mrs. Sikorska." halina.json `client_meeting_close` line 224 has Halina's epigram ("You go to a lawyer like you go to a doctor: too late.") but no Cula reply. Inline as a per-line slot after line 224. Speaker `cula`. |
| `cula_b8_halina_closeout` | GAP | "Murrow. Archive Room?" halina.json `client_meeting_close` ends with Halina's "Thank you, Dr. A. Cula. Mr. Crab. Mr. Whimsy. Mr. Murrow." (line 229) — no bridge to Beat 9. Inline as a per-line slot at the very end. Speaker `cula`. Note: the b9 archive scene doesn't exist yet (NO_DISPATCH above), so this bridge line is the only Beat 8 → Beat 9 narrative cue currently in the file. |

**Net halina.json patch:** two inline inserts (b8 literary-epigram Cula reply; b8 closeout bridge to b9). Ten cula.json states queued for deletion. Three NO_DISPATCH internal states deferred. Two states surfaced as Design questions (referral / taught).

---

## Out-of-strict-scope tallies (reference only)

These targets are out of the explicit task scope but appear in the full report.

### judge_district_ch1.json (5 cula states)

All Beat 12 court round responses. judge_district_ch1.json carries the judge's voice; Cula's responses to round 1 / round 2 / round 3 remedy lines need to be inlined either there or in a separate court-orchestration data file. **Defer to court round 1/2/3 dialogue authoring sprint.**

### postcard_swine_ch1.json (2 cula states)

`cula_b14_postcard_reaction` already inlined per F4 partial in 2026-05-19 SPRINT_LOG (the `_comment` references the source id). `cula_b14_chapter_close` is the navigation cue. **Recommend:** inline as a per-line slot at the end of postcard_swine_ch1.json's chapter_close state. One line for review.

### ambient (4 cula states)

`cula_b1_arrival_observation`, `cula_b2_office_first_impression`, `cula_b8_office_return_internal`, `cula_b9_kundera_beat` — all `cula_internal` speakers, no NPC anchor. **Recommend:** lift the most evocative into `cula.json::idle_flavor` (which is dispatched by the family-photo interactable per existing pattern) OR design a zone-trigger ambient channel that fires Cula internal observations on entering specific rooms. Defer.

### unresolved (5 cula states)

`cula_b8_dwell_options`, `cula_b9_archive_setup`, `cula_b9_dwell_how_options`, `cula_b9_archive_close`, `cula_b13_victory_internal`. The first belongs to halina.json (NO_DISPATCH per Halina recon above — handled). The middle three belong to the Beat 9 Archive scene (NO_DISPATCH per Murrow recon above — deferred). The last belongs to Beat 13 return (NO_DISPATCH — deferred). All accounted for in deferral buckets above.

---

## Summary table

| Target | Inline edits | New states | Deletions | Deferred |
|---|---|---|---|---|
| asia.json | 2 | 0 | 5 | 0 |
| pig.json | 3 + 1 replace | 4 (dwell trio + options state) | 6 | 0 |
| murrow.json | 1 insert + 1 replace | 5 (dwell trio + options + b13) | 6 | 7 (Beat 9 scene + b13 ledger) |
| crab.json | 0 | 5 (dwell trio + options + b13) | 6 | 0 |
| whimsy.json | 0 | 5 (dwell trio + options + b13) | 5 | 0 |
| halina.json | 2 | 0 | 10 | 3 (internal_fee × 3) |
| **subtotals (in-scope)** | **8 + 2 replaces** | **19** | **38** | **10** |
| postcard_swine_ch1.json | 1 | 0 | 1 | 0 |
| judge_district_ch1.json | — | — | — | 5 |
| ambient | — | — | — | 4 |
| **totals** | **9 + 2 replaces** | **19** | **39** | **19** |

cula.json after the patch retains: `family_photo_ch1`, `family_photo_ch1_repeat`, `idle_flavor`, **plus 17 NO_DISPATCH / deferred states** (4 ambient + 6 Beat 9 + 2 Beat 13 + 5 judge_district + 3 internal_fee + the family-photo two). Total file size shrinks roughly by half.

---

## Open design questions for human review

1. **Internal-monologue dispatch.** Cula's `cula_internal` speaker states have no shipped rendering channel. Options: (a) lift to idle_flavor and let them surface on family-photo re-interaction; (b) author a per-zone ambient trigger that fires on room entry; (c) extend DialogueRunner to render `cula_internal` as a non-dialogue thought balloon UI element. **Recommend:** pick before authoring the b8 internal_fee inlines.

2. **b3 Pig dwell-trio Pig replies.** Cula's dwell prompts need Pig replies authored. The `_comment` describes the expected register; not the actual line. Either Design authors the replies as part of this sprint, or the dwell options ship as "Cula-monologue dead ends" until Design lands them.

3. **b8 Halina referral / taught dwells.** Are these worthwhile plants given the trust-meter r1/r2 system already absorbs the biographical surfacing? If yes, where do they slot (new r3, or post-r2 close-state choices)? Halina bible reference required.

4. **Beat 9 Archive Room dispatch.** Without a live state writing `chapter1.archive_research_complete`, six cula.json states have nothing to bind against. The Archive Room scene + Murrow archive state machine is the prerequisite work; F4 cannot close cleanly until this sprint lands.

5. **cula.json's role post-F4.** After fan-out, cula.json becomes: family-photo interactable dispatch + a "deferred / waiting-on-scene" bucket of 17 NO_DISPATCH states. Two options: (a) keep deferred states in cula.json as the "voice-doc consolidated reference" per the original `_authoring_note`; (b) move deferred states to `data/_drafts/cula_deferred.json` so cula.json is exclusively the family-photo file. **Recommend (a)** — keeps voice continuity in one place; the `_authoring_note` already explains the staging arrangement.

---

## Sequencing recommendation for the actual F4 patch (when authored)

1. **Inline edits first** (10 patches: 8 inserts + 2 replaces). These are surgical and unambiguous. Land in one commit.
2. **New states second** (19 new states across 5 NPC files). These need Design review of the dwell-NPC reply lines before commit. Land per-NPC when each NPC's replies are signed off.
3. **Deletions third** (38 in-scope + 1 postcard deletions from cula.json). Only after target inlines + new states are merged and verified. Land in one commit. Run `tools/fanout_cula.py` after to confirm the post-prune state.
4. **Deferred buckets** stay in cula.json until their dispatch scenes (Beat 9 archive, Beat 13 return, internal-monologue channel, ambient zone triggers) land in separate sprints. Do not delete prematurely.

End of recon.
