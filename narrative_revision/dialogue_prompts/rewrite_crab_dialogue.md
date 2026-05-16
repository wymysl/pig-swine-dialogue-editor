# Rewrite `crab.json` — agent prompt

You are a coding agent operating inside the Pig & Swine RPG repository. Your task: rewrite `godot/data/dialogues/crab.json` end-to-end, preserving all existing chapter-flow integration and adding player-choice branching at well-chosen beats. You have read/write file access scoped to the workspace. You will not edit any file other than `godot/data/dialogues/crab.json`.

---

## What "rewrite" means here

The current `crab.json` is functional but flat: most states are one or two lines, no player choices, the voice has been described as blunt. You will replace the dialogue *content* with new lines in the revised Crab voice and add a small number of meaningful branch points where the player chooses Cula's stance, follow-up question, or angle.

You are **not** changing the schema. You are **not** adding new state flags. You **are** rewriting line text, expanding states from linear to branching where it earns its keep, and adding `_comment` annotations to document new design choices.

If you find yourself wanting to introduce a new `chapter1.*` flag, **stop and report**. New flags require Code-role changes (`state.gd` defaults, `SAVE_VERSION` bump, save migration, migration test) which are outside this task's scope per `godot/AGENTS.md` §Save migration policy.

---

## Read first, in this order

1. **`narrative_revision/voice_agents/crab.md`** — Crab's voice agent. The gear-shift mechanic (clean professional analysis paired with a short colloquial sentence that names what just happened in plain language) is the central voice rule. Internalize this before drafting any line.
2. **`narrative_revision/voice_agents/cula.md`** — Cula's voice. The choice text the player picks is *spoken by Cula*; every choice must pass Cula's self-test, not just Crab's.
3. **`godot/data/dialogues/crab.json`** — the file you will rewrite. Read carefully for current state IDs, trigger expressions, and `on_dismiss` flag writes. You must preserve every existing flag write; you may add additional writes only when new content justifies them and only using flags that already exist.
4. **`godot/data/dialogues/halina.json`** — the gold-standard example of branching dialogue in this project. Study the schema: how `options` blocks work, how `chain: true` chains states, how `write_path` / `trust_path` / `trust_delta` interact, how tier-gated response states fire from a single choice. Mirror this schema exactly.
5. **`godot/AGENTS.md`** §Address forms in dialogue, §First-meeting introductions, §The Taste Standard, §Save migration policy. Hard rules. The address-form rule for Crab is non-negotiable: pre-recruitment he addresses Cula as "Dr. A. Cula"; post-recruitment (`chapter1.recruited_crab == true`) as "Cula" in private and "Dr. A. Cula" in formal contexts.
6. Skim **`godot/scripts/autoload/state.gd`** to confirm which `chapter1.*` flags exist. Do not introduce any flag not already present there.

---

## Schema rules (binding)

**Lines** are either:
- A bare string — spoken by the file's `npc_id` (here, `crab`).
- An object `{"speaker": "<id>", "text": "..."}` — spoken by the named character. Valid speaker ids currently in canon: `cula`, `crab`, `whimsy`, `murrow`, `pig`, `asia`, `halina`. Do not invent new speakers.

**States** are objects with:
- `id` — snake_case, unique within the file.
- `trigger` — boolean expression. Operators: `==`, `!=`, `&&`, `!`, `>=`, `<=`. Flags referenced as `chapter1.<flag_name>`.
- `lines` — array as above.
- `options` (optional) — branching block. Required fields: `write_path`, `choices`. Optional: `trust_path`, `chain`. Each choice has `text`, `value`, optionally `trust_delta` (only if `trust_path` is present on the parent options block).
- `on_dismiss` (optional) — array of `{"set": "<path>", "value": <value>}` writes executed when the state finishes.
- `_comment*` — free-form documentation. Use generously to record design intent, especially for new branch logic.

**Trigger order matters.** The dialogue runner picks the first state in JSON order whose trigger evaluates true. Order states most-specific to most-general. A general fallback state (e.g., the existing `after_engagement`) must remain last in its applicable chain.

**`chain: true` semantics.** When an `options` block has `chain: true`, selecting a choice writes the value to `write_path` (and applies `trust_delta` to `trust_path` if present), then immediately re-evaluates triggers and fires the next matching state. This is how `halina.json` produces its question-then-tiered-response flow. Use this pattern when a player choice should immediately produce a differentiated Crab response.

---

## Branching design principles

Target **3–5 branch points** across the file. Branches are not their own goal; they exist to do specific work.

**Use a branch when:**
- The player can plausibly choose Cula's stance (transactional / collegial / curious / pushed-back) and Crab can respond differently within the gear-shift register.
- A fact Crab delivers naturally invites two or three different follow-up questions, each yielding different color or detail.
- A "wrong" choice can produce a sharper Crab response without blocking progress (per `godot/AGENTS.md` §Failure is comic, not punitive — failure narrows outcomes; it does not block them).

**Do not use a branch when:**
- The state is purely procedural (a hint nudge, a coffee reaction, a flag-setting handoff). Those should stay linear.
- The branch options would all produce the same Crab response with cosmetic variation only.
- Adding the branch would require a new flag.

**Where branches are most likely to earn their keep in this file:**
- The recruitment scene (`before_binder` and the fused `first_meeting_with_binder`). Cula's opening could offer stance choices — for example: a blunt procedural pitch, a collegial-professional pitch, a direct-personal pitch. Crab responds within the gear-shift register, with the colloquial closer shifting register depending on the stance Cula brought.
- The first post-recruitment engagement (`after_binder_first_engagement`). Cula handing over the binder could chain to a small follow-up choice: ask Crab how he plans to verify service, ask about timing, ask what could go wrong. Each yields a different short Crab beat.
- Possibly one of the post-recruitment hint states (`hint_needs_archive` or the court-readiness hint), where Cula can take the hint, push for specifics, or propose a competing angle.

These are illustrative, not prescriptive. Use judgment. Ground every branch in what Cula would plausibly say at this point in the chapter and what Crab would plausibly answer.

**Wrong-but-not-blocking choice rule.** At least one branch in the file should expose a Cula choice that's wrong-shaped (e.g., a pitch that misreads Crab, a follow-up that asks the procedurally-pointless question). Crab's response should be in his sharper colloquial register without being mean — a dry correction that teaches the player how Crab thinks. The state must still allow the player to proceed; failure here is comic, not punitive.

---

## Voice discipline (binding)

**Crab.** The gear-shift register is the central rule. Most turns either: (a) start in clean technical legal register and close on one short colloquial sentence that names what the analysis just demonstrated, (b) open colloquial and land in a procedural fact, or (c) intrude one colloquial word into a single technical sentence. The colloquial register is plain-Polish-lawyer-in-English-translation: *garbage, mess, stitch-up, whole thing stinks, give me a break, paperwork from a parallel universe, that's not paperwork — that's a confession*. Forbidden in the colloquial register: internet voice (yikes, tbh, lowkey), American slang (bro, dude, that's wild), obscenity above the *bullshit / give me a break* bar. Crab stays technical in court and in front of clients; the colloquial mouth is for halls, doorways, witnesses he's putting at ease, and private firm conversations.

Crab's suspicion is **technical** — about forms, dates, addresses, drafting. Not about people's motives. Lines that mind-read the landlord, the witness, or any other character are out of register; rewrite as observations about what the documents actually say or don't say.

Crab does not reassure. The colloquial register is not warmth. He produces the next fact.

**Cula.** Choice text is spoken by Cula. Cula is observational, dry, precise; short sentences when stressed, longer on procedural ground; no modern internet voice; no cursing; no boasting about the doctorate; no casual "Doctor" self-reference; no quipping at Crab's expense. Pre-recruit, Cula addresses Crab by bare surname plus self-introduction (canonical opener: *"Crab. I'm Cula."*). Post-recruit, "Crab" without preamble.

**The Taste Standard.** Every line — Crab's, Cula's, every other speaker who appears — passes all five tests: Laugh, Clever, Alive, Clear, Future-proof. Four-of-five fails.

---

## Hard constraints

- **Do not edit any file other than `godot/data/dialogues/crab.json`.** If a change requires editing another file (a new flag in `state.gd`, a save migration in `save.gd`, a new `chapter*.json` step), STOP and write a short note describing what would need to change in which file. Do not make the change yourself; that crosses Code-role ownership per `godot/AGENTS.md`.
- **Do not introduce new flags.** Use only `chapter1.*` flags that already exist in `state.gd` or are written by other dialogue/chapter files.
- **Preserve every existing `on_dismiss` flag write.** Grep the current file's `on_dismiss` blocks. Each existing write must appear in the new file at a state whose trigger semantics match. You may add additional writes only with new content that justifies them.
- **Preserve trigger semantics.** A state that currently fires "before binder, before recruitment" must still fire then. You may refine triggers (e.g., add a specificity clause) but you cannot relax existing constraints in a way that lets the state fire when it previously couldn't, or tighten them in a way that prevents a previously-valid path.
- **Preserve every state ID** unless renaming improves clarity AND you have grep-confirmed the ID is not referenced elsewhere in the repo. If you rename, document in `_comment` and report the rename.
- **Honor address forms strictly** per the rules above and `godot/AGENTS.md` §Address forms in dialogue.
- **Honor first-meeting greeting** per `godot/AGENTS.md` §First-meeting introductions. The first conversation between Cula and Crab must contain a recognisable greeting before any task content. The canonical opener `"Crab. I'm Cula."` (or near-equivalent in the same shape) is mandatory at the introduction beat. Inventory hand-off cannot be the first word spoken.
- **No canon contradictions.** Halina's case facts are settled (renumbering 2015, lease 1962, notice dated 8 April received 28 April, current address number 12, prior address number 7, etc.). If Crab references them, get them right; if you're unsure of a detail, omit it rather than invent.
- **No introduced spoilers.** This file is Chapter 1; do not foreshadow material from later chapters that the player has not yet earned. The Plotek thread, the operating-account reserve glimpse, STUB founding, and Mr. Swine's return are all out of scope here.

---

## Output

A single rewritten file at `godot/data/dialogues/crab.json`. The file must:

- Be valid JSON. No trailing commas, no comments outside `_comment*` keys.
- Maintain the existing top-level fields: `version`, `npc_id`, `states`, `idle_flavor`. Do not bump `version` (you are using existing schema features only).
- Include a top-level `_provenance` field naming this prompt and the date, in the style of `halina.json`'s `_provenance` field.
- Include `_comment` annotations on every new or substantially modified state explaining the design intent — especially for branch logic, trust path use (if any), and gear-shift register choices that might look surprising on second read.

---

## Self-test before reporting done

Run every check. Fix every miss before submitting.

1. **JSON validity.** The file parses. (`python3 -c "import json; json.load(open('godot/data/dialogues/crab.json'))"` exits 0.)
2. **Flag inventory.** Every `chapter1.*` flag referenced in any trigger or `on_dismiss` exists in `state.gd` or is written by another dialogue/chapter file. No new flags introduced.
3. **Preserved writes.** Every `on_dismiss` write present in the original file is present in the new file at a state whose trigger fires under equivalent or stricter conditions.
4. **Trigger order.** States are ordered most-specific to most-general. The general fallback (`after_engagement` or its successor) is last in its chain.
5. **Branching schema.** Every state with `options` has a valid `choices` array. Every choice has `text` and `value`; if `trust_delta` is present, the parent options block has a `trust_path`.
6. **Address forms.** Pre-recruit: Crab → "Dr. A. Cula"; Cula → "Crab" with self-introduction. Post-recruit: Crab → "Cula" (private) or "Dr. A. Cula" (formal); Cula → "Crab".
7. **First-meeting greeting.** The introduction state(s) include a recognisable greeting before task content.
8. **Crab voice.** Every Crab line either lands in clean technical register OR exhibits the gear-shift OR is a justified short interjection (*"No."* / *"Yeah, no."* / *"Look —"*). Lines that are flatly technical without personality are the old-version trap; rewrite.
9. **Cula voice.** Every Cula line — including every choice text — passes `cula.md`'s self-test. Especially: no internet voice, no casual "Doctor" self-reference, no quips at Crab's expense, address-form correct.
10. **Taste Standard.** Every line passes all five tests.
11. **Branch count and quality.** 3–5 branch points across the file. At least one branch includes a wrong-but-not-blocking choice that exposes Crab's sharper colloquial register.
12. **No canon contradictions.** Halina case facts correct. No later-chapter spoilers.
13. **No off-file edits.** Confirm you have not modified any other file.

---

## Report

When done, return:

- Total states in the new file vs the old.
- Which states are new, which are substantially modified, which are preserved with only line-text rewrites, which are preserved verbatim.
- Where branch points were added and what each branch buys (one sentence each).
- Any new `on_dismiss` writes you added beyond preservation, with justification.
- Any state IDs you renamed (with grep confirmation that nothing else references the old name).
- Any constraint you bumped against and how you resolved it.
- Any flag you considered referencing but rejected because it doesn't exist (and what you did instead).
- The result of the JSON-validity check.

If at any point you found yourself needing to edit another file, stop, do not edit it, and report what you would have needed to change.
