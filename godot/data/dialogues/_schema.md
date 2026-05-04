# Dialogue file schema

One JSON file per NPC, named `<npc_id>.json`. The dialogue runner loads every `.json` file in this directory at boot.

## Schema

```json
{
  "version": 1,
  "npc_id": "pig",
  "display_name": "Mr. Pig",
  "states": [
    {
      "id": "before_meeting_pig",
      "trigger": "chapter1.pig_revealed_crisis == false",
      "lines": {
        "neutral":  "...",
        "agitated": "...",
        "deadpan":  "..."
      },
      "tags": ["progress", "tutorial"]
    }
  ],
  "idle_flavor": [
    { "line": "...", "tags": ["flavor"] }
  ]
}
```

## Rules

- `npc_id` matches the file name (without `.json`).
- `id` strings within `states` are unique per NPC and map to quest-state keys in `data/chapters/chapter*.json`.
- `trigger` is a boolean expression over `state.gd` fields. Code's dialogue_runner evaluates it.
- `lines` uses three expression variants where the runner supports them. Single-string `lines` are also acceptable for simple NPCs.
- Every committed line must pass the Taste Standard (see `godot/AGENTS.md` §The Taste Standard) and the Address forms in dialogue (§Address forms in dialogue).
- See `data/asia_hints.json` for a fully-authored example.

## Files

- `asia_hints.json` lives at `data/asia_hints.json` (one level up) for legacy reasons; treat it as if it were `data/dialogues/asia.json`. Future refactor: move it into this directory.
- All other NPCs author here: `pig.json`, `murrow.json`, `crab.json`, `whimsy.json`, `swine.json`, plus chapter-specific NPCs as they're introduced.
