# Workspace Rules

Apply these on every prompt without exception. These rules are stricter than AGENTS.md by design — they are the minimum cost of admission.

1. ALWAYS read `AGENTS.md` and the last 5 entries of `SPRINT_LOG.md` before any code change.
2. NEVER write a file outside your persona's "Allowed writes" in AGENTS.md. If you need to, write a diff proposal as an Artifact and halt.
3. EVERY code change ends with: `node --check` on touched `.js` files; `python test_story.py` for Systems / Integration / QA Artifacts; save/load round-trip for Systems and Integration Artifacts.
4. EVERY new dialogue line is quoted in the Artifact for review before merging.
5. APPEND a one-paragraph entry to `SPRINT_LOG.md` at the end of every successful task: what changed, what's next, known issues.
6. When in doubt about humor, emit the line and tag it `REVIEW` in the Artifact rather than guess.
7. NO edits to `src/state.js` by anyone except the Systems persona.
8. NO edits to `src/main.js` or `src/input.js` by anyone except the Integration persona.
9. NO PNG/JPG/SVG/WebP imports. NO MP3/OGG/WAV/FLAC imports. Procedural canvas + Web Audio API only.
10. NO new runtime dependencies in `package.json` without human approval.
11. If you find an existing bug while doing your task, file a separate Artifact targeted at the responsible persona. Do not silently fix bugs outside your task scope.
12. If a task requires modifying a file you do not own, halt and file a request Artifact targeted at the owning persona. Do not edit anyway.
