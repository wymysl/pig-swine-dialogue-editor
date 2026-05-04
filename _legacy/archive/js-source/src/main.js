// === Main Game Module ===
// Game loop, interaction routing, bootstrap. Single entry point for Vite.
import { state, player, ui, camera, room, BADGES, resetState } from './state.js';
import { initRenderer, iso, applyShake, drawBackground, drawTile, drawLawyerSprite, drawTransition, getCtx, getW, getH } from './renderer.js';
import { initAudio, playSound } from './audio.js';
import { startTypewriter, skipTypewriter, isTypewriterDone } from './typewriter.js';
import { saveGame, loadGame, hasSave } from './systems/save.js';
import { setupInput, setupMovementTick, keys } from './input.js';
import { initTransitions, startTransition, updateTransition, isTransitioning, getActiveMap, getActiveDoors, getRoomEntry } from './systems/transitions.js';
import { MusicEngine } from './audio/music.js';
import { onMuteChange } from './audio.js';
import { overworldTiles, MAP_W, MAP_H, blocked, areaAt, manhattan, TILE_W, TILE_H } from './data/maps.js';
import { dialogTopics, getContextualTopics } from './data/dialogues.js';
import { createNpcs, createItems, createInteractables } from './data/npcs.js';
import {
  awardBadge, startCourtArgumentChoice, resolveCourtChoice, startNowakCourtChoice,
  resolveNowakCourt, takeItem, nextQuest
} from './systems/quests.js';
import { incidents, incidentEffects, checkForRandomIncident } from './systems/incidents.js';
import { startCoffeeMiniGame, drawCoffeeMiniGame, getCoffeeMiniGame, resolveCoffeeMiniGame, initCoffeeCallbacks } from './systems/coffee.js';
import {
  drawHUD, drawMiniMap, drawDocket, drawCaseBag, drawDialog, drawDialogTopics,
  drawChoiceMenu, drawResultScreen, drawDaySummary, drawFlashMessage, drawTitleScreen,
  drawInteractHint, getNearbyInteractable
} from './ui.js';

// --- Canvas setup ---
const canvas = document.getElementById('game');
initRenderer(canvas);
const ctx = getCtx();
const W = getW(), H = getH();
const ORIGIN_X = W / 2, ORIGIN_Y = 92;
const MOVE_SPEED = 0.12;

// --- Entity instances ---
const npcs = createNpcs({
  awardBadge: (id) => awardBadge(id, doSave),
  saveGame: doSave,
  flashDialog,
  startNowakCourtChoice
});
const items = createItems();
const interactables = createInteractables();

// --- Music engine ---
const music = new MusicEngine();
onMuteChange(() => music.syncMute());

// --- Transition system ---
initTransitions({
  playSound,
  onRoomLoaded: (roomId) => {
    music.crossfade(roomId);
  }
});

// --- Local UI state ---
let resultData = null;

// --- Save/Load wrappers ---
function doSave() {
  const itemsTaken = items.filter(i => i.taken).map(i => i.id);
  saveGame(itemsTaken);
}

function doLoad() {
  const takenIds = loadGame();
  if (takenIds) {
    takenIds.forEach(id => {
      const it = items.find(i => i.id === id);
      if (it) it.taken = true;
    });
  }
}

// --- Dialog system ---
function flashDialog(text) {
  state.activeDialog = { name: 'Discovery', lines: [text], idx: 0, text };
  startTypewriter(text);
}

// Initialize coffee mini-game callbacks
initCoffeeCallbacks(flashDialog, doSave);

function startDialog(n) {
  if (n.onTalk) n.onTalk();
  if ((n.id === 'rak' || n.id === 'wymysl') && !state.quests.friends) {
    const rakClose = manhattan(player, npcs.find(p => p.id === 'rak')) <= 2;
    const wymyslClose = manhattan(player, npcs.find(p => p.id === 'wymysl')) <= 2;
    if (rakClose || wymyslClose) {
      state.quests.friends = true;
      state.reputation++;
      awardBadge('friends', doSave);
      doSave();
    }
  }
  if (n.id === 'clerk' && state.quests.law && state.quests.rights && !state.quests.court) {
    startCourtArgumentChoice();
    return;
  }
  const lines = n.lines();
  state.activeDialog = { name: n.name, npcId: n.id, lines, idx: 0, text: lines[0] };
  startTypewriter(lines[0]);
  ui.showDialogTopics = false;
  ui.activeTopicIdx = 0;
  ui.activeTopicResponse = null;
  doSave();
}

function advanceDialog() {
  const d = state.activeDialog;
  d.idx++;
  if (d.idx >= d.lines.length) {
    if (d.npcId && dialogTopics[d.npcId]) {
      ui.showDialogTopics = true;
      ui.activeTopicIdx = 0;
      ui.activeTopicResponse = null;
    } else {
      state.activeDialog = null;
      ui.showDialogTopics = false;
    }
  } else {
    d.text = d.lines[d.idx];
    startTypewriter(d.text);
  }
}

function selectDialogTopic() {
  if (!state.activeDialog) return;
  const npcId = state.activeDialog.npcId || 'pig';
  const topics = getContextualTopics(npcId);
  const topic = topics[ui.activeTopicIdx];
  if (!topic) return;
  if (topic.close) {
    state.activeDialog = null;
    ui.showDialogTopics = false;
    ui.activeTopicIdx = 0;
    ui.activeTopicResponse = null;
    return;
  }
  ui.activeTopicResponse = topic.text;
}

function startOpeningScene() {
  state.mode = 'play';
  if (!state.quests.orientation) {
    state.quests.orientation = true;
    state.reputation++;
  }
  const lines = [
    'Welcome to Pig & Swine, Dr. A. Kula.',
    'Our financial situation is very difficult. Justice may be priceless, but rent has an invoice number.',
    'Mr. Swine is skiing in Japan, allegedly studying comparative snow liability.',
    'Find Muraś near reception. He will guide you through courts, Polish law, human rights, and the printer.'
  ];
  state.activeDialog = { name: 'Mr. Pig', lines, idx: 0, text: lines[0] };
  startTypewriter(lines[0]);
}

// --- Interaction ---
function interact() {
  if (state.mode === 'title') { startOpeningScene(); return; }
  if (ui.showDaySummary) { ui.showDaySummary = false; return; }
  if (ui.showResult) {
    const wasVictory = resultData && resultData.victory;
    ui.showResult = false;
    resultData = null;
    if (wasVictory) { ui.showDaySummary = true; }
    return;
  }
  if (state.activeDialog && ui.showDialogTopics) { selectDialogTopic(); return; }
  if (state.activeDialog) {
    if (skipTypewriter()) return;
    advanceDialog();
    return;
  }
  for (const n of npcs) { if (manhattan(player, n) <= 1) { startDialog(n); return; } }
  for (const item of items) { if (!item.taken && manhattan(player, item) <= 1) { takeItem(item, doSave, flashDialog); return; } }
  for (const inter of interactables) { if (manhattan(player, inter) <= 1) { startCoffeeMiniGame(canvas); return; } }
  state.message = 'Nothing billable here.';
}

// --- Court choice resolution wrappers ---
function handleResolveCourtChoice(index) {
  const result = resolveCourtChoice(index, doSave, incidentEffects, flashDialog);
  if (result && result.type === 'court') {
    resultData = { victory: result.victory };
    ui.showResult = true;
  }
}

function handleResolveNowakCourt(index) {
  const result = resolveNowakCourt(index, doSave);
  if (result) {
    resultData = { victory: result.victory, caseName: result.caseName };
    ui.showResult = true;
  }
}

// --- Random incidents ---
function handleCheckIncident() {
  if (state.activeDialog || state.choiceMenu || ui.showResult || ui.showDaySummary) return;
  checkForRandomIncident(flashDialog);
}

// --- Movement ---
function tryMove(dx, dy, face) {
  if (state.activeDialog || state.mode === 'title' || isTransitioning()) return;
  player.facing = face;
  const nx = player.x + dx, ny = player.y + dy;
  const activeMap = getActiveMap();
  if (!blocked(nx, ny, activeMap.tiles, activeMap.mapW, activeMap.mapH)) {
    player.x = nx;
    player.y = ny;
    playSound('move');
    handleCheckIncident();
    // Check for door transition
    const doors = getActiveDoors();
    const door = doors.find(d => d.x === player.x && d.y === player.y);
    if (door) {
      const entry = door.targetPos || getRoomEntry(door.room);
      if (entry) startTransition(door.room, entry);
    }
  }
}

// --- Item drawing helpers (from monolith) ---
function drawItem(item, frame) {
  if (item.taken) return;
  if (item.hidden && manhattan(player, item) > 1) return;
  const p = iso(item.x + .5, item.y + .5, 18 + Math.sin(frame / 12) * 3);
  ctx.save(); ctx.translate(p.x, p.y);
  ctx.fillStyle = 'rgba(255,215,108,.25)'; ctx.beginPath(); ctx.ellipse(0, 20, 22, 8, 0, 0, Math.PI * 2); ctx.fill();
  if (item.kind === 'binder') { ctx.fillStyle = '#aa3d42'; ctx.fillRect(-13, -16, 26, 28); ctx.fillStyle = '#f5ead2'; ctx.fillRect(-8, -10, 16, 4); ctx.fillRect(-8, -2, 16, 4); }
  else if (item.kind === 'files') { ctx.fillStyle = '#8b6d4b'; ctx.fillRect(-15, -18, 30, 24); ctx.fillStyle = '#d7a84f'; ctx.fillRect(-10, -14, 20, 4); ctx.fillRect(-10, -6, 20, 4); }
  else if (item.kind === 'stamps') { ctx.fillStyle = '#4a6b8a'; ctx.fillRect(-8, -12, 16, 20); ctx.fillStyle = '#d7a84f'; ctx.fillRect(-6, -8, 12, 3); ctx.fillRect(-6, -2, 12, 3); }
  else if (item.kind === 'coffee') { ctx.fillStyle = '#6b3fa0'; ctx.fillRect(-6, -14, 12, 24); ctx.fillStyle = '#3e2b22'; ctx.fillRect(-4, -10, 8, 6); }
  else if (item.kind === 'poster') { ctx.fillStyle = '#d46a6b'; ctx.fillRect(-10, -14, 20, 24); ctx.fillStyle = '#f5ead2'; ctx.fillRect(-7, -10, 14, 4); ctx.fillRect(-7, -2, 14, 4); }
  else { ctx.fillStyle = '#d7d8e0'; ctx.fillRect(-5, -14, 10, 24); ctx.fillStyle = '#526f45'; ctx.fillRect(-3, -10, 6, 10); }
  ctx.restore();
}

function drawInteractableSprite(inter, frame) {
  const p = iso(inter.x + .5, inter.y + .5, 20 + Math.sin(frame / 10) * 2);
  ctx.save(); ctx.translate(p.x, p.y);
  ctx.fillStyle = '#59617f'; ctx.fillRect(-12, -16, 24, 28);
  ctx.fillStyle = '#aa3d42'; ctx.fillRect(-8, -20, 16, 6);
  ctx.fillStyle = '#d7a84f'; ctx.fillRect(-4, -12, 8, 4);
  ctx.fillStyle = '#1b1f31'; ctx.fillRect(-6, -6, 4, 2); ctx.fillRect(2, -6, 4, 2);
  ctx.restore();
}

function drawNPC(n) {
  const p = iso(n.x + .5, n.y + .5, 22);
  drawLawyerSprite(p.x - 16, p.y - 40, 2, n.hue);
}

function drawPlayer() {
  const p = iso(player.visualX + .5, player.visualY + .5, 23 + Math.sin(ui.frame / 8) * 2 + player.bob);
  if (player.moving) player.walkFrame++; else player.walkFrame = 0;
  drawLawyerSprite(p.x - 16, p.y - 42, 2.2, '#33415f', player.facing, player.walkFrame);
}

// --- Main draw loop ---
function draw() {
  try {
    ui.frame++;
    if (state.mode === 'title') { drawTitleScreen(ui.frame); requestAnimationFrame(draw); return; }

    // Smooth movement interpolation
    if (player.visualX !== player.x || player.visualY !== player.y) {
      const dx = player.x - player.visualX, dy = player.y - player.visualY;
      player.visualX += Math.abs(dx) < MOVE_SPEED ? dx : Math.sign(dx) * MOVE_SPEED;
      player.visualY += Math.abs(dy) < MOVE_SPEED ? dy : Math.sign(dy) * MOVE_SPEED;
      player.moving = true;
      player.bob = Math.sin(ui.frame / 4) * 2;
    } else {
      player.moving = false;
      player.bob = 0;
    }

    ctx.save();
    applyShake();
    ctx.clearRect(0, 0, W, H);
    updateTransition();
    const activeMap = getActiveMap();
    state.currentArea = areaAt(player.x, player.y, activeMap.tiles);

    // Draw background
    drawBackground(state.currentArea, ui.frame);

    // Build entity list for depth-sorted rendering
    const entities = [];
    for (let y = 0; y < activeMap.mapH; y++) {
      for (let x = 0; x < activeMap.mapW; x++) {
        entities.push({ sort: x + y, draw: () => drawTile(x, y, activeMap.tiles[y][x], ui.frame) });
      }
    }
    for (const item of items) {
      if (!item.taken) entities.push({ sort: item.x + item.y + .2, draw: () => drawItem(item, ui.frame) });
    }
    for (const inter of interactables) {
      entities.push({ sort: inter.x + inter.y + .3, draw: () => drawInteractableSprite(inter, ui.frame) });
    }
    for (const n of npcs) {
      entities.push({ sort: n.x + n.y + .4, draw: () => drawNPC(n) });
    }
    entities.push({ sort: player.visualX + player.visualY + .5, draw: drawPlayer });
    entities.sort((a, b) => a.sort - b.sort).forEach(e => e.draw());

    // UI layers
    drawInteractHint(npcs, items, interactables, ui.frame);
    drawHUD();
    drawFlashMessage();
    if (ui.showMap) drawMiniMap();
    if (ui.showDocket) drawDocket();
    if (ui.showCaseBag) drawCaseBag();
    if (ui.showResult) drawResultScreen(resultData, ui.frame);
    if (ui.showDaySummary) drawDaySummary(ui.frame);
    if (state.choiceMenu) drawChoiceMenu();
    if (state.activeDialog && !ui.showDialogTopics) drawDialog();
    if (state.activeDialog && ui.showDialogTopics) drawDialogTopics(ui.activeTopicIdx, ui.activeTopicResponse);
    const coffeeMG = getCoffeeMiniGame();
    if (coffeeMG && coffeeMG.active) drawCoffeeMiniGame(ui.frame);

    if (room.transitionAlpha > 0) drawTransition(room.transitionAlpha);
    ctx.restore(); // end shake
    requestAnimationFrame(draw);
  } catch (e) {
    ctx.fillStyle = '#151827'; ctx.fillRect(0, 0, W, H);
    ctx.fillStyle = '#aa3d42'; ctx.font = '16px monospace'; ctx.textAlign = 'left';
    ctx.fillText('JS Error: ' + e.message, 20, 40);
    ctx.fillText('Stack: ' + (e.stack || '').split('\n')[1], 20, 65);
    console.error('Draw error:', e);
    requestAnimationFrame(draw);
  }
}

// --- Input setup ---
setupInput({
  interact,
  tryMove,
  saveGame: doSave,
  loadGame: doLoad,
  getContextualTopics,
  selectDialogTopic,
  resolveCourtChoice: handleResolveCourtChoice,
  resolveNowakCourt: handleResolveNowakCourt
});

setupMovementTick(tryMove);

// --- Debug ---
window.__pigDebug = { state, player, npcs, items, startCourtArgumentChoice, resolveCourtChoice };

// --- Boot ---
if (hasSave()) {
  state.mode = 'play';
  doLoad();
}

draw();
