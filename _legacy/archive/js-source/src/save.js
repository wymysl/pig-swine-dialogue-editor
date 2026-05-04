// === Save/Load System ===
// Complete save/load — persists ALL game state including evidence, badges, items.
import { state, player, ui, room } from './state.js';

const SAVE_KEY = 'pigSwineSave';
const SAVE_VERSION = 2; // Bumped to fix broken save format

export function saveGame(itemsTaken = []) {
  const saveData = {
    version: SAVE_VERSION,
    state: {
      gold: state.gold,
      reputation: state.reputation,
      stress: state.stress,
      coffee: state.coffee,
      files: state.files,
      evidence: state.evidence,
      rightsMemo: state.rightsMemo,
      nowakEvidence: { ...state.nowakEvidence },
      quests: { ...state.quests },
      badges: state.badges.map(b => ({ ...b })),
      incidentCooldown: state.incidentCooldown,
      lastIncidentId: state.lastIncidentId,
    },
    player: {
      x: player.x,
      y: player.y,
      facing: player.facing,
    },
    room: {
      current: room.current,
    },
    itemsTaken, // Array of taken item IDs
    timestamp: Date.now(),
  };

  try {
    localStorage.setItem(SAVE_KEY, JSON.stringify(saveData));
    state.flashMessage = 'Game Saved!';
    state.flashTimer = 90;
    return true;
  } catch (e) {
    console.error('Save failed:', e);
    return false;
  }
}

export function loadGame() {
  const saveStr = localStorage.getItem(SAVE_KEY);
  if (!saveStr) return null;

  try {
    const saveData = JSON.parse(saveStr);

    // Restore state
    state.gold = saveData.state.gold;
    state.reputation = saveData.state.reputation;
    state.stress = saveData.state.stress;
    state.coffee = saveData.state.coffee;
    state.files = saveData.state.files;
    state.evidence = saveData.state.evidence;
    state.rightsMemo = saveData.state.rightsMemo;

    // Restore nowakEvidence (was missing in v1!)
    if (saveData.state.nowakEvidence) {
      Object.assign(state.nowakEvidence, saveData.state.nowakEvidence);
    }

    // Restore quests
    Object.assign(state.quests, saveData.state.quests);

    // Restore badges (was missing in v1!)
    if (saveData.state.badges) {
      state.badges = saveData.state.badges.map(b => ({ ...b }));
    }

    // Restore incident state
    state.incidentCooldown = saveData.state.incidentCooldown || 0;
    state.lastIncidentId = saveData.state.lastIncidentId || null;

    // Restore player position
    player.x = saveData.player.x;
    player.y = saveData.player.y;
    player.facing = saveData.player.facing;
    player.visualX = player.x;
    player.visualY = player.y;
    player.moving = false;

    // Restore room
    if (saveData.room) {
      room.current = saveData.room.current;
    }

    // Clear UI state
    state.mode = 'play';
    state.activeDialog = null;
    state.choiceMenu = null;
    ui.showResult = false;
    ui.showDaySummary = false;
    ui.showDialogTopics = false;

    return saveData.itemsTaken || [];
  } catch (e) {
    console.error('Load failed:', e);
    return null;
  }
}

export function hasSave() {
  return !!localStorage.getItem(SAVE_KEY);
}

export function showSaveFlash() {
  state.flashMessage = 'Game Saved!';
  state.flashTimer = 90;
}
