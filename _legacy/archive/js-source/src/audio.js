// === Audio System ===
// Web Audio API: sound effects, typewriter sounds, background music.

let audioCtx = null;
let bgMusicNode = null;
let isMuted = false;
const SOUND_VOL = 0.3;
const muteCallbacks = [];

export function initAudio() {
  if (!audioCtx) {
    audioCtx = new (window.AudioContext || window.webkitAudioContext)();
  }
}

export function getAudioCtx() { return audioCtx; }

function osc(freq, dur, vol = SOUND_VOL, type = 'square') {
  if (isMuted || !audioCtx) return;
  const o = audioCtx.createOscillator();
  const g = audioCtx.createGain();
  o.type = type;
  o.connect(g);
  g.connect(audioCtx.destination);
  g.gain.setValueAtTime(vol, audioCtx.currentTime);
  g.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + dur);
  o.frequency.setValueAtTime(freq, audioCtx.currentTime);
  o.start();
  o.stop(audioCtx.currentTime + dur);
}

export function playSound(type) {
  if (isMuted || !audioCtx) return;
  switch (type) {
    case 'docket':    osc(440, 0.1); break;
    case 'casebag':   osc(523.25, 0.1); break;
    case 'badge':
      // 3-note fanfare
      osc(523.25, 0.15, 0.25);
      setTimeout(() => osc(659.25, 0.15, 0.25), 120);
      setTimeout(() => osc(783.99, 0.3, 0.3), 240);
      break;
    case 'move':      osc(220, 0.04, 0.08); break;
    case 'pickup':
      osc(587.33, 0.08, 0.2);
      setTimeout(() => osc(783.99, 0.12, 0.25), 80);
      break;
    case 'success':
      osc(523.25, 0.1, 0.2);
      setTimeout(() => osc(659.25, 0.1, 0.2), 100);
      setTimeout(() => osc(783.99, 0.1, 0.2), 200);
      setTimeout(() => osc(1046.5, 0.3, 0.3), 300);
      break;
    case 'failure':
      osc(311.13, 0.15, 0.2, 'sawtooth');
      setTimeout(() => osc(233.08, 0.3, 0.2, 'sawtooth'), 150);
      break;
    case 'door':
      osc(349.23, 0.06, 0.15);
      setTimeout(() => osc(293.66, 0.1, 0.12), 60);
      break;
    case 'typing':    osc(800 + Math.random() * 400, 0.03, 0.06); break;
    case 'ui_open':   osc(659.25, 0.06, 0.15); osc(880, 0.08, 0.12); break;
    case 'ui_close':  osc(880, 0.04, 0.1); osc(659.25, 0.06, 0.08); break;
    case 'shake':     osc(80, 0.15, 0.2, 'sawtooth'); break;
  }
}

// Typewriter sound — varies pitch per character for personality
export function playTypingSound(charCode) {
  if (isMuted || !audioCtx) return;
  const baseFreq = 600 + (charCode % 20) * 30;
  osc(baseFreq, 0.025, 0.04);
}

export function toggleBgMusic() {
  if (!audioCtx) initAudio();
  if (bgMusicNode) {
    bgMusicNode.stop();
    bgMusicNode = null;
  } else {
    bgMusicNode = audioCtx.createOscillator();
    const gain = audioCtx.createGain();
    bgMusicNode.connect(gain);
    gain.connect(audioCtx.destination);
    bgMusicNode.frequency.setValueAtTime(220, audioCtx.currentTime);
    gain.gain.setValueAtTime(0.08, audioCtx.currentTime);
    bgMusicNode.start();
  }
}

export function toggleMute() {
  isMuted = !isMuted;
  for (const cb of muteCallbacks) cb(isMuted);
}
export function getMuted() { return isMuted; }

/** Register a callback to fire when mute state changes */
export function onMuteChange(cb) { muteCallbacks.push(cb); }

