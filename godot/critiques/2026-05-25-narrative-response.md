---
responds_to: 2026-05-25-narrative.md
date: 2026-05-25
stance: triage + plan, with pushback where warranted
---

# Response — Narrative & Dialogue critique, 2026-05-25

## Verification summary

Every concrete file/line claim in the critique was checked against committed
dialogue files. Eleven of twelve findings land at least partially; one is a
judgment call worth resisting. The critic also missed one hard runtime bug
in `cula.json` that is independent of the F5 fan-out problem and is worth
fixing in the same pass.

**Land cleanly.** F4 (Whimsy unauthored in court Round 2), F5 (cula.json
unreachable + duplication with NPC files), F6 (Wójcik diacritic),
F8 (dry-surprise template gated to perfect-play path only), F9 (Beat 8 close
is a 26-line monolith + Hennessy phone has no setup), F10 (~68 manual
`met_*` callsites awaiting `once: true` migration), F11 (Pig maritime tic
saturated — present in every Pig appearance in Ch1 including idle_flavor),
F7 (judge round openers are numbered templates).

**Land partially.** F1 (Murrow/Crab collapse): the named states are
genuinely flat — `murrow.json::court_readiness_check` is a fragment list,
`crab.json::after_binder_first_engagement` is a verbless date-list, and the
one-word "Acceptable." / "Heard." pair is a duplicated comedy engine. But
the critic overreaches by claiming both voices collapse globally. Murrow's
`murrow_first_meeting` carries the archival-faintly-amused register ("I am
still deciding whether reception staff qualify as friends or as workplace
constellations" and the invoices/friends couplet earn their adjectives);
Crab's "postal theatre" / "decorative gaps" / "standing in the right order"
are diagnostic. The intervention is per-state, not a rewrite-everything
pass. F2 (Halina = lawyer's voice): the intro and the incapacity rebuke are
flat, and the rebuke is a clean two-clause antithesis Cula or Murrow could
have spoken. But the critic cherry-picked. The high-trust paths carry real
texture the critic ignored: "He apologised at the door. He is a kind young
man." / "She has been a widow longer than I have been one. She is patient."
/ "I thought at the time it was just his manner. People in his position
sometimes have that manner." Those lines do exactly what the critic claims
nothing in Halina's voice does. The work is to lift the low-trust paths up
to that bar, not to author a teacher's tic from scratch.

**Push back.** F12 (Whimsy recruitment patronises): the "wrong-door file
with the right door also in the file. I have heard worse music" line is
Whimsy's cynic-aesthete register, not a critic-from-above register. He is
called out at Cula's request precisely because his rhetorical eye is what
the firm cannot otherwise produce. Whimsy auditioning the case shape
*is* his contribution at the recruitment beat; making him pious about the
client's plight on first meeting would flatten the character. F12 is a
preference disguised as a craft finding. Leave the line.

**Triage F3 (five scoldings).** The pile-on is real, but the critic's
remediation throws out a load-bearing beat. Murrow's
`murrow_post_decoy_incapacity` strips Cula's lead role at court ("you will
not argue incapacity in my courtroom"); collapsing it to a single line
loses the in-fiction stake. The correct trim is narrower: drop Whimsy's
`whimsy_post_decoy_incapacity` (the critic is right that it adds nothing
sharper), keep Crab's walkaway and Halina's rebuke and the judge's icy
remedy and Murrow's role-strip. Four voices, not five, with the firm's
in-fiction consequences (Murrow takes the lead, Crab withdraws from
drafting) preserved.

**Critic missed one bug.** `cula.json` lines 543/550/557/564 trigger on
`chapter1.casebook_judge_state == 'round2_open'` / `'round3_open'`. The
judge writes `'round_2_open'` / `'round_3_open'` (with underscore between
"round" and the digit). Even after the F5 fan-out lands, these Cula court
responses would never fire as written. They need to be normalised to the
judge's spelling when they're moved into the court flow.

---

## Plan, severity-ordered

### S1 — must land before Ch2 design work resumes

**1. Wójcik diacritic (F6).** The fix is already drafted in
`data/_drafts/nightly_dialogue_fixes_2026-05-22.json`. Apply it to
`data/dialogues/asia_hint_states_ch1.json` line 101. Then add the
diacritic-consistency rule the critic asks for to `tools/voice_audit.py`:
fail if any Polish surname appears in two spelling variants across `data/`.
Half an hour. No design discussion needed.

**2. Whimsy Round 2 court state (F4).** Author
`whimsy.json::whimsy_b12_round2_open` carrying the soup/spoon/fork-of-bees
metaphor the judge already reacts to in `judge_b12_react_r2`, plus the
Wordsworth or Shakespeare cite style_canon §2 mandates for Phase 2
closings. Three stance variants per `chapter1.client_meeting_stance` are
already specced — write all three. This is the chapter's load-bearing
rhetorical moment; until the state exists, Round 2 reacts to thin air.

**3. Cula fan-out decision (F5).** The recon work is already done in
`critiques/2026-05-24-f4-fanout-recon.md`. Commit to option (a) — finish
the fan-out by deleting DUPLICATIVE states from `cula.json`, inlining GAPs
as per-line `{"speaker": "cula", ...}` slots into the target NPC files,
and reducing `cula.json` to the family-photo dispatch states. This is the
cheaper of the two options and matches the engineering note that already
exists in `cula.json::_authoring_note`. Then **fix the round number
triggers** (`round2_open` → `round_2_open`, same for round 3) in the lines
that get inlined into the court flow. The fan-out and the trigger fix
ship in one PR.

### S2 — voice and structure work for the Ch1 polish pass

**4. Split Beat 8 close into three states (F9).** Current `client_meeting_close`
is a 26-line monolith that buries the cardiologist plant and the literary
epigram. Split as the critic recommends: (a) fee + retention + Pig
interruption + Murrow redirect; (b) cardiologist plant as discrete short
state with a beat of silence after; (c) literary epigram as discrete short
state, also with breath. Cut the "Hennessy retainer phone" reference —
Hennessy appears nowhere else in committed Ch1 and a callback to an
established firm detail (the printer, the absent Swine, the rent envelope)
serves the same interruption function without inventing a new noun.

**5. Reauthor the four flattened states (F1).** Specifically:
`murrow.json::court_readiness_check` (cut the fragment list, restore the
archival-aside register present in `murrow_first_meeting`),
`crab.json::after_binder_first_engagement` (cut the verbless date-list,
rebuild as canonical observation-then-implication pairs Crab actually uses
elsewhere), and pick one mouth for the one-word verdict — Murrow's
"Acceptable." stays (style_canon §2 names it as immense praise), Crab's
"Heard." goes (Crab's gear-shift discipline is the joke; one-word verdicts
are not his pattern). Do not attempt a wholesale rewrite of either voice;
the catalogues mostly diagnose cleanly already.

**6. Lift Halina's low-trust paths (F2).** `client_meeting_intro`,
`client_meeting_r0_response_blunt`, `client_meeting_r0_response_technical`,
and `client_meeting_r1_response_low` are the procedural-recitation states
the critic calls out. Apply the texture that already works on the
high-trust paths (the "kind young man" / "she is patient" / "people in
his position sometimes have that manner" register). Rewrite
`halina_post_meeting_decoy_incapacity_cold` so the rebuke does not land as
a two-clause antithesis — it is the cleanest sentence in the chapter and
it reads as Murrow's voice on Halina's mouth. The Iwaszkiewicz reference
flagged in story.txt Beat 8 is still missing from any committed file;
author it now into one of the Beat 8 closes (the literary epigram state
after the F9 split is the natural home).

**7. Rewrite judge openers (F7) and lift dry-surprise out of the
strong-only gate (F8).** The three Round openers in `judge_district_ch1.json`
need one diagnosable bench habit each — a docket glance, a tired
correction of how counsel framed it, a single-page wryness — instead of
"First question / Second question / Third question." Bring the
"Against several expectations" template register into
`judge_b12_react_r1_blunt_procedural` and `judge_b12_react_r1_sympathetic`
so the standard-path player hears the bench's comic voice. Move the
checklist-shaped dry-disappointment register into the wrong-answer
reactions where it currently does no work.

**8. Trim the incapacity pile-on (F3).** Delete
`whimsy.json::whimsy_post_decoy_incapacity` entirely. Keep
`crab.json::crab_post_halina_incapacity_refuses`,
`halina.json::halina_post_meeting_decoy_incapacity_cold`,
`murrow.json::murrow_post_decoy_incapacity` (the role-strip is
load-bearing — do not collapse it as the critic suggests), and
`judge_b12_remedy_narrow_incapacity`. Four voices, not five.

### S3 — sweep work, not blocking

**9. `met_*` migration to `once: true` (F10).** A scheduled sprint sweep,
not a single-PR task. For every state whose only `on_dismiss` write is a
`met_<npc>` flag and where no downstream gameplay reads the flag, replace
with `"once": true`. Keep `chapter1.met_<npc>` only where Asia hints,
route blockers, or other state-machinery reads it. Verify with a save
fixture that walks a known dwell tree and confirms no greeting repeats.
Editor work is already done (Session 30 closed the `once: true` exposure
in `dialogue_editor.html`); this is migration, not invention.

**10. Pig maritime tic decay (F11).** Cut the metaphor from
`pig.json::met_murrow_pre_binder` ("crawled below deck") and from
`pig.json::court_readiness_check` ("kraken/bait"). Keep "six weeks under
the surface" in `pig_first_meeting` — it does load-bearing work as the
chapter's first crisis-frame. Keep the idle_flavor maritime lines (they
are barker-frequency and signal "Pig is here" between scenes; that's
different from saturating every Pig appearance). Replace the cut lines
with a Hrabal-rhythm digression that wanders back to a printer-lease
detail. The Beat 13 celebration already starts the tic's recession per
the prior critique round (F9, May 19); this completes it for Ch1.

### Push back, no work

**11. F12 declined.** Whimsy's recruitment line stays as written. The
critic's reading conflates "Whimsy auditions the case as rhetorical
material" (his register) with "Whimsy patronises the client" (a different
charge that the line does not commit). Style_canon §2 explicitly names
the case-as-music pairing rule as how Whimsy engages on rhetoric. If
the line needs adjustment later because playtesters read it the critic's
way, revisit then.

---

## Standing concerns response

The critic's two standing notes both land. The `_comment` fields are
genuinely longer than the lines they justify in several places
(`cula.json::cula_b8_approach_choice` is the cleanest example, with a
seven-sentence diagnostic preceding three option lines). This is
documentation cost displacing authorship cost. The right discipline is a
single sentence per `_comment` naming what the state DOES, not what the
authoring brief asked it to do. The verbose comments can stay on draft
files in `_drafts/` if needed.

The engineering-vs-writing imbalance is real. The provenance fields,
anti-AI-voice-pass declarations, and address-form audit trails are doing
real work (they are how this critique was answerable in the first place),
but they have crowded out authorship time. The Ch2 voice work should
budget at parity: every structural decision document gets paired with
hours scheduled for the actual lines that document covers.
