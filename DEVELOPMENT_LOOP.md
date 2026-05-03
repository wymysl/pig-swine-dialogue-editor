# Pig & Swine Continuous Development Loop

**Goal:** continuously improve *Dr. A. Kula and the Pig & Swine Crisis* through small playable increments, with every loop ending in a verified build that can be playtested.

## North Star

Make a funny, charming, retro legal RPG where the player feels clever by solving absurd but coherent quests about Warsaw courts, Polish law, human rights, office politics, and the financial survival of Pig & Swine.

## Loop Overview

Each development cycle should be short and produce a playable improvement:

```text
PLAYTEST → PICK ONE PROBLEM → SPEC → TDD IMPLEMENT → REVIEW → BROWSER VERIFY → PLAYTEST NOTES → NEXT LOOP
```

Target loop duration:

- **Micro loop:** 30–90 minutes for one small feature or fix.
- **Daily loop:** 1 playable build with 2–5 small improvements.
- **Weekly loop:** 1 vertical-slice milestone with a new case, system, location, or polished sequence.

---

## The Core Rule

Do not build “more game” in the abstract.

Every loop must answer one of these:

1. Does this make the game funnier?
2. Does this make the player feel cleverer?
3. Does this make the world more alive?
4. Does this make the game easier to understand or play?
5. Does this make future development faster?

If the answer is no, skip it.

---

## Loop Step 1: Playtest the Current Build

Start every cycle by playing the game for 3–10 minutes.

Check:

- What is confusing?
- What is boring?
- What is funny and should be expanded?
- Where does the player lack agency?
- Where does the game fail to reward an action?
- Where does the story not match the mechanics?

For the current prototype, likely observations are:

- Movement works, but is stiff.
- Dialogue exists, but lacks portraits and choice.
- Quests are clear, but too linear.
- Characters exist, but need stronger personalities.
- Legal theme exists, but needs case-solving mechanics.

Output of this step:

```markdown
## Playtest Notes
- Problem: [specific issue]
- Evidence: [what happened during play]
- Desired improvement: [player-facing result]
```

---

## Loop Step 2: Pick Exactly One Problem

Choose one small improvement per loop.

Good examples:

- “Add an interaction marker above nearby NPCs.”
- “Give Mr. Pig a proper intro cutscene.”
- “Add a quest log panel.”
- “Add one legal-choice puzzle for the Polish law binder.”
- “Add dialogue choices when speaking to Rak and Wymysl.”

Bad examples:

- “Make the game good.”
- “Add all locations.”
- “Improve the story.”
- “Add legal mechanics.”

Each task should be small enough to finish and verify in one session.

---

## Loop Step 3: Write a Tiny Spec

Before coding, write a tiny spec in `docs/current-task.md` or directly in the issue/task note.

Template:

```markdown
# Current Task: [Feature Name]

**Player-facing goal:**
[What the player experiences]

**Implementation goal:**
[What code/data changes are needed]

**Acceptance criteria:**
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

**Manual verification:**
1. Open `index.html` in browser.
2. Do [specific steps].
3. Confirm [specific result].

**Automated checks:**
- [ ] Existing story checks pass.
- [ ] JS syntax check passes.
- [ ] Add/update lightweight test if feature has explicit data/story requirements.
```

Example:

```markdown
# Current Task: Interaction Marker

**Player-facing goal:**
When Dr. A. Kula stands next to an NPC or item, a small `!` or label appears so the player knows Space will do something.

**Acceptance criteria:**
- [ ] NPCs adjacent to player show `!`.
- [ ] Items adjacent to player show sparkle or label.
- [ ] No marker appears when nothing is interactable.
- [ ] Space still opens dialogue or picks up item.
```

---

## Loop Step 4: Test First

Use lightweight tests appropriate for this browser prototype.

Current command:

```bash
cd /opt/data/pig-swine-rpg
python3 test_story.py
python3 - <<'PY'
from pathlib import Path
html=Path('index.html').read_text()
Path('/tmp/pig_swine_game.js').write_text(html.split('<script>',1)[1].split('</script>',1)[0])
PY
node --check /tmp/pig_swine_game.js
```

For story/data features, add tests to `test_story.py` first.

Examples:

- New character must be present in HTML.
- New quest flag must exist.
- New story phrase must exist.
- New item id must exist.
- New location label must exist.

For larger refactors, introduce proper JS unit tests later, but keep the first version simple.

---

## Loop Step 5: Implement the Smallest Playable Change

Implementation principle:

> Make the smallest change that creates a visible improvement in play.

Do not refactor the entire game unless the task is specifically architectural.

For the current codebase, the next high-value architecture step is:

```text
Split the single HTML file into separate JS modules/data sections only after 2–3 more gameplay loops expose repeated pain.
```

Until then, avoid overengineering.

---

## Loop Step 6: Review in Two Passes

### Pass A: Spec Compliance

Ask:

- Did the feature do exactly what the spec said?
- Are all acceptance criteria satisfied?
- Did anything extra sneak in?
- Did the story remain consistent with Dr. A. Kula, Mr. Pig, Mr. Swine, Rak, Wymysl, Muraś, Polish law, courts, and human rights?

### Pass B: Quality

Ask:

- Is the code simple?
- Are names clear?
- Is state manageable?
- Is this likely to break another quest?
- Is the player feedback clear?
- Is the joke actually readable in-game?

For larger tasks, dispatch fresh subagents:

1. implementation subagent
2. spec-review subagent
3. quality-review subagent

Only move on when both reviews pass.

---

## Loop Step 7: Browser Verification

Every loop must end with browser verification.

Checklist:

- [ ] Open `file:///opt/data/pig-swine-rpg/index.html`.
- [ ] Title screen renders.
- [ ] Press Space to start.
- [ ] HUD appears.
- [ ] Move with arrows/WASD.
- [ ] Interact with at least one NPC.
- [ ] Complete or trigger the changed feature.
- [ ] Check browser console for JS errors.
- [ ] Take screenshot if the visual result matters.

Never rely only on code inspection for a game.

---

## Loop Step 8: Record Playtest Notes

At the end of each loop, write a short note:

```markdown
## Build Note: YYYY-MM-DD HH:MM

Changed:
- [what changed]

Verified:
- [what was tested]

Observed:
- [what still feels weak]

Next best task:
- [one recommended next loop]
```

This prevents wandering and keeps development continuous.

---

# Recommended Development Backlog

## Phase 1 — Make the Prototype Understandable and Pleasant

Priority: very high.

1. Add interaction markers for NPCs/items.
2. Add a quest log overlay.
3. Add a simple inventory overlay.
4. Add proper intro dialogue with Mr. Pig.
5. Add short tutorial guidance from Muraś.
6. Add clear completion feedback for each quest.
7. Fix title text wrapping and UI readability issues.
8. Add basic save/load using `localStorage`.

Definition of done:

- A new player can understand what to do without explanation.
- Every interaction gives clear feedback.
- The first 5 minutes feel intentional.

## Phase 2 — Add the First Real Fun Mechanic

Priority: highest creative milestone.

Build the first case-solving mechanic.

Suggested first case:

**Case 1: The Missing Annex and the Human Rights Argument**

Player must:

1. Talk to Mr. Pig about the financial crisis.
2. Get guidance from Muraś.
3. Find Rak and Wymysl.
4. Collect a Polish law binder.
5. Collect a human rights memo.
6. Choose the correct legal argument at court.

Mechanic:

- Present 3 choices at court.
- One is legally sound.
- One is funny but wrong.
- One is desperate Pig & Swine nonsense.

Reward:

- Correct choice: reputation + firm funds.
- Wrong choice: stress + funny failure, but still recoverable.

Definition of done:

- Player makes at least one meaningful choice.
- Choice outcome affects state.
- The result is funny and legible.

## Phase 3 — Improve Game Feel

1. Smooth tile movement.
2. Walking animations.
3. Character facing direction.
4. Better collision feedback.
5. Sound effects.
6. Dialogue typing sound.
7. Quest-complete chime.

Definition of done:

- Moving and interacting feels satisfying rather than merely functional.

## Phase 4 — Expand the World

1. Split map into locations:
   - Pig & Swine office
   - Warsaw street/cafe
   - court building
2. Add transitions between locations.
3. Give each location a purpose.
4. Add location-specific NPCs.
5. Add location-specific music/ambience later.

Definition of done:

- The world feels like places, not one board with objects.

## Phase 5 — Architecture Refactor

Do this only when the single-file structure slows development.

Target structure:

```text
/opt/data/pig-swine-rpg
  index.html
  src/
    game.js
    state.js
    map.js
    player.js
    npcs.js
    items.js
    quests.js
    dialogue.js
    ui.js
    save.js
  data/
    quests.js
    dialogues.js
    maps.js
  tests/
    test_story.py
```

Definition of done:

- Game still loads from a simple local server.
- Story/data changes no longer require touching rendering code.
- Tests still pass.

---

# Suggested Immediate Next 5 Loops

## Loop 1: Interaction Markers

Why: highest usability gain.

Add visible markers for nearby interactable NPCs/items.

## Loop 2: Quest Log Overlay

Why: prevents player confusion.

Press `Q` to show current quest chain and completed steps.

## Loop 3: Mr. Pig Intro Sequence

Why: establishes story.

On new game start, force a short opening scene/dialogue with Mr. Pig explaining:

- financial crisis
- Mr. Swine skiing in Japan
- Dr. A. Kula’s mission
- need for Muraś, Rak, and Wymysl

## Loop 4: Court Choice Puzzle

Why: first real gameplay mechanic.

At court, require choosing one of three legal arguments.

## Loop 5: Inventory + Evidence Screen

Why: supports future case-solving.

Press `I` to show:

- Polish law binder
- human rights memo
- coffee/funds
- case notes

---

# Metrics to Track

Do not optimize for code volume. Optimize for playable quality.

Track after each build:

1. **Time to first meaningful interaction** — should be under 30 seconds.
2. **Player confusion count** — how often player asks “what now?”
3. **Meaningful choices per 10 minutes** — target at least 3.
4. **Jokes that land** — keep, expand, or cut based on playtest reaction.
5. **Quest dead ends** — must be zero.
6. **Console errors** — must be zero.
7. **Full completion path** — must always work.

---

# Definition of a Good Build

A build is good if:

- It starts.
- It explains itself.
- It has no console errors.
- One complete quest path works.
- The player gets at least one funny payoff.
- The player makes at least one meaningful decision.
- The next development task is obvious.

---

# Operating Mode for Hermes

For small tasks:

1. Update/add a small test.
2. Implement directly.
3. Run checks.
4. Browser verify.
5. Report result.

For larger tasks:

1. Write a task spec.
2. Dispatch implementer subagent with TDD instructions.
3. Dispatch spec reviewer.
4. Dispatch quality reviewer.
5. Fix until both pass.
6. Browser verify.
7. Report result.

This keeps progress continuous without letting the prototype collapse under accidental complexity.
