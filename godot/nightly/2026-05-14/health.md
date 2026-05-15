# Nightly Health — 2026-05-14

## Step 0 — Reversibility Snapshot
SKIPPED — `.git/index.lock` exists and could not be removed (operation not permitted in sandbox). Another process likely holds the lock. No snapshot committed; no source files were modified.

## Test Results
Godot binary is not available in the sandbox PATH (`godot` / `godot4` not found). All headless test runs were skipped. Tests must be verified locally or in a CI environment with Godot installed.

| Test | Result | Note |
|------|--------|------|
| all 35 test_*.gd | SKIP | `godot` binary not found in sandbox PATH |

## Voice Audit
PASS — 40 files audited, 24,812 records scanned, 0 violations, 0 JSON errors, 0 duplicates.

## JSON Validity
PASS — all 29 `.json` files under `godot/data/` parsed without error.

Files checked: `dialogues/asia.json`, `dialogues/pig.json`, `dialogues/whimsy.json`, `dialogues/judge_district_ch1.json`, `dialogues/meeting_room_stance.json`, `dialogues/asia_hint_states_ch1.json`, `dialogues/murrow_v2.json`, `dialogues/halina.json`, `dialogues/cula.json`, `dialogues/dialogues.json`, `dialogues/pig_rewrite.json`, `dialogues/barista.json`, `dialogues/crab.json`, `dialogues/asia_rewrite.json`, `dialogues/postcard_swine_ch1.json`, `dialogues/asia_hint_states_ch1_rewrite.json`, `dialogues/murrow.json`, `argument_opponents.json`, `minigames/coffee_patterns.json`, `minigames/coffee_text.json`, `character_registry.json`, `judgments.json`, `chapters/chapter1.json`, `items.json`, `_drafts/nightly_design_pig_2026-05-14.json`, `_drafts/halina_with_trust_meter.json`, `court_rounds/ch1_round1_halina_examination.json`, `tag_taxonomy.json`, `doors.json`

## Print Statements (runtime only)
None — `rg 'print\('` over `godot/scripts/` returned no matches.

## Godot MCP
Connected — Godot 4.6.2.stable.official.71f334935 (11 scenes, 86 scripts, 560 assets)

## Action Required
1. **Tests not run** — `godot` binary unavailable in nightly sandbox. Recommend verifying CI has Godot 4.6.2 installed, or running `godot --headless --path godot --script tests/test_runner.gd --log-file /tmp/pig_runner.log` locally before next commit.
2. **Git index.lock present** — `.git/index.lock` blocked the reversibility snapshot. If no editor or git process is actively running, the lock is stale and should be removed manually: `rm pig-swine-rpg/.git/index.lock`.

Voice audit, JSON validity, and print-statement checks all clear.
