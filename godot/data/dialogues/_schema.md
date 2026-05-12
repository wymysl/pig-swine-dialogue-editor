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
      "lines": [
        "First line of dialogue (plain string — NPC who owns this tree speaks).",
        "Second line of dialogue (advances on interact press)."
      ],
      "on_dismiss": [
        { "set": "chapter1.pig_revealed_crisis", "value": true }
      ],
      "tags": ["progress", "tutorial"]
    }
  ],
  "idle_flavor": [
    { "line": "...", "tags": ["flavor"] }
  ]
}
```

## Multi-speaker lines (option 1)

Individual entries inside a `lines` array can declare a different speaker using an object form:

```json
{
  "id": "example_multi_speaker",
  "trigger": "chapter1.met_pig == false",
  "lines": [
    "NPC who owns the tree speaks (plain string).",
    { "speaker": "cula", "text": "Dr. A. Cula responds." },
    "NPC speaks again (plain string).",
    { "speaker": "asia", "text": "Asia chimes in." }
  ]
}
```

The same `lines` array may mix strings and objects in any order. The runner fires them sequentially; the dialogue box switches the displayed speaker name for each entry.

**Speaker resolution:**
- Plain string → owning NPC's display name (the `display_name` arg from the NPC node's `dialogue_requested` signal).
- Object `{ "speaker": "<character_id>", "text": "..." }` → display name looked up in `res://data/character_registry.json`.
- If a `character_id` is not in the registry, a warning is pushed and the owning NPC's name is used as fallback.

**Backward compatibility guarantee:** All existing string-only `lines` arrays continue to work identically. No existing dialogue tree file needs to change.

**Character ids in use:** `cula`, `pig`, `murrow`, `asia`, `crab`, `whimsy`, `barista`, `swine`. See `godot/data/character_registry.json` for the full display-name mapping.

## Rules

- `npc_id` matches the file name (without `.json`).
- `id` strings within `states` are unique per NPC and map to quest-state keys in `data/chapters/chapter*.json`.
- `trigger` is a boolean expression over `state.gd` fields. Code's dialogue_runner evaluates it.
- `lines` can be a single string for simple dialogue, an array of strings for paginated dialogue, or a mixed array of strings and speaker-override objects (see Multi-speaker lines above).
- `on_dismiss` is an optional array of mutation objects (`{ "set": "path.to.flag", "value": true }`) that update State.data when the dialogue finishes playing.
- Every committed line must pass the Taste Standard (see `godot/AGENTS.md` §The Taste Standard) and the Address forms in dialogue (§Address forms in dialogue).
- See `data/asia_hints.json` for a fully-authored example.

## Files

- `asia_hints.json` lives at `data/asia_hints.json` (one level up) for legacy reasons; treat it as if it were `data/dialogues/asia.json`. Future refactor: move it into this directory.
- All other NPCs author here: `pig.json`, `murrow.json`, `crab.json`, `whimsy.json`, `swine.json`, plus chapter-specific NPCs as they're introduced.
- `character_registry.json` lives at `data/character_registry.json` (one level up). Maintained by Code role. Add new character ids here when introducing new NPC dialogue trees.
