# Dialogue Canon Audit — 2026-05-26

Automated run. Snapshot skipped: `.git/index.lock` held by another process (likely the Godot editor). No live files were modified.

Files audited: `cula.json`, `murrow.json`, `pig.json`, `asia.json`, `crab.json`, `whimsy.json`, `barista.json`, `judge_district_ch1.json`, `postcard_swine_ch1.json`, `halina.json`, `coffee_machine_ch1.json`, `smokers_lawyer_ch1.json`, `asia_hint_states_ch1.json`, `dialogues.json`.

`meeting_room_stance.json` — listed in audit scope but **does not exist** in `data/dialogues/`. Per MEMORY.md entry `feedback_pig_swine_meeting_room_stance_rejected.md`, the separate NPC state-machine was intentionally rejected; `halina.json` inline chain handles the stance pick. File removal is intentional and correct.

`dialogues.json` — empty legacy schema shell (`"npcs": {}`). No dialogue content to audit.

---

## Address Form Violations

None found.

`halina.json::client_meeting_intro` — Murrow says "Dr. A. Cula will lead." This was initially flagged as a possible conflict with `murrow.json` provenance (which states bare "Cula" post-first-meeting). Confirmed correct by Piotr 2026-05-26: the distinction is **private/partner-only scenes** (bare "Cula") vs. **client or third-party-present scenes** ("Dr. A. Cula"). The Beat 8 client meeting has Mrs. Sikorska present, so the formal form is correct. Memory updated accordingly.

The `murrow.json` provenance phrase "including formal contexts like court and client-facing scenes" is an authoring error — it overstates the rule. The correct rule (now in memory) is audience-based, not introduction-triggered.

---

## Canonical Name Misspellings

No misspellings found. All canonical names (`Dr. A. Cula`, `Mr. Pig`, `Mr. Swine`, `Murrow`, `Crab`, `Whimsy`, `Asia`, `Mrs. Sikorska`) are spelled correctly across all audited files.

---

## Gender Errors

No gender errors found. Cula (he/him) is not referred to by pronoun in any audited file. No "she", "her", or equivalent applied to Cula.

---

## Taste Standard Flags

| File | State ID | Issue Type | Line Text |
|------|----------|-----------|-----------|
| `murrow.json` | `court_readiness_check` | **Generic filler opener** — "Understood" is on the filler-word list (AGENTS.md §Taste Standard). The following punchline ("We will keep the printer informed.") rescues the beat, but the opener could be stronger. | `"Understood, Mr. Pig. We will keep the printer informed."` |
| `murrow.json` | `state_2_response_friendly` | **Voice register flag** — "the famous, promising and talented new hire" runs three adjectives for Murrow, whose AGENTS.md register is archival, low-affect, understated. The line may be intended as dry sarcasm (plausible given Murrow's register), but read flat it sounds warmer than Murrow's established voice. No outright violation; flagged for author awareness. | `"Well, well, well. Dr. A. Cula, the famous, promising and talented new hire."` |

---

## Placeholder / Stub Lines

All TODOs below are intentional authoring stubs placed by the 2026-05-25 fan-out sprint per the "you author, I wire" decision. They are not errors in the dialogue runner sense (states have `once: true` and clear `state_choice` on dismiss), but they will render raw bracket-text to players if the game is run before Piotr authors the content.

| File | State ID | Current |
|------|----------|---------|
| `asia.json` | `hint_blue_folder` | Lines array contains `"_doc: DRAFT - Asia points Dr. A. Cula to the blue folder…"` — a doc-string inside the live `lines` array, not a playable line. This state also has `"trigger": "chapter1.met_asia && !chapter1.has_case_folder"` which means it can fire at runtime. **Priority: high** — this is the only stub whose trigger can fire during normal play without a TODO-pattern guard. |
| `murrow.json` | `murrow_b4_dwell_tenure_reply` | `"[TODO 2026-05-25: Piotr to author Murrow's reply…]"` |
| `murrow.json` | `murrow_b4_dwell_pattern_reply` | `"[TODO 2026-05-25: Piotr to author Murrow's reply…]"` |
| `murrow.json` | `murrow_b4_dwell_client_reply` | `"[TODO 2026-05-25: Piotr to author Murrow's reply…]"` |
| `pig.json` | `pig_b3_dwell_case_reply` | `"[TODO 2026-05-25: Piotr to author Pig's deflection…]"` |
| `pig.json` | `pig_b3_dwell_okay_reply` | `"[TODO 2026-05-25: Piotr to author Pig's brief admission…]"` |
| `pig.json` | `pig_b3_dwell_swine_reply` | `"[TODO 2026-05-25: Piotr to author Pig's reply about Swine's absence…]"` |
| `crab.json` | `crab_b5_dwell_background_reply` | `"[TODO 2026-05-25: Piotr to author Crab's reply…]"` |
| `crab.json` | `crab_b5_dwell_why_here_reply` | `"[TODO 2026-05-25: Piotr to author Crab's reply…]"` |
| `crab.json` | `crab_b5_dwell_case_opinion_reply` | `"[TODO 2026-05-25: Piotr to author Crab's reply…]"` |
| `whimsy.json` | `whimsy_b7_dwell_office_reply` | `"[TODO 2026-05-25: Piotr to author Whimsy's reply…]"` |
| `whimsy.json` | `whimsy_b7_dwell_case_read_reply` | `"[TODO 2026-05-25: Piotr to author Whimsy's reply…]"` |
| `whimsy.json` | `whimsy_b7_dwell_office_visits_reply` | `"[TODO 2026-05-25: Piotr to author Whimsy's reply…]"` |
| `halina.json` | `client_meeting_dwell_referral` | `"[TODO 2026-05-25: Piotr to author Halina's reply…]"` |
| `halina.json` | `client_meeting_dwell_taught` | `"[TODO 2026-05-25: Piotr to author Halina's reply…]"` |
| `smokers_lawyer_ch1.json` | `smokers_lawyer_ambient_stub` | Entire file is a voice-spec stub (`_voice_spec_pending: true`). The single state has `"tags": ["stub", "voice_spec_pending"]` and is a voice-neutral stage direction. **Not a concern** — correctly tagged, intentional, documented. |

---

## Summary

**0 objective violations** (address form / names / gender) across all audited files.

**0 canonical name misspellings** across all audited files.

**0 gender errors** across all audited files.

**2 quality flags** for human review: `murrow.json::court_readiness_check` (filler opener "Understood"); `murrow.json::state_2_response_friendly` (three-adjective line slightly warm for Murrow's archival register — likely intentional sarcasm, flagged for awareness).

**15 placeholder/stub lines** across 6 files — all intentional 2026-05-25 fan-out TODOs pending Piotr authoring. `asia.json::hint_blue_folder` is highest priority: the raw `_doc: DRAFT` string sits in the live `lines` array with a trigger that fires in normal play. All other stubs are dwell states gated by explicit player choice.

**1 authoring correction to apply**: `murrow.json` provenance phrase "including formal contexts like court and client-facing scenes" misstates the Murrow address-form rule. The correct rule (confirmed 2026-05-26) is audience-based: bare "Cula" in private/partner-only scenes; "Dr. A. Cula" when a client or third party is present. The provenance note should be updated in a future Design sprint to prevent future confusion.
