// === Typewriter System ===
// Character-by-character text reveal for dialogue, Ace Attorney style.
import { playTypingSound } from './audio.js';

let typewriterState = null;

export function startTypewriter(fullText, speed = 2) {
  typewriterState = {
    fullText,
    revealed: 0,
    speed,       // frames per character
    timer: 0,
    done: false,
  };
}

export function updateTypewriter() {
  if (!typewriterState || typewriterState.done) return;
  typewriterState.timer++;
  if (typewriterState.timer >= typewriterState.speed) {
    typewriterState.timer = 0;
    typewriterState.revealed++;
    if (typewriterState.revealed >= typewriterState.fullText.length) {
      typewriterState.done = true;
    } else {
      const ch = typewriterState.fullText.charCodeAt(typewriterState.revealed);
      if (typewriterState.fullText[typewriterState.revealed] !== ' ') {
        playTypingSound(ch);
      }
    }
  }
}

export function skipTypewriter() {
  if (typewriterState && !typewriterState.done) {
    typewriterState.revealed = typewriterState.fullText.length;
    typewriterState.done = true;
    return true; // consumed the input
  }
  return false;
}

export function getRevealedText() {
  if (!typewriterState) return '';
  return typewriterState.fullText.slice(0, typewriterState.revealed);
}

export function isTypewriterDone() {
  return !typewriterState || typewriterState.done;
}

export function clearTypewriter() {
  typewriterState = null;
}

export function isTypewriterActive() {
  return !!typewriterState;
}
