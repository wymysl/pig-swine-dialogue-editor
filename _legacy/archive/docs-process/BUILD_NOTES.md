# Build Notes — Pig & Swine RPG

Maintained by the QA Agent. Append-only verification log.

Format per entry:

```
### [DATE] — Sprint N — [Task or "Sprint QA pass"]

Files touched this pass: <list>

Test results:
- node --check: PASS / FAIL <details>
- python test_story.py: PASS / FAIL <details>
- Browser subagent run: PASS / FAIL <link to video Artifact>

Bugs found:
- [P0|P1|P2] <short description> → filed as Artifact targeting <persona>

Bugs fixed:
- [P0|P1|P2] <short description> → fixed by <persona> in <Artifact ref>

Notes: <anything else the next QA pass should know>
```

---

### 2026-05-03 — Sprint 0 — Test Harness Expansion

Files touched this pass: 
- `test_story.py`
- `artifacts/qa/sprint-0-plan.md`

Test results:
- node --check: PASS (no JS modified)
- python test_story.py: FAIL (AssertionError: missing chapter1 flag: started - expected as Sprint 0 wiring is pending)
- Browser subagent run: Not run (test plan created for execution after Sprint 0 wiring)

Bugs found:
- None (pre-sprint test harness update)

Bugs fixed:
- None

Notes: Sprint 0 verification harness is ready. Wait for Systems and Integration to implement the required flags and features before running the full QA pass.

---

### 2026-05-03 — Sprint 0 — Sprint QA pass

Files touched this pass:
- All modified `.js` files

Test results:
- node --check: PASS (No JS errors in src/**/*.js)
- python test_story.py: PASS (29 story checks passed)
- Browser subagent run: FAIL (Could not launch dev server due to EPERM)

Bugs found:
- [P0] Cannot launch Vite dev server due to sandbox network constraints (EPERM) → filed as Artifact targeting Integration Agent (`artifacts/qa/bug_integration_dev_server.md`)

Bugs fixed:
- None

Notes: The static analysis and python test harnesses passed flawlessly. However, the runtime tests are completely blocked by the P0 bug preventing the dev server from binding to a port. Escalate the network constraint issue.
