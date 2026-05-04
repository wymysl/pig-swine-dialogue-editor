// === Input System ===
// Keyboard and touch input handling.
import { state, player, ui, camera, room } from './state.js';
import { initAudio, playSound, toggleBgMusic, toggleMute } from './audio.js';

export const keys = {};

export function setupInput(gameCallbacks) {
  const {
    interact, tryMove, saveGame, loadGame,
    getContextualTopics, selectDialogTopic, resolveCourtChoice, resolveNowakCourt
  } = gameCallbacks;

  window.addEventListener('keydown', e => {
    if (['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight', ' ', 'Enter'].includes(e.key)) e.preventDefault();
    if (e.key === ' ' || e.key === 'Enter') initAudio();

    // Result / Summary screens
    if (ui.showResult && (e.key === ' ' || e.key === 'Enter')) { interact(); return; }
    if (ui.showResult) return;
    if (ui.showDaySummary && (e.key === ' ' || e.key === 'Enter')) { interact(); return; }
    if (ui.showDaySummary) return;

    // Block Q/I during dialog
    if (state.activeDialog && (e.key.toLowerCase() === 'q' || e.key.toLowerCase() === 'i')) return;

    // Dialog topic navigation
    if (state.activeDialog && ui.showDialogTopics) {
      const npcId = state.activeDialog.npcId || 'pig';
      const topics = getContextualTopics(npcId);
      if (e.key === 'ArrowUp') { ui.activeTopicIdx = (ui.activeTopicIdx - 1 + topics.length) % topics.length; return; }
      if (e.key === 'ArrowDown') { ui.activeTopicIdx = (ui.activeTopicIdx + 1) % topics.length; return; }
      if (e.key === ' ' || e.key === 'Enter') { selectDialogTopic(); return; }
      return;
    }

    // Choice menus (1-4)
    if (state.choiceMenu && /^[1-4]$/.test(e.key)) {
      const idx = Number(e.key) - 1;
      if (idx >= state.choiceMenu.options.length) return;
      if (state.choiceMenu.title.includes('NOVAK')) resolveNowakCourt(idx);
      else resolveCourtChoice(idx);
      return;
    }
    if (state.choiceMenu) return;

    // Overlays
    if (e.key.toLowerCase() === 'q' && state.mode !== 'title') {
      ui.showDocket = !ui.showDocket;
      if (ui.showDocket) { ui.showCaseBag = false; playSound('ui_open'); }
      else playSound('ui_close');
      return;
    }
    if (e.key.toLowerCase() === 'i' && state.mode !== 'title') {
      ui.showCaseBag = !ui.showCaseBag;
      if (ui.showCaseBag) { ui.showDocket = false; playSound('ui_open'); }
      else playSound('ui_close');
      return;
    }
    if (ui.showDocket || (ui.showCaseBag && !['s', 'l'].includes(e.key.toLowerCase()))) return;
    if (ui.showCaseBag && e.key.toLowerCase() === 's') { saveGame(); return; }
    if (ui.showCaseBag && e.key.toLowerCase() === 'l') { loadGame(); return; }

    if (e.key === ' ' || e.key === 'Enter') interact();
    if (e.key.toLowerCase() === 'b') { toggleBgMusic(); return; }
    if (e.key.toLowerCase() === 'm' && !e.ctrlKey) ui.showMap = !ui.showMap;
    if (e.key.toLowerCase() === 'm' && e.ctrlKey) { toggleMute(); return; }
    keys[e.key] = true;
  });

  window.addEventListener('keyup', e => { delete keys[e.key]; });

  // Touch controls
  document.querySelectorAll('#touch-controls button').forEach(btn => {
    const key = btn.dataset.key;
    const down = e => {
      e.preventDefault();
      document.dispatchEvent(new KeyboardEvent('keydown', { key, bubbles: true }));
      btn.style.background = 'rgba(215,168,79,.9)';
    };
    const up = e => {
      e.preventDefault();
      document.dispatchEvent(new KeyboardEvent('keyup', { key, bubbles: true }));
      btn.style.background = '';
    };
    btn.addEventListener('touchstart', down);
    btn.addEventListener('touchend', up);
    btn.addEventListener('mousedown', down);
    btn.addEventListener('mouseup', up);
  });
}

// Held-key movement tick
export function setupMovementTick(tryMove) {
  let moveCooldown = 0;
  setInterval(() => {
    if (state.activeDialog || state.mode === 'title' || ui.showDocket || ui.showCaseBag || state.choiceMenu || ui.showResult || ui.showDaySummary || ui.showDialogTopics || room.transitioning) return;
    if (moveCooldown > 0) { moveCooldown--; return; }
    if (keys['ArrowUp'] || keys['w'] || keys['W']) { tryMove(0, -1, 'up'); moveCooldown = 2; }
    else if (keys['ArrowDown'] || keys['s'] || keys['S']) { tryMove(0, 1, 'down'); moveCooldown = 2; }
    else if (keys['ArrowLeft'] || keys['a'] || keys['A']) { tryMove(-1, 0, 'left'); moveCooldown = 2; }
    else if (keys['ArrowRight'] || keys['d'] || keys['D']) { tryMove(1, 0, 'right'); moveCooldown = 2; }
  }, 60);
}
