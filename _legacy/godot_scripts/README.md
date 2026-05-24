# _legacy/godot_scripts/

Frozen GDScript files that were live in `godot/scripts/` until a migration
made them incompatible with the current architecture. Each is kept in case
the rejected pattern needs to be re-read for context. None of these are
loaded by the running project.

Do NOT move these files back into `godot/scripts/` without re-validating
against the architecture they conflict with.

## Contents

- **`wall_occluder.gd`** (relocated 2026-05-22, tech critique F10). Was
  `godot/scripts/actors/wall_occluder.gd`. Faded interior wall segments
  when the player walked behind them. Incompatible with the TileMapLayer
  wall topology introduced 2026-05-12; per `godot/CONVENTIONS.md`
  §"Architectural Conflicts": "`wall_occluder.gd` is incompatible with the
  TileMapLayer wall topology and is not used." Replaced by Y-sort + baked
  collision in `art/tilesets/office_tileset.tres`.
  `tests/test_office_wall_visibility.gd` enforces that no `WallOccluder`
  node exists in the live office scene.

- **`room_fog.gd`** (relocated 2026-05-22, tech critique F10). Was
  `godot/scripts/actors/room_fog.gd`. Darkened rooms the player was not
  currently in. Same TileMapLayer-migration retirement;
  `tests/test_office_wall_visibility.gd` also asserts no `RoomFog` node.
