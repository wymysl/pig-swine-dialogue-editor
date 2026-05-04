# Managing the Agents — Piotr's Playbook

Your job is not to write code. Your job is: pick the next problem, brief the agent, review the artifact, run the build once, accept or kick back. Three roles, in that order of frequency.

## Daily flow

1. **Open Antigravity** with `godot/` as the workspace. Cascade picks up `AGENTS.md` and the four skill files automatically.
2. **Check `CURATION_BOARD.md`** in `godot/`. The "Next Best Task" line is your prompt source. (The legacy curation board under `_legacy/design/` is frozen; do not edit it and do not point agents at it.)
3. **Brief the agent** using the template below. One task per session.
4. **Wait** while Cascade reads, plans, executes. Skim the plan when it shows up; reject early if the plan is wrong rather than wait for a wrong artifact.
5. **Review the artifact** when it lands. Two questions only: did it stay in its lane (allowed-writes), and does it pass the role's acceptance gate? If yes, `git diff | wc -l` < 400, accept and merge. If no, kick back with one line.
6. **Run the build once** locally: open the web export, play the changed area for two minutes. Watch the console.
7. **Update `CURATION_BOARD.md`** with the new "Next Best Task". Never leave it empty — that's the prompt for the next session.

A good day: 1–3 agent runs, 1 manual playtest, 5–10 minutes of typing on your part.

A bad day: trying to direct the agent line by line. If you find yourself writing pseudocode in the prompt, the task is too big — split it.

## Briefing template

Paste this into Cascade. Fill the three brackets:

> Read `AGENTS.md` and the last five entries of `SPRINT_LOG.md`. Adopt the **[role]** skill (`.antigravity/skills/[role].md`). Task: [one-sentence task description]. Spec: [pointer to the relevant section of `../story.txt` (and `../style_canon.txt` / `../dialogue_samples.txt` for voice; `../world.txt`, `../battle_mechanics.txt`, or `../minigames.txt` as relevant)]. Acceptance: stay strictly within the role's allowed-writes; pass the role's acceptance gate; output the artifact format specified in the skill file. If the task requires touching files outside this role's allowed-writes, halt and file a request artifact for the responsible role.

Three real examples:

> Read AGENTS.md and the last five entries of SPRINT_LOG.md. Adopt the **Code** skill. Task: implement the room-transition system with 500ms fade-to-black. Spec: `../story.txt` Chapter 1 Beat 1 (entering Pig & Swine). Acceptance: stay strictly within Code's allowed-writes; pass Code's acceptance gate; save-load round-trip preserves the current room and player position; GUT test in `tests/test_room_transition.gd`. Halt if dialogue text or art is missing rather than stub it.

> Read AGENTS.md and the last five entries of SPRINT_LOG.md. Adopt the **Design** skill. Task: write four dialogue states (before / during / ready / after) for Mr. Pig in Chapter 1. Spec: the Mr. Pig sections of `../story.txt`. Acceptance: stay strictly within Design's allowed-writes; every line passes the Taste Standard 5/5; three expression variants on the main lines; quote every new line in the artifact for review. Use the canonical name "Mr. Pig" — never "Pig" alone in narration.

> Read AGENTS.md and the last five entries of SPRINT_LOG.md. Adopt the **QA** skill. Task: run a full Chapter 1 happy-path browser playtest against the current web export. Spec: Chapter 1 acceptance criteria in `../story.txt`. Acceptance: scripted walkthrough using canonical cast names (Dr. A. Cula, Mr. Pig, Murrow, Crab, Whimsy, Asia), console capture, save-load round-trip, BUILD_NOTES entry. File one bug artifact per issue found.

## What to reject

Reject the artifact, kick back with one line, regardless of correctness, if any of these are true:

- It edited files outside the role's allowed-writes table in `AGENTS.md`.
- The diff is >400 lines for a single role's task. (Exception: initial scaffolding sprints, where Code may justifiably write a lot — but the artifact must say so up front.)
- It modified content owned by another role to "make it work" instead of filing a request artifact.
- A new dialogue line fails the Taste Standard.
- It added a runtime dependency (Godot addon, etc.) not approved by you.
- It built content for a chapter listed in `PLAN.md` §Out of scope.
- The web export does not build cleanly.
- Save migration is missing or untested.

Sample kick-back lines (use literally):

> "Out of scope per PLAN.md §Out of scope. Stop here; nothing to merge."

> "Touched dialogues.json — that's Design's. File a Design request and stop."

> "Diff is 800 lines and crosses three roles. Split into three artifacts and resubmit."

> "Line X fails Taste Standard test 2 (Clever — no real referent). Rewrite."

## Parallelism

Antigravity supports multiple subagents in worktrees. Use it, but only for safe pairs:

- **Safe**: Design + Art (text vs binary). Design + Code on systems that don't reference new dialogue. QA + anything (QA is read-only for game code).
- **Unsafe**: Two Code agents at once. Art + Code both editing scenes. Design + Design on the same NPC.
- **Banned**: Anything + Anything if both touch `state.gd`, `Main.tscn`, or the same chapter JSON.

Heuristic: if the safe pairs each finish in 30 minutes, run them in parallel. If one is 2 hours and the other 30 minutes, run them sequentially — the 30-minute one will sit in queue waiting for review and you'll lose the parallelism benefit anyway.

## When to use Cowork vs Antigravity

- **Antigravity**: writing code, modifying scenes, running headless tests, browser-verifying web exports, anything where the IDE context (file tree, git diff, run/debug) matters.
- **Cowork**: writing dialogue passes for one NPC at a time, drafting design-bible extensions, reviewing playtest video and rewriting `CURATION_BOARD.md`, post-mortems where you want a fresh context window unrelated to the codebase.
- **Codex**: optional second-opinion review on save-migration PRs and any state-shape change. Not part of the daily flow.

## When to playtest yourself

Once a week, minimum. Set 15 minutes on a timer. Play whatever the latest web export does. Write three honest sentences in `BUILD_NOTES.md` under "Human Playtest". Agents will optimize for measurable acceptance criteria; only you can tell if it is funny.

If you ever find yourself thinking "the agents are making progress but the game is getting worse" — stop the next sprint immediately, do a 30-minute playtest, rewrite `CURATION_BOARD.md` from what you observed, then resume.

## Failure modes to watch for

- **Agent silently expands scope**. Check the diff range before reading the diff.
- **Agent invents Polish legal doctrine**. Grep new dialogue for KPC/KPK/KPA articles and verify they exist.
- **Agent stubs out missing content** instead of halting. The skill files forbid this; if it happens, kick back hard.
- **Agent passes its own tests but breaks an unrelated chapter**. QA pass should catch this, but if you skip QA for speed, you'll find out in playtest.
- **Drift in the curation board**. Every two weeks, re-read `../design/CURATION_BOARD.md` and ask: does the "Next Best Task" still match what would make the game funnier / cleverer / more alive?

## What success looks like

A new player can sit down with the web export, understand what to do without you explaining, and complete Chapter 1 in 20–30 minutes. They laugh at least three times. They make at least one meaningful legal choice. The console is clean. The save round-trips on reload.

When that's true, stop. Playtest with two real humans. Then start Chapter 2.
