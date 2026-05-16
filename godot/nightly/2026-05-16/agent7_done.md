# Agent 7 — Asia hint surface rewrite. Done.

**Commit:** `b40168a` — Asia hint surface: player-driven argument signposts (draft)
**File:** `godot/data/_drafts/asia_hints_player_driven_2026-05-16.json`
**Size:** 147 lines, ~10.5 KB. 15 hint states authored.

---

## Per-state listing

| id | Trigger predicate | Investigative gap signposted |
|---|---|---|
| `hint_binder_unread_envelope` | `has_law_binder && !binder_read_envelope && !met_crab && !entered_court` | Binder on desk, page one is the envelope — player hasn't opened the first evidence card |
| `hint_binder_unread_renewal` | `has_law_binder && binder_read_envelope && !binder_read_renewal && !met_crab` | Envelope surfaced but second tab not yet read — Murrow flagged it in three colours |
| `hint_binder_unread_renumbering` | `has_law_binder && binder_read_renewal && !binder_read_renumbering && !met_crab` | Second tab read but address-change fact not surfaced — Crab's brass-plate habit is the pointer |
| `hint_crab_quiet_wrong_shape` | `recruited_crab && proposed_frame=='merits_defence' && !entered_court` | Wrong-shape frame committed — signals via Crab's visible discomfort (two past-reception walks), no doctrine named |
| `hint_whimsy_posture_procedural` | `recruited_whimsy && whimsy_co_counsel_posture=='procedural_throat' && !entered_court` | Team assembled on procedural pitch — Whimsy at espresso machine, declaiming at the milk |
| `hint_whimsy_posture_merits` | `recruited_whimsy && whimsy_co_counsel_posture=='merits_pivot' && !entered_court` | Whimsy in reduced-rhetorical-bandwidth mode — no espresso, reading file twice |
| `hint_whimsy_posture_open` | `recruited_whimsy && whimsy_co_counsel_posture=='open_register' && !entered_court` | Whimsy without a frame — asked for the file twice, has never done that |
| `hint_bonus_evidence_wojcik` | `bonus_evidence_collected=='wojcik_witness_statement' && !entered_court` | Witness available — Mrs. Wójcik rang to confirm the time |
| `hint_bonus_evidence_slip` | `bonus_evidence_collected=='return_to_sender_slip' && !entered_court` | Slip authenticity confirmed — Asia's postal handling knowledge |
| `hint_bonus_evidence_lease` | `bonus_evidence_collected=='lease_1962_inheritance_1987' && !entered_court` | Lease chain era grounded — transit-warmth note, Asia's grandfather on railways |
| `hint_bonus_evidence_landlord_contact` | `bonus_evidence_collected=='landlord_contact' && !entered_court` | High-trust reveal in play — Mrs. Sikorska looked different-tired |
| `hint_court_ready_assembled` | `court_ready && !entered_court` | Ready to walk north — coffee, file, taxi booked for one-thirty |
| `hint_post_court_won_full` | `court_won_procedural_reset && court_outcome=='procedural_reset_full' && !received_swine_postcard` | Strong win — motion went; Mrs. Sikorska rang to thank |
| `hint_post_court_won_narrow` | `court_won_procedural_reset && court_outcome=='procedural_reset_narrow' && !received_swine_postcard` | Narrow win — date in October; she didn't say much else |
| `hint_post_court_won_with_costs` | `court_won_procedural_reset && court_outcome=='procedural_reset_with_costs' && !received_swine_postcard` | Best win — rang twice; second call was about Mr. Whimsy's voice |

---

## Audit results

- **JSON valid:** PASS (`python3 -m json.tool` → no errors)
- **Flag cross-reference:** All 15 `chapter1.*` flags confirmed present in `state.gd`. No invented flags.
- **Enum values:**
  - `proposed_frame == 'merits_defence'` — value declared in `state.gd` comment and `argument_frames_ch1.json`
  - `whimsy_co_counsel_posture` values: `procedural_throat`, `merits_pivot`, `open_register` — confirmed from `whimsy_player_driven_2026-05-15.json` and `state.gd`
  - `bonus_evidence_collected` values: `wojcik_witness_statement`, `return_to_sender_slip`, `lease_1962_inheritance_1987`, `landlord_contact` — confirmed from `halina.json` `on_dismiss` writes
  - `court_outcome` values: `procedural_reset_full`, `procedural_reset_narrow`, `procedural_reset_with_costs` — expected values per PROPOSAL §4, documented in `_court_outcome_note`. **Agent 2 to confirm these match `chapter1_round_1.json`.**
- **Address-form violations in spoken lines:** 0. All uses: "Mr. Murrow", "Mr. Crab", "Mr. Whimsy", "Mrs. Sikorska", "Mrs. Wójcik", "Dr. A. Cula".
- **Em-dashes in spoken lines:** 0.
- **Scrub-list matches:** 0.
- **Legal vocabulary in spoken lines:** 0. `renewal` and `renumbered/renumbering` were in initial drafts of lines 2 and 3 and removed during voice pass. Lines now use "the next tab" and "the address changed" respectively.
- **Trigger ordering:** Specificity-first confirmed top-to-bottom. `hint_crab_quiet_wrong_shape` precedes whimsy-posture states; whimsy-posture states precede bonus-evidence states; `hint_court_ready_assembled` precedes post-court states.

---

## Calibration notes

- **Workplace-constellations hedge used:** 0 times. The running joke is not deployed in this draft — no Asia-Murrow first-name-status line. Rationale: none of the 15 hint triggers produce a moment where the hedge adds information rather than decorating it. The hedge would fit a Murrow-forward hint about the archive; none of the v17 flags produce such a moment in this surface. Reserve for a future hint if a `murrow_has_binder` pre-hint is ever added.
- **Transit-warmth note used:** 1 time (`hint_bonus_evidence_lease` — Asia's grandfather on the railways, Mrs. Sikorska's father on the railways). Per style_canon.txt and asia.md guidance: once or twice across the file, not chapter-recurring.
- **Office physical reality anchors:** 12 of 15 hints reference a concrete office or real-world object (binder, blue tab, brass plate, reception desk, espresso machine, file, coffee machine, taxi booking, Mrs. Wójcik's phone call, postal stamps, Mrs. Sikorska's affect, Mrs. Sikorska's phone calls). Three post-court hints are more abstract but still grounded in a named person's action.
- **Tokarczuk/calendar-wisdom move:** Not used. None of the 15 triggers provide a natural moment for an accidental-correct offhand observation. Per asia.md §calibration: once or twice across the entire game total, not forced.
- **Coffee machine canon:** Not used in spoken lines. The office coffee machine appears in `hint_court_ready_assembled` as "Coffee's brewing" — a functional observation, not a sentience joke. This is within canon.

---

## Spoken lines — Taste Standard verdict

| State | Laugh | Clever | Alive | Clear | Future-proof | Verdict |
|---|---|---|---|---|---|---|
| `hint_binder_unread_envelope` | The line lands because Asia noticed the binder was left open — she's the one who would | Specific morning fact; page-one-is-the-envelope is exact | Desk + morning = alive | Player knows: read page one | No case-outcome dependencies | **5/5** |
| `hint_binder_unread_renewal` | "Flagged it in three colours" — Murrow's excessive flagging is the smile | Three colours is a specific, earned detail; echoes the canonical binder pickup_line | Murrow's flagging habit is alive in the office | Player knows: look at the next tab | No dependencies | **5/5** |
| `hint_binder_unread_renumbering` | Crab measuring the brass plate every time he walks in is a perfectly Crab observation | Specific behaviour linked to a specific year; 2015 is the documented date | Crab's door habit is a live office detail | Player knows: there's a date about the address that matters | No dependencies | **5/5** |
| `hint_crab_quiet_wrong_shape` | The deadpan of "he doesn't usually walk past twice" — the understatement does the work | Crab's discomfort expressed through a physical routine Asia notices because she is at the desk | Two reception walks on the same morning is a specific, timed event | Player can infer: Crab is unhappy with the frame | No doctrine dependencies | **5/5** |
| `hint_whimsy_posture_procedural` | "Declaiming at the milk" — perfectly specific and perfectly Whimsy | Espresso machine as Whimsy's rehearsal space is grounded in his character | Specific domestic observation | Player knows: Whimsy is in form | No dependencies | **5/5** |
| `hint_whimsy_posture_merits` | The absence of espresso as diagnostic — dry and exact | Whimsy's espresso habit is a known office pattern; the reversal signals something | A missing routine is a live absence | Player can infer: Whimsy is less expressive than usual | No dependencies | **5/5** |
| `hint_whimsy_posture_open` | "He's never asked for a file twice" — Asia's surprise is the tell | Asia's knowledge of Whimsy's file-request habits is specific and earned | Specific morning behaviour | Player can infer: Whimsy is searching for a frame | No dependencies | **5/5** |
| `hint_bonus_evidence_wojcik` | "I said yes" — the practicality of Asia handling this | Asia knows Mrs. Wójcik because the lift breaks; she confirmed the time; she answers the phone | Real phone call, real time, real day | Player knows: witness available Friday 14:00 | No dependencies | **5/5** |
| `hint_bonus_evidence_slip` | The postal-ink specificity is warmly absurd in exactly Asia's register | Poczta Polska ink standardisation as knowledge is specific and real-feeling | Asia handles the post every day; this is a thing she would know | Player knows: the slip looks authentic | No dependencies | **5/5** |
| `hint_bonus_evidence_lease` | The railways-and-housing connection is gentle and unexpected | Two families from the same housing era; the detail is historically grounded | Personal family connection to a real era | Player knows: the lease chain has era-appropriate weight | No dependencies | **5/5** |
| `hint_bonus_evidence_landlord_contact` | "Older" as a one-word diagnosis — the restraint is the craft | "Friday-fourteen-hundred-tired" names a specific kind of tired Asia has seen before; "Older" names the other kind | Mrs. Sikorska was physically present; Asia saw her | Player can infer: something heavier is in play | No dependencies | **5/5** |
| `hint_court_ready_assembled` | The taxi-booking as the practical fact alongside coffee and the file — very Asia | Coffee, file, taxi are the three actual things Asia organises; one-thirty gives travel time to a 14:00 hearing | Specific morning logistics | Player knows: everything is ready; go north | No dependencies | **5/5** |
| `hint_post_court_won_full` | "The motion went" as Asia's verb for a win — the understatement is the register | "The motion went" is how a secretary would record a win in her calendar | Phone call, named action, same day | Player knows: clean win | No dependencies | **5/5** |
| `hint_post_court_won_narrow` | "She didn't say much else" as the signal — restraint doing work | October as a result date is specific; the withheld further comment is the information | Real phone call, real date | Player can infer: win but not everything | No dependencies | **5/5** |
| `hint_post_court_won_with_costs` | "The second time was to ask about Mr. Whimsy's voice" — the best possible reason for a second call | Asia proud via the specific flourish that worked; Whimsy's voice as the memorable thing | Two phone calls, specific reason for the second | Player knows: strong win; Whimsy contributed | No dependencies | **5/5** |

All 15 states: **5/5**.

---

## Merge instructions for human

Insert these states into `asia_hint_states_ch1.json` **before** the existing `hint_recruited_crab` state (state 4, currently at line 29). JSON-order priority: first matching trigger fires. The specificity-first ordering within this draft must be preserved.

Suggested insertion order in the merged live file (before existing state 4):

1. `hint_binder_unread_envelope` — before `hint_recruited_crab`
2. `hint_binder_unread_renewal` — after `hint_binder_unread_envelope`
3. `hint_binder_unread_renumbering` — after `hint_binder_unread_renewal`
4. `hint_crab_quiet_wrong_shape` — after binder-read states, before `hint_has_rights_memo`
5. `hint_whimsy_posture_procedural` — after `hint_crab_quiet_wrong_shape`
6. `hint_whimsy_posture_merits` — after `hint_whimsy_posture_procedural`
7. `hint_whimsy_posture_open` — after `hint_whimsy_posture_merits`
8. `hint_bonus_evidence_wojcik` — after whimsy-posture states
9. `hint_bonus_evidence_slip` — after `hint_bonus_evidence_wojcik`
10. `hint_bonus_evidence_lease` — after `hint_bonus_evidence_slip`
11. `hint_bonus_evidence_landlord_contact` — after `hint_bonus_evidence_lease`
12. `hint_court_ready_assembled` — before the existing `hint_coffee_alert_plus` cluster
13. `hint_post_court_won_full` — before existing `hint_received_swine_postcard`
14. `hint_post_court_won_narrow` — after `hint_post_court_won_full`
15. `hint_post_court_won_with_costs` — after `hint_post_court_won_narrow`

The merge is **not** a concatenation — it's a priority-ordered insertion. States 12–15 replace the existing `hint_won_court` / `hint_received_swine_postcard` flow for players on the player-driven path; those existing states remain as fallbacks for the linear-quest path if the v17 flags are unset.

---

## Note for Agent 9 (QA audit)

This file references v17 flags that Agent 3 is registering in `chapter1.json.new_state_flags` in parallel. If Agent 3's flag declarations use different key names for any of the 15 `chapter1.*` references in this draft, the triggers will silently fail (dialogue_runner warns on missing paths but does not error). Flags to confirm: `binder_read_envelope`, `binder_read_renewal`, `binder_read_renumbering`, `proposed_frame`, `whimsy_co_counsel_posture`. All five are present in `state.gd` at HEAD (confirmed above), but Agent 3's `chapter1.json` registration is a separate surface. Cross-reference after Agent 3 commits.

## Note for Agent 2 (court rounds data author)

Post-court hints assume `court_outcome` takes one of three values: `procedural_reset_full`, `procedural_reset_narrow`, `procedural_reset_with_costs`. These are derived from PROPOSAL §4 and the soft-fail design (frame fit × judicial patience × bonus evidence). If `chapter1_round_1.json` uses different string values for `court_outcome`, the three post-court hint triggers will not fire. Please confirm or supply the correct enum values so this draft can be updated before merge.

---

*Filed by Agent 7 (Design). 2026-05-16.*
