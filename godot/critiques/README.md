# Critiques

Weekly hostile critique reports produced by scheduled subagents. Each
critic is an in-role expert with a narrow mandate and an adversarial
stance toward the current game state.

## Cadence

| Day | Role | Slug |
|---|---|---|
| Mon 09:00 | Narrative & dialogue | `narrative` |
| Tue 09:00 | Game / systems design | `design` |
| Wed 09:00 | Pixel art / visual direction | `art` |
| Thu 09:00 | UI / UX | `ui` |
| Fri 09:00 | Code & technical health | `tech` |

## File naming

`YYYY-MM-DD-{slug}.md` — date is the day the critic ran.

## Report format

Each report leads with a one-paragraph verdict, then numbered findings.
Each finding has: **Flaw**, **Why this fails**, **Remediation**, **Severity**
(S1 must-fix / S2 should-fix / S3 nice-to-fix).

Critics are instructed to be hostile toward the work but not toward the
developer. They prioritize problems over praise and propose concrete,
implementable fixes (file paths, code changes, tests to add).

## What to do with a report

Treat the report as a triage queue, not a directive. Promote S1 findings
you agree with into `godot/PROPOSALS.md` or `godot/PLAN.md`; archive or
dismiss the rest. The critic does not have authority to modify source
files — only this folder.

## Backlog hygiene

Older critiques can be moved into a year-quarter subfolder
(`2026-Q2/`, `2026-Q3/`) when the folder gets noisy. The critic prompts
do not depend on prior reports.
