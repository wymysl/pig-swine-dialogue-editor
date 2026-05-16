# Agent 1 Done — Battle Controller Restoration

- Commit: `603f65ebe0ceadf8fd37ac7dbc2eef5018a2162c` — `Restore battle_controller and wire Phase 1 / Phase 2 (v17)`.

Files written:

- `godot/scripts/systems/battle/battle_controller.gd` — 643 lines.
- `godot/scripts/systems/battle/argument_opponent.gd` — 165 lines.
- `godot/scripts/systems/battle/judgment.gd` — 70 lines.
- `godot/scripts/systems/battle/principle_move.gd` — 108 lines.
- `godot/scripts/autoload/signals.gd` — 122 lines; one signal added.
- `godot/tests/test_battle_controller.gd` — 240 lines.

Acceptance results:

- `godot --headless --path godot --script tests/test_smoke.gd --log-file /tmp/agent1_smoke.log` — EXIT 0.
- `godot --headless --path godot --script tests/test_runner.gd --log-file /tmp/agent1_runner.log` — EXIT 0.
- `godot --headless --path godot --script tests/test_battle_controller.gd --log-file /tmp/agent1_battle.log` — EXIT 0.
- `godot --headless --path godot --script tests/test_save_migration_v16_v17.gd --log-file /tmp/agent1_v17.log` — EXIT 0.
- `godot --headless --path godot --script tests/test_effectiveness.gd --log-file /tmp/agent1_eff.log` — EXIT 0.
- `godot --headless --path godot --export-release "Web" exports/web/index.html --log-file /tmp/agent1_export.log` — EXIT 0.

Signal inventory:

- `Signals.judge_skepticism_raised(round_index: int, proposed_frame: String)` — emitted when `proposed_frame == "merits_defence"` opens round 3 and initial `judicial_patience` is reduced to 3.

Seed adaptation notes:

- Preserved the c83feaa seed's two-phase court-controller direction and pure battle resource split.
- Reworked the seed away from authored court-round effectiveness buckets. `player_present()` and `player_press()` now call `Effectiveness.resolve(...)` live against weighted move/evidence tags and opponent weakness/strength tags.
- The restored resources hydrate the current `data/judgments.json` and `data/argument_opponents.json` schemas directly; no data schema changes or save-version bump were introduced.
- Phase 1 currently uses the public `player_press(witness_statement_id)` and `player_present(move, evidence_id)` primitives with `State.data.chapter1.witness_cooperation` as the resource. Evidence ids from `data/evidence_ch1.json` can establish the corresponding `sets_flag`.
- Phase 2 reads `State.data.chapter1.proposed_frame`, `judicial_patience`, and the frame entries in `data/argument_frames_ch1.json`. Frame `court_round_unlock` is treated as the earliest state rank at which the frame's supporting evidence can be cited.

Agent 2 / court-round data note:

- The controller does not require a new `data/court_rounds/*.json` runtime schema yet. For the current live loop, the expected runtime shape is still `data/argument_opponents.json` rounds plus `data/evidence_ch1.json` evidence ids and `data/argument_frames_ch1.json` frame gates. If Agent 2's authored `data/court_rounds/chapter1_round_1.json` should become runtime input, the next Code pass should add an explicit loader rather than relying on this controller to auto-discover it.

DESIGN_TODO / wrong-but-not-blocking:

- `data/evidence_ch1.json` and `data/argument_frames_ch1.json` still have several Design text fields intentionally blank from the v17 code pass. The controller avoids hardcoded player-facing fallback text, so UI-facing presentation still needs the Design fill.
- `tests/test_battle_controller.gd` deliberately triggers `push_error` once for the unknown-tag taxonomy rejection path, mirroring `tests/test_effectiveness.gd`.
