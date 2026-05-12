# V1.A §J critique prompt — for Antigravity

You are running hostile critique against the V1.A pass-1 draft. Your output is the §J critique pass that the user will then arbitrate into a pass-3 commit. Do not author lines, do not arbitrate, do not commit. Critique only.

## Inputs (read first, in this order)

1. **Pack** (the canonical source): `narrative_revision/phase_7_packs/V1.A_asia_hint_states.md`. Treat as the authority on every discipline you check against.
2. **Pass-1 draft** (what you're critiquing): `narrative_revision/phase_7_drafts/V1_A_draft_pass1.md`. The 12 hint-state lines plus the cross-cutting register check are the critique surface.
3. **Reference: pass-3 V1.7 commit shape** (for tonal-baseline calibration of Asia's voice): `narrative_revision/phase_7_drafts/V1_7_draft_pass5.md` — Asia's *"Good work, Dr. Cula. The blue file is back on your desk."* and *"Mr. Pig. Postcard. The address says Sapporo."* are the V1.7 baseline.
4. **Reference: V1.1 Asia baseline** (chapter-1 Beat 2 commit): `narrative_revision/phase_7_packs/V1.1_office_opening_pig_crisis.md` §B.5 (Asia voice baseline). V1.A's 12 lines must read as register-baseline-consistent with V1.1.
5. **Reference: legacy canonical lines** (the verbatim source for states 1–6 and 9–12): `_legacy/dialogue_samples.txt` lines 50–59. Use to verify the draft's verbatim-hold claims.
6. **Reference: address-form rule** (only if needed for adjudication): the project's address-form convention is *"Mr. Pig" / "Mr. Murrow" / "Mrs. Sikorska" / "Mr. Swine" formal-titled; "Crab" / "Whimsy" bare; no "Dr. Cula" address in hint-NPC register (room-shaped).*

## Critique discipline (apply to every line)

For each of the 12 hint-state lines, check against:

1. **§A general AI tells.** Em-dash count per line (≤1; only state 5 uses one canonically — flag any drift). Contrastive antithesis (*"not X but Y"*). Banned vocabulary (*delve / tapestry / myriad / vibrant / navigate as metaphor / showcase / essence of / heart of / rich / deeply / robust / intricate / weave / intersection*). Hedge-preambles (*"let me be clear"* etc.). Symmetric paired phrases (*"not only X but Y"* / *"X, yet Y"*). Generic uplifting endings. Pet-name register (*"sweetie" / "honey"*). Exclamation marks. Rule-of-three rhythm-padding on abstractions.

2. **§A.5 language convention.** Polish in dialogue (only Café Paragraf permitted as proper place name).

3. **§A.6 social context.** Hint-NPC register held; address-form for Cula NOT used (room-shaped, not direct-address); other NPCs by formal title (Mr. Pig / Mr. Murrow / Mrs. Sikorska / Mr. Swine) or canonical bare (Crab / Whimsy).

4. **§B.1 per-character constraints — the load-bearing checks:**

   - **Sharpening.** Any line landing sharper than warm-dry-amused. The chapter-3 STUB-decline reservation is the most-protected commitment. Flag any line that approaches the *"front-desk staff have negotiating power"* / *"password to the photocopier"* register or pre-empts the chapter-3 sharp moment.
   - **Legal opinion.** Any line that frames the case's merits, the client's situation, or the firm's structure. Asia quotes Murrow / quotes Mr. Pig / does not editorialise.
   - **Editorial on Pig's panic.** Any line that names Pig's pattern explicitly. The cheerful-while-drowning register implies awareness; the line does not name it. **State 1's *"loudest crisis in the room"* is the closest approach** — pressure-test whether it reads as room-class observation or pattern-diagnosis. Pack §B.1 explicitly approves verbatim hold; if you disagree, say why specifically.
   - **Excessive cheer becoming caricature.** Sing-song-helpful overcorrection.
   - **Pre-empting reserved phrasings.** Chapter-3 STUB-decline; chapter-2 Waldek warmth; chapter-4 Bajtek call; chapter-5 backup-copy; chapter-6 brief-index. Any leakage is a categorical fail.
   - **Verbatim canonical hold check.** For states 1–6 and 9–12, the draft claims verbatim hold from `_legacy/dialogue_samples.txt §Sign and notice text samples` lines 50–59. Diff each line against the legacy source. If the draft has iterated where the canonical line passes discipline, that's overreach — flag and recommend revert. If the draft has held where the canonical line fails discipline, that's under-arbitration — flag and recommend iteration.
   - **States 7 and 8 (new lines):** confirm one short sentence (or two short clauses); one specific operational detail; no editorial on Halina's manner / case (state 7) or on Murrow's mood / research content (state 8); warm-while-sorting register; Beat-8 client meeting and Beat-9 archive content not pre-empted.

5. **Cross-cutting register check (read all 12 lines aloud as a sequence).** Do they read as one Asia voice? Any line that breaks the sequence's tonal coherence? Any line sharper than the surrounding ones? Any line that drops below warm-while-sorting into flat-functional?

6. **Repeatability test.** Each line will play multiple times if the player lingers. Does each line bear at least three reads without grating? Flag any line that wears out fast.

7. **Hint-direction clarity.** Does each line actually point the player toward the next quest gate? Is the hint clear enough to reduce player confusion (the canonical purpose per `chapter_1.md` Asia hint-state logic)? Flag any line that hints in the wrong direction or buries the gate behind too much characterisation.

## Output format

Save your critique as `narrative_revision/phase_7_drafts/V1_A_draft_pass2_critique.md`. Header:

```
# V1.A §J Hostile Critique — Pass 1

**Draft critiqued:** `narrative_revision/phase_7_drafts/V1_A_draft_pass1.md`
**Pack:** `narrative_revision/phase_7_packs/V1.A_asia_hint_states.md`
**Status:** Raw hostile-critique output only. No arbitration or revision applied here.
```

For each failure mode you identify, output:

```
> **Failure:** [line quoted exactly, with state number]
> **Mode:** [which discipline it violates — be specific to §A or §B.1 sub-rule]
> **Fix:** [specific revision]
```

For boundary cases:

```
> **Marginal:** [line quoted with state number]
> **Concern:** [why it might be a problem]
> **Suggestion:** [optional revision; or "leave as is — defensible" with reasoning]
```

End with a summary section:

```
## Summary

Critical failures: **N**
Marginal lines: **N**
Overall recommendation: **commit / revise / redraft**
```

## Calibration notes

- **Be hostile, not destructive.** The pack §B.1 explicitly recommends verbatim hold for the 10 legacy lines because they pass every discipline. If you propose iteration on a verbatim-held legacy line, your bar is high: the line must specifically violate §A or §B.1 in a way the pack hasn't already adjudicated. *"This could be sharper"* is not a valid critique against Asia's no-sharpening discipline; *"This is sharper than V1.7 Beat 13 baseline by [specific measure]"* is.
- **Pressure-test the pack's pre-existing arbitrations.** Pack §B.1 explicitly approves state 1's *"loudest crisis in the room"* and state 11's *"expensive and irresponsible"* against their respective borderline-editorial concerns. If you disagree with these arbitrations, name the disagreement and the reasoning; don't silently re-flag.
- **Pass-1 self-check already lists 4 open questions.** Treat those as the user's pre-flagged uncertainties; address each in your critique with a clear marginal/critical verdict and reasoning.
- **The two new lines (states 7 and 8) are the highest-risk slots in the draft.** Apply more scrutiny here — these have no canonical legacy to fall back on; they're authored against §B.1 recommended sample shapes only.
- **Cross-pack baseline.** The 12 V1.A lines must read as register-baseline-consistent with V1.7 pass-5 Asia commits and V1.1 Asia baseline. If a line drifts from that baseline (sharper, warmer, more editorial), flag it.

## What you are NOT doing

- Not authoring replacement lines (only proposing them in the Fix field).
- Not committing anything to JSONL or dialogue files.
- Not updating the manifest.
- Not running `voice_audit.py`.
- Not arbitrating between competing fixes — produce the critique; the user arbitrates.

Output: a single Markdown file at `narrative_revision/phase_7_drafts/V1_A_draft_pass2_critique.md`. Approximate length: 100–250 lines depending on how many flags you identify. If the draft is clean, that's a valid output — short critique with low flag count and a *commit* recommendation.
