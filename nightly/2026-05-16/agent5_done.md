# Agent 5 — Murrow voice pass — done

## Deliverable

`godot/data/_drafts/murrow_player_driven_final_2026-05-16.json` — voice-finalized cut of `murrow_player_driven_2026-05-15.json` (committed at `ba6c094`). 133 lines, 14,600 bytes. JSON-valid (`python3 -m json.tool` clean).

Single scoped commit: see "Commit" section below.

## What this draft does

Voice pass over the structural reshape Agent 4 (or the prior author) drafted in `murrow_player_driven_2026-05-15.json`. Every line audited against `style_canon.txt` §Murrow (the canon authority per `narrative_revision/ai_voice_constraints.md` authority hierarchy) and against the worktree-modified `godot/data/dialogues/murrow.json`'s in-flight voice-pack discipline (Sessions 37–38). Two canonical anchors preserved verbatim from `style_canon.txt` (per V1.2 pass-4/5/6 calibration):

- *"It is Murrow, to friends. The 'Mister' I keep for invoices."*
- *"I am still deciding whether reception staff qualify as friends or as workplace constellations."*

## States in this draft (per-state, with line counts and Taste Standard verdict)

**`murrow_first_meeting`** (RESHAPED — load-bearing). 13 lines. Murrow names file-facts; Cula synthesizes. The motion-to-set-aside line is removed from this state and migrates to `murrow_post_frame_attaches_motion`. Verdict: 5/5 every line. The reshape lands the "Murrow does not name the conclusion" contract — Murrow now produces seven file-facts (case name, addresses, renumbering, countersignature, ex parte hearing, third-party deliverer, actual-notice date, time-limit-as-KPC-fact, binder/memo locations, retention status) without saying "the landlord knew" or "we file." Cula must produce the synthesis at Crab.

**`murrow_post_frame_attaches_motion`** (NEW). 4 lines. Fires post-Crab on the well-fitted frame. Murrow attaches procedural vehicle to the shape Cula named. Four short factual sentences ("We file a motion to set aside. Fourteen days from actual notice. We are inside the window. Hearing rescheduled, merits preserved."), then the client-arrival directive. Verdict: 5/5. The procedural-attachment beat lands because Murrow names *what we file* and *what window we are inside*, neither of which is the SHAPE — Cula already produced the shape ("wrong-door service") in her line.

**`murrow_post_frame_walks_back`** (NEW). 5 lines. Fires post-Crab on the wrong-shape frame. Murrow walks Cula back as archival fact, not rebuke — "I have filed the motion to set aside on the service defect. The merits stay where they are." The motion has been filed regardless because the KPC clock does not wait. Verdict: 5/5. The two states sound DIFFERENT in rhythm: `attaches_motion` is four facts attaching procedure to shape; `walks_back` is two corrective declaratives plus an inventory of what has happened. Neither feels punitive or weightless.

**`has_binder_pre_crab`** (RESHAPED). 3 lines. Reshape pulls back Murrow's old "Nothing else moves until service is checked" (which named the doctrinal task); the new line points to binder pages without naming their contents. Cula's "Page one and page two" echo preserved. Verdict: 5/5.

**`court_readiness_check`** (RESHAPED). 13 lines. The closing-order line ("Service first. Fair hearing second. Remedy last.") moves from Murrow's voice to Cula's voice — Murrow asks ("Cula. State the order."), Cula states. No new flag added in this cut (no SAVE_VERSION bump for `chapter1.closing_order`; v2 deliverable). Asia's address form fixed from worktree's `Mr. Cula` typo to canonical `Dr. A. Cula`. Verdict: 5/5.

**`idle_flavor`**. 3 lines preserved from worktree voice-pack. Verdict: 5/5. Line 2 ("Ensure every form is stamped in triplicate.") is the marginally weakest — slightly imperative; could take an ironic-gloss polish in a later pass ("That is the number." or similar) — kept as-is per task guidance.

## Audit results (dialogue lines only — comments / provenance blocks excluded)

| Audit | Target | Actual |
|---|---|---|
| Em-dash count in dialogue | ≤1/line outside Pig kraken | 0 (zero across all 41 dialogue lines) |
| Address-form forbidden (`Doctor Cula` / `Mr. Cula`) | 0 | 0 |
| Scrub-list (`delve`/`tapestry`/`myriad`/`vibrant`/`showcase`/`essence of`/`heart of`/`robust`/`intricate`/`weave`/`intersection`/`Indeed,`/`Moreover`/`Furthermore`/`let me be clear`/`to be honest`/`one might argue`) | 0 | 0 |
| `navigate` metaphorical | 0 | 0 (the 1 hit is Pig's canon "We navigated by panic alone" kraken-interjection line) |
| Friend invitation verbatim | preserved | ✓ |
| Asia hedge verbatim | preserved | ✓ |
| Adjective-cut count from seed (decorative adjectives removed in this pass) | report | 1 (cut "Statute on time-limits" preamble in line 5 of `murrow_first_meeting`; resulting line is cleaner archival fact) |
| Flag cross-reference (every `chapter1.*` in trigger/on_dismiss resolves) | all resolve | ✓ all 9 flags (`met_pig`, `met_murrow`, `recruited_crab`, `proposed_frame`, `halina_met`, `has_law_binder`, `has_rights_memo`, `recruited_whimsy`, `court_ready`) found in `state.gd` reset_state() |

## Deviations from the seed draft (documented)

1. **`murrow_first_meeting` line 5**: "Statute on time-limits is fourteen days from actual notice. The math is yours." → "The time-limit is fourteen days from actual notice. The math is yours." Drops the slightly awkward "Statute on time-limits is" preamble; Murrow names the fact cleanly. The "math is yours" synthesis-handoff line preserved verbatim.
2. **`murrow_first_meeting` Cula's response to friend invitation**: seed's "Then it's Murrow." → "Then it's Cula." This matches V1.2 pass-4 calibration (preserved in V1.2 pass-5 and pass-6 drafts; preserved in worktree murrow.json) — Cula reciprocates the address-form invitation. The seed's "Then it's Murrow." was a regression.
3. **`murrow_post_frame_attaches_motion` line 3**: removed em-dash. "Fourteen days from actual notice — we are inside the window. Hearing rescheduled, merits preserved." → "Fourteen days from actual notice. We are inside the window. Hearing rescheduled, merits preserved." Murrow's rhythm is period-separated facts.
4. **`murrow_post_frame_attaches_motion` line 4** AND **`murrow_post_frame_walks_back` line 4**: bare "Halina is at one" → "Mrs. Sikorska is at one." Per the bible's honorific-always rule for client address and the firm's collective register at client-arrival beats (per `halina.json` `client_meeting_intro` / `_close`). Task prompt explicitly allows this switch.
5. **`murrow_post_frame_walks_back` line 3**: "The merits are not the door we are at. The door we are at is service." → "The merits are not before the court. Service is." The "door" metaphor belongs to Whimsy's voice (per PROPOSAL §1 Whimsy section) and to Cula's procedural-vocabulary — not Murrow's. style_canon §Murrow rules out metaphor; absence-of-metaphor is the discipline.

## Specific notes on load-bearing moments

**The address-form shift inside `murrow_first_meeting` around the friend invitation.** Cula's first speech-act in this state is "Thank you, Mr. Murrow." (pre-invite address). Murrow then invites: "It is Murrow, to friends. The 'Mister' I keep for invoices." Cula's response "Then it's Cula." is the address-form reciprocation — Cula offers Murrow the right to call him Cula. From this point forward in the state and onward in the chapter (per AGENTS.md §Address forms), Cula says "Murrow" privately and Murrow says "Cula" privately. The shift lands cleanly inside the same state; no later state needs to re-introduce the rule.

**Procedural attachment in `murrow_post_frame_attaches_motion` without naming the shape Cula named.** Cula's line in this state is "Wrong-door service. I told Crab we file." — Cula owns the SHAPE. Murrow's response does NOT echo back the shape ("Yes, wrong-door service was the right call"); Murrow attaches the PROCEDURAL VEHICLE ("We file a motion to set aside.") and names the WINDOW ("Fourteen days from actual notice. We are inside the window."). Cula's synthesis is treated as a given, not validated. The voice discipline is: Murrow does not reward Cula for being right. He proceeds.

**Soft-fail walk-back in `murrow_post_frame_walks_back` without rebuke.** The mechanic per PROPOSAL §4 is that the motion is filed regardless because the KPC deadline does not wait for the player to find the shape. The voice must land this as inventory of what has happened, not as criticism of what Cula proposed. The state opens with Murrow's archival report ("Crab tells me you proposed the merits."), Cula owns ("I did."), Murrow names what is true ("The merits are not before the court. Service is.") and what he has already done ("I have filed the motion to set aside on the service defect. The merits stay where they are."), client-arrival directive ("Mrs. Sikorska is at one."), Cula closes ("Understood."). No "you should have" / "next time" / "you got this wrong." The walk-back IS the consequence.

## Note for the human merging

The `_states_unchanged_from_live_murrow_json` list in this draft is the merge guide: `before_pig`, `after_pig`, `state_2_response_friendly`, `state_2_response_professional`, `state_2_response_dry`, `post_briefing_pre_binder`, `murrow_coffee_reaction_perfect`, `murrow_coffee_reaction_bad` stay as they are in the worktree-modified `godot/data/dialogues/murrow.json` (Sessions 37–38 voice-pack). The five states in this draft (`murrow_first_meeting`, `murrow_post_frame_attaches_motion` [new], `murrow_post_frame_walks_back` [new], `has_binder_pre_crab`, `court_readiness_check`) replace the worktree's bodies.

When merging, also fix the worktree's Asia line at the bottom of `court_readiness_check`: change `"Mr. Cula"` to `"Dr. A. Cula"` (Asia's canonical address form per AGENTS.md). This draft already carries the fix.

## Bible-versus-canon contradiction (per task halt protocol)

`narrative_revision/voice_agents/murrow.md` (worktree-modified — has uncommitted edits) describes a revised "wry, explanatory, ironic" mentor-mode register with relaxed adjective rules (multiple short permitted) and longer explanatory turns (cite + ironic gloss + directive shape). `style_canon.txt` §Murrow (HEAD) still describes the older register: "understated, archival, faintly amused. Short declarative sentences. Almost never uses adjectives. When he does, it lands." Worktree `godot/data/dialogues/murrow.json` (post-Session-37/38 voice-pack) uses the older register.

Per the authority hierarchy stated in `narrative_revision/ai_voice_constraints.md` (`style_canon.txt > bibles/*.md > this document`), `style_canon.txt` wins. This draft matches style_canon + the worktree voice-pack discipline. The bible's revised mentor-mode register has not propagated to canon or to the committed dialogue file. **For the human**: either the bible needs to roll back to match canon, or canon needs to be updated to match the bible — but the divergence should be resolved before the next voice pass, because the two registers are not interchangeable. NOT halting on this — the task prompt's described constraints match canon and the worktree voice-pack, and that's what this draft delivers.

## Notes for adjacent agents

**For Agent 9 (QA audit)**: this draft references `chapter1.proposed_frame`, which Agent 3 may be registering in `chapter1.json.new_state_flags`. Confirmed present in `state.gd` `reset_state()` at line 175 (SAVE_VERSION 17 scaffolding). If Agent 3 lands the chapter1.json registry entry, the cross-reference resolves through both surfaces; if not yet, the state.gd presence is sufficient for runtime. No gap.

**For Agent 8 (dialogue editor)**: no new option-block shapes used in this draft. `court_readiness_check` uses spoken-line synthesis (Cula's "Service first..." line) rather than an option block, deliberately deferring `chapter1.closing_order` enum to a v2 SAVE_VERSION bump. Feature request: if Agent 8 has bandwidth, consider enum-validation hook for `chapter1.proposed_frame` against `data/argument_frames_ch1.json` keys — this draft's triggers on `proposed_frame == 'defective_service_135bis'` and `proposed_frame == 'merits_defence'` are content-coupled to the frames file.

## File ownership respected

Wrote only `godot/data/_drafts/murrow_player_driven_final_2026-05-16.json` (Design-owned drafts directory). Did not touch `godot/data/dialogues/murrow.json` (in-flight worktree voice-pack). Did not touch `narrative_revision/voice_agents/murrow.md` (modified in worktree; left for upstream agent or human).

## Commit

`3bf3800` — `Murrow voice pass: player-driven argument synthesis (draft)`. 2 files changed, 216 insertions(+). No code touched; only the new draft JSON and this report.
