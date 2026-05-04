extends Node
## State autoload — single writer. Owns all persistent game state and save/load.
## Migration required for every shape change (see AGENTS.md §Save migration policy).

const SAVE_VERSION: int = 1

## reset_state — returns the canonical empty-state Dictionary.
## Every key must have an explicit default; never rely on null.
func reset_state() -> Dictionary:
	return {}
