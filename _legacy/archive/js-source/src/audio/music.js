// === Procedural Music Engine ===
// Web Audio API only. No imported audio files.
// Tracks loop seamlessly. Master gain respects global mute toggle.

import { getAudioCtx, getMuted } from '../audio.js';

/** @type {Object<string, TrackDef>} Track definitions keyed by location name */
const TRACKS = {};

// ── Musical constants ──────────────────────────────────────────────

const NOTES = {
  C3: 130.81, D3: 146.83, Eb3: 155.56, E3: 164.81, F3: 174.61,
  G3: 196.00, Ab3: 207.65, A3: 220.00, Bb3: 233.08, B3: 246.94,
  C4: 261.63, D4: 293.66, Eb4: 311.13, E4: 329.63, F4: 349.23,
  G4: 392.00, Ab4: 415.30, A4: 440.00, Bb4: 466.16, B4: 493.88,
  C5: 523.25, D5: 587.33, Eb5: 622.25, E5: 659.25, F5: 698.46,
  G5: 783.99, A5: 880.00,
};

// ── Track definitions ──────────────────────────────────────────────

// Office: stressed, slightly wonky, off-meter (7/8 time, C minor, 132 BPM)
TRACKS.office = {
  bpm: 132,
  beatsPerMeasure: 7,
  scale: [NOTES.C4, NOTES.Eb4, NOTES.F4, NOTES.G4, NOTES.Bb4, NOTES.C5, NOTES.Eb5],
  bass: [NOTES.C3, NOTES.C3, NOTES.Eb3, NOTES.Eb3, NOTES.F3, NOTES.G3, NOTES.C3],
  melody: [
    { note: NOTES.C5,  dur: 1 },
    { note: NOTES.Eb5, dur: 0.5 },
    { note: NOTES.G4,  dur: 0.5 },
    { note: NOTES.F4,  dur: 1 },
    { note: NOTES.Eb4, dur: 0.75 },
    { note: NOTES.G4,  dur: 1.25 },
    { note: NOTES.Bb4, dur: 1 },
    { note: NOTES.C5,  dur: 0.5 },
    { note: NOTES.Eb4, dur: 0.5 },
    { note: NOTES.F4,  dur: 1 },
    { note: NOTES.G4,  dur: 0.75 },
    { note: NOTES.Eb4, dur: 0.75 },
    { note: NOTES.C4,  dur: 1.5 },
  ],
  melodyType: 'square',
  melodyVol: 0.06,
  bassType: 'triangle',
  bassVol: 0.08,
  padType: 'sawtooth',
  padVol: 0.03,
  padChord: [NOTES.C3, NOTES.Eb3, NOTES.G3],
};

// Court: stately, minor key, mock-serious (4/4 time, D minor, 88 BPM)
TRACKS.court = {
  bpm: 88,
  beatsPerMeasure: 4,
  scale: [NOTES.D4, NOTES.F4, NOTES.A4, NOTES.D5],
  bass: [NOTES.D3, NOTES.D3, NOTES.A3, NOTES.A3],
  melody: [
    { note: NOTES.D5,  dur: 2 },
    { note: NOTES.C5,  dur: 1 },
    { note: NOTES.A4,  dur: 1 },
    { note: NOTES.Bb4, dur: 2 },
    { note: NOTES.A4,  dur: 1 },
    { note: NOTES.G4,  dur: 1 },
    { note: NOTES.F4,  dur: 1.5 },
    { note: NOTES.E4,  dur: 0.5 },
    { note: NOTES.D4,  dur: 2 },
  ],
  melodyType: 'triangle',
  melodyVol: 0.07,
  bassType: 'sine',
  bassVol: 0.10,
  padType: 'triangle',
  padVol: 0.04,
  padChord: [NOTES.D3, NOTES.F3, NOTES.A3],
};

// Café: warm, jazz-inflected, unhurried (4/4 swing, F major7, 96 BPM)
TRACKS.cafe = {
  bpm: 96,
  beatsPerMeasure: 4,
  scale: [NOTES.F4, NOTES.A4, NOTES.C5, NOTES.E5],
  bass: [NOTES.F3, NOTES.A3, NOTES.C3, NOTES.E3],
  melody: [
    { note: NOTES.A4,  dur: 1.5 },
    { note: NOTES.C5,  dur: 0.5 },
    { note: NOTES.E5,  dur: 1 },
    { note: NOTES.D5,  dur: 1 },
    { note: NOTES.C5,  dur: 1.5 },
    { note: NOTES.A4,  dur: 0.5 },
    { note: NOTES.G4,  dur: 1 },
    { note: NOTES.F4,  dur: 1 },
    { note: NOTES.A4,  dur: 1 },
    { note: NOTES.C5,  dur: 2 },
    { note: 0,         dur: 1 },
  ],
  melodyType: 'sine',
  melodyVol: 0.07,
  bassType: 'triangle',
  bassVol: 0.07,
  padType: 'sine',
  padVol: 0.03,
  padChord: [NOTES.F3, NOTES.A3, NOTES.C4, NOTES.E4],
  swing: 0.15,
};

// Archive: sparse, ambient, simulated tape hiss (free time feel, A minor, 60 BPM)
TRACKS.archive = {
  bpm: 60,
  beatsPerMeasure: 4,
  scale: [NOTES.A3, NOTES.C4, NOTES.E4],
  bass: [NOTES.A3, NOTES.A3, NOTES.E3, NOTES.E3],
  melody: [
    { note: NOTES.A4,  dur: 3 },
    { note: 0,         dur: 1 },
    { note: NOTES.E4,  dur: 2 },
    { note: NOTES.C4,  dur: 2 },
    { note: 0,         dur: 2 },
    { note: NOTES.A4,  dur: 2 },
    { note: NOTES.G4,  dur: 2 },
    { note: 0,         dur: 2 },
  ],
  melodyType: 'sine',
  melodyVol: 0.04,
  bassType: 'sine',
  bassVol: 0.05,
  padType: 'sine',
  padVol: 0.02,
  padChord: [NOTES.A3, NOTES.C4, NOTES.E4],
  hiss: true,
};


// ── Playback helpers ───────────────────────────────────────────────

/**
 * Schedule one loop of a track into the given AudioContext, returning
 * an object with { sources, gainNode, duration } for cleanup.
 */
function scheduleLoop(ctx, track, masterGain, startTime) {
  const beatDur = 60 / track.bpm;
  const sources = [];

  // ── Pad (sustained chord) ──
  const padGain = ctx.createGain();
  padGain.connect(masterGain);
  const totalBeats = track.melody.reduce((s, n) => s + n.dur, 0);
  const loopDur = totalBeats * beatDur;

  for (const freq of track.padChord) {
    const osc = ctx.createOscillator();
    osc.type = track.padType;
    osc.frequency.setValueAtTime(freq, startTime);
    const g = ctx.createGain();
    g.gain.setValueAtTime(0, startTime);
    // Fade in over first beat, sustain, fade out over last beat
    g.gain.linearRampToValueAtTime(track.padVol, startTime + beatDur);
    g.gain.setValueAtTime(track.padVol, startTime + loopDur - beatDur);
    g.gain.linearRampToValueAtTime(0, startTime + loopDur);
    osc.connect(g);
    g.connect(masterGain);
    osc.start(startTime);
    osc.stop(startTime + loopDur);
    sources.push(osc);
  }

  // ── Bass line ──
  const bassBeats = track.beatsPerMeasure;
  const measures = Math.ceil(totalBeats / bassBeats);
  let bassTime = startTime;
  for (let m = 0; m < measures; m++) {
    for (let b = 0; b < track.bass.length && bassTime < startTime + loopDur; b++) {
      const freq = track.bass[b % track.bass.length];
      const osc = ctx.createOscillator();
      osc.type = track.bassType;
      osc.frequency.setValueAtTime(freq, bassTime);
      const g = ctx.createGain();
      g.gain.setValueAtTime(track.bassVol, bassTime);
      g.gain.exponentialRampToValueAtTime(0.001, bassTime + beatDur * 0.9);
      osc.connect(g);
      g.connect(masterGain);
      osc.start(bassTime);
      osc.stop(bassTime + beatDur);
      sources.push(osc);
      bassTime += beatDur;
    }
  }

  // ── Melody ──
  let melTime = startTime;
  for (const step of track.melody) {
    const dur = step.dur * beatDur;
    if (step.note > 0) {
      const osc = ctx.createOscillator();
      osc.type = track.melodyType;
      osc.frequency.setValueAtTime(step.note, melTime);
      const g = ctx.createGain();
      const attack = Math.min(0.05, dur * 0.1);
      const release = Math.min(0.1, dur * 0.3);
      g.gain.setValueAtTime(0, melTime);
      g.gain.linearRampToValueAtTime(track.melodyVol, melTime + attack);
      g.gain.setValueAtTime(track.melodyVol, melTime + dur - release);
      g.gain.linearRampToValueAtTime(0, melTime + dur);
      osc.connect(g);
      g.connect(masterGain);
      osc.start(melTime);
      osc.stop(melTime + dur + 0.01);
      sources.push(osc);
    }
    melTime += dur;
  }

  // ── Tape hiss (archive) ──
  if (track.hiss) {
    const bufSize = ctx.sampleRate * 2;
    const buf = ctx.createBuffer(1, bufSize, ctx.sampleRate);
    const data = buf.getChannelData(0);
    for (let i = 0; i < bufSize; i++) {
      data[i] = (Math.random() * 2 - 1) * 0.015;
    }
    const noise = ctx.createBufferSource();
    noise.buffer = buf;
    noise.loop = true;
    // Low-pass filter for tape-hiss character
    const filter = ctx.createBiquadFilter();
    filter.type = 'lowpass';
    filter.frequency.setValueAtTime(3000, startTime);
    const hissGain = ctx.createGain();
    hissGain.gain.setValueAtTime(0.6, startTime);
    noise.connect(filter);
    filter.connect(hissGain);
    hissGain.connect(masterGain);
    noise.start(startTime);
    noise.stop(startTime + loopDur);
    sources.push(noise);
  }

  return { sources, duration: loopDur };
}


// ── MusicEngine class ──────────────────────────────────────────────

/** Procedural music engine — plays location-specific tracks via Web Audio API */
export class MusicEngine {
  constructor() {
    /** @type {string|null} */
    this._currentTrack = null;
    /** @type {GainNode|null} */
    this._masterGain = null;
    /** @type {Array} scheduled oscillator sources */
    this._sources = [];
    /** @type {number|null} loop scheduling interval */
    this._loopTimer = null;
    /** @type {number} duration of current loop in seconds */
    this._loopDuration = 0;
    /** @type {boolean} true while a crossfade is in progress */
    this._fading = false;
  }

  /** Play a track by location name. If already playing, no-op. */
  play(trackName) {
    const ctx = getAudioCtx();
    if (!ctx) return;
    if (this._currentTrack === trackName) return;

    const track = TRACKS[trackName];
    if (!track) return;

    this._stopInternal();

    this._masterGain = ctx.createGain();
    this._masterGain.gain.setValueAtTime(getMuted() ? 0 : 1, ctx.currentTime);
    this._masterGain.connect(ctx.destination);
    this._currentTrack = trackName;

    this._scheduleAndLoop(ctx, track);
  }

  /** Stop all music immediately. */
  stop() {
    this._stopInternal();
    this._currentTrack = null;
  }

  /** Crossfade from current track to a new one over durationMs (default 500). */
  crossfade(trackName, durationMs = 500) {
    const ctx = getAudioCtx();
    if (!ctx) return;
    if (this._currentTrack === trackName) return;

    const track = TRACKS[trackName];
    if (!track) { this.stop(); return; }

    if (!this._currentTrack) { this.play(trackName); return; }

    const durSec = durationMs / 1000;
    const oldGain = this._masterGain;
    const oldSources = this._sources;
    const oldTimer = this._loopTimer;
    this._fading = true;

    // Fade out old
    if (oldGain) {
      oldGain.gain.setValueAtTime(oldGain.gain.value, ctx.currentTime);
      oldGain.gain.linearRampToValueAtTime(0, ctx.currentTime + durSec);
    }

    // Start new track
    this._masterGain = ctx.createGain();
    this._masterGain.gain.setValueAtTime(0, ctx.currentTime);
    this._masterGain.gain.linearRampToValueAtTime(getMuted() ? 0 : 1, ctx.currentTime + durSec);
    this._masterGain.connect(ctx.destination);
    this._currentTrack = trackName;
    this._sources = [];
    this._loopTimer = null;

    this._scheduleAndLoop(ctx, track);

    // Cleanup old after fade completes
    setTimeout(() => {
      if (oldTimer) clearInterval(oldTimer);
      for (const s of oldSources) {
        try { s.stop(); } catch (_) { /* already stopped */ }
      }
      if (oldGain) { try { oldGain.disconnect(); } catch (_) { /* ok */ } }
      this._fading = false;
    }, durationMs + 100);
  }

  /** Sync master gain with the global mute state. Call from game loop or mute toggle. */
  syncMute() {
    if (!this._masterGain) return;
    const ctx = getAudioCtx();
    if (!ctx) return;
    const target = getMuted() ? 0 : 1;
    this._masterGain.gain.setValueAtTime(target, ctx.currentTime);
  }

  /** @returns {string|null} Currently playing track name */
  get currentTrack() { return this._currentTrack; }

  // ── Private ────────────────────────────────────────────────────

  _stopInternal() {
    if (this._loopTimer) { clearInterval(this._loopTimer); this._loopTimer = null; }
    for (const s of this._sources) {
      try { s.stop(); } catch (_) { /* already stopped */ }
    }
    this._sources = [];
    if (this._masterGain) {
      try { this._masterGain.disconnect(); } catch (_) { /* ok */ }
      this._masterGain = null;
    }
    this._loopDuration = 0;
  }

  _scheduleAndLoop(ctx, track) {
    const result = scheduleLoop(ctx, track, this._masterGain, ctx.currentTime);
    this._sources = result.sources;
    this._loopDuration = result.duration;

    // Schedule next loop before current one ends, with overlap to avoid gaps
    const intervalMs = (this._loopDuration * 1000) - 200;
    this._loopTimer = setInterval(() => {
      if (getMuted()) return; // don't schedule while muted, will resume on unmute
      const newCtx = getAudioCtx();
      if (!newCtx || !this._masterGain) { this.stop(); return; }
      const res = scheduleLoop(newCtx, track, this._masterGain, newCtx.currentTime + 0.1);
      // Replace source list (old ones self-stop)
      this._sources = res.sources;
    }, Math.max(intervalMs, 500));
  }
}

/** @returns {string[]} List of available track names */
export function getTrackNames() {
  return Object.keys(TRACKS);
}
