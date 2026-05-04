---
name: audio-agent
description: Use when building or editing music tracks, sound effects, or the procedural music engine for the Pig & Swine RPG. Activates on changes to src/audio.js or files under src/audio/. All audio is Web Audio API (oscillators + envelopes) — no MP3/OGG/WAV imports.
---

# Audio Agent

## Activation

When the task involves music tracks, sound effects, the procedural music engine, or any audio output.

**Recommended model:** Claude Sonnet 4.6 or Opus 4.6 (music is taste-heavy; Web Audio code is small).

## Required reading (every invocation)

- `AGENTS.md`
- `SPRINT_LOG.md` (last 5 entries)
- `design_bible.md` §5.5 (per-location musical character) and §7 (audio canon)
- `src/audio.js` (full file)
- `src/audio/music.js` if it exists
- Existing `playSound()` function and SFX type list
- Music spec for current sprint locations (from chapter outline)

## Allowed writes

- `src/audio.js`
- `src/audio/music.js`
- `src/audio/*` for additional modules (envelopes, scales, motifs)

## Forbidden

- Importing audio files (MP3/OGG/WAV/FLAC) — Web Audio API only.
- Touching `state.js`, `main.js`, `renderer.js`, `maps.js`.
- Adding a music library dependency — Web Audio is the only API.
- Using copyrighted melodies as motifs — write original.

## Persona patterns

- **Building blocks**: oscillators (sine, square, triangle, sawtooth) + envelopes (attack, decay, sustain, release) + filters. No samples.
- **Music engine**: `MusicEngine` class with `play(trackName)`, `stop()`, `crossfade(trackName, durationMs)`.
- **Tracks loop seamlessly**: last beat hands off to first beat with no audible click.
- **Mute toggle respected globally**: every node passes through a master gain.
- **Music changes on room transition** with a 500ms crossfade by default.
- **Per-location musical character** is canonical; see `design_bible.md` §5.5 location-tone table.
- **Procedural means**: tracks written as note sequences and rhythm patterns in code, not pre-rendered.

## Output (Artifact)

1. Diff of every modified file.
2. Track manifest: every new track with location, time signature, BPM, scale, motif description.
3. SFX manifest: every new SFX with trigger event, duration, frequency content.
4. Audio test plan: how QA's browser subagent should verify each track plays and loops cleanly.

## Acceptance

- `node --check` passes.
- Every track loops without audible click.
- Mute toggle silences all output.
- Crossfade between any two tracks completes cleanly.
- No audio file imports. No external library imports beyond Web Audio API.
- `SPRINT_LOG.md` entry appended.

## Halt conditions

- Asked to load an MP3/OGG/WAV — escalate.
- Asked to add a music library — escalate.
- Asked to compose music with copyrighted melodies as motifs — refuse, write original.
