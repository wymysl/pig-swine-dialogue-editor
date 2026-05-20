# Beat brief — Ch<N> Beat <N>: "<Topic>"

<!--
  USAGE
  -----
  Copy this file to beats/<chN>_beat<N>_<slug>.md and fill in every section.
  Run task 1.1 (beat brief sanity check) after filling; it reports only
  mismatches. Do not submit a brief with placeholder text still present.

  Sections 1-7 map directly to the 1.1 checker's seven assertions.
  Required fields are marked [REQUIRED]. Optional annotation fields are [OPT].
-->

---

## 1. Story-spec anchor

<!--
  [REQUIRED] Paste the verbatim paragraph(s) from story.txt that describe this
  beat. Section heading must match: "### Beat N — <Title>" exactly as it appears
  in story.txt. The checker compares your paste against story.txt; any divergence
  is a MISMATCH.
-->

**story.txt section heading (verbatim):**

> ### Beat N — …

**Quoted spec text (verbatim, copy-paste from story.txt):**

> …

---

## 2. Cast

<!--
  [REQUIRED] List every character who speaks or is named in the beat. Use
  canonical reference names exactly as given in AGENTS.md §Cast — canonical names.
  The checker flags any non-canonical name.

  Canonical roster for reference:
    Dr. A. Cula · Mr. Pig · Mr. Swine · Murrow · Crab · Whimsy · Asia
  Chapter NPCs (add per-chapter as introduced).
-->

| Character | Role in beat |
|-----------|-------------|
| Dr. A. Cula | protagonist |
| …         | …           |

---

## 3. Address forms

<!--
  [REQUIRED] For each pair of characters who address each other in this beat,
  state the expected address form and the rule that governs it.
  The checker cross-references AGENTS.md §Address forms in dialogue.

  Quick reference:
  - Cula addressed as "Dr. A. Cula" by everyone EXCEPT Crab/Whimsy post-recruit
    (who use bare "Cula").
  - Murrow addressed as "Murrow" by Crab/Whimsy; "Mr. Murrow" by Asia, Pig,
    Swine, and chapter NPCs; "Mr. Murrow" by Cula until the first-name invitation
    fires (after which "Murrow").
  - Cula addresses Murrow: per above.
-->

| Speaker → Addressee | Form used | Rule / beat context |
|--------------------|-----------|---------------------|
| … → Dr. A. Cula    | …         | …                   |
| … → Murrow         | …         | …                   |

---

## 4. Incoming flags

<!--
  [REQUIRED] Flags that must already be true (or have a specific value) for this
  beat's trigger conditions to be reachable. Every flag listed here must exist in
  state.gd reset_state(). The checker greps state.gd; a flag absent from that
  file is a MISMATCH.

  Format: `chapter1.<flag_name>` (bool/string/int) — what value is required and why.
-->

| Flag | Required value | Why |
|------|---------------|-----|
| `chapter1.…` | true | … |

---

## 5. Outgoing flags

<!--
  [REQUIRED] Flags this beat sets, clears, or modifies. Distinguish:
    (a) EXISTS — already declared in state.gd reset_state(); just list it.
    (b) NEW — not yet declared; requires a Code task before this beat is playable.
        For NEW flags, specify: type (bool/string/int), default value, owner system.

  The checker greps state.gd for (a) and flags (b) as requiring a Code artifact.
-->

| Flag | Type | Set to | EXISTS / NEW | Notes |
|------|------|--------|--------------|-------|
| `chapter1.…` | bool | true | EXISTS | set by on_dismiss |
| `chapter1.…` | string | "…" | NEW | Code task: declare in reset_state(), bump SAVE_VERSION, add migration |

---

## 6. Doctrinal anchor

<!--
  [REQUIRED] The real-ish KPC / KPK / KPA / institutional fact the beat's comedy
  or procedural content rests on. Per AGENTS.md §Humor rules: parody real
  procedure or halt; do not invent doctrine to make a joke work.

  Fabricated article numbers are permitted only with the -bis suffix convention
  (see story.txt §Article 135-bis) and must sit plausibly near real KPC neighbors.

  Format:
    Statute / institution: <e.g., KPC Art. 135-bis § 2 (fabricated)>
    Real neighbor: <e.g., KPC Art. 135 — delivery rules>
    How it's parodied: <one sentence>
    Checker note: REAL (citable in actual statute) / FABRICATED-BIS (meets
    project convention) / NEEDS VERIFICATION
-->

**Statute / institution:**
**Real neighbor:**
**How it's parodied:**
**Checker note:**

---

## 7. Length budget

<!--
  [REQUIRED] Target line counts and hard caps for this beat's dialogue states.
  The 1.1 checker fails any brief that omits this section entirely.

  Fill in realistic targets based on the beat's narrative weight. Breathing-room
  beats (character-dwell options) typically run 2-4 lines per branch; load-bearing
  plot beats run 4-8 lines per state; court-round states run up to 10.

  "Max NPC lines before Cula interjects" = longest unbroken NPC run before a
  player option or Cula line must appear.
-->

| State slug | Target lines | Hard cap | Max NPC run |
|-----------|-------------|---------|-------------|
| `…`       | …           | …       | …           |

**Beat-level cap:** [total spoken lines across all states in this beat]
**Dwell options:** [number of character-dwell branches, if any]
**Notes:** [any state that may exceed cap due to doctrinal narration, and why]

---

## 8. Authoring notes [OPT]

<!--
  [OPTIONAL] Anything the Design agent or human needs before drafting lines:
  voice-bible references, taste-standard edge cases, plants, recoloring
  commitments, phase-7 voice-pack cross-references, etc.
  The 1.1 checker does not validate this section.
-->
