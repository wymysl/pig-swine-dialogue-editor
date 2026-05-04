// === Save/Load System (v3) ===
// Versioned save/load with migration pipeline and chapter progress tracking.
// Replaces the original src/save.js — Integration must update the import path in main.js.
import { state, player, ui, room } from '../state.js';

const SAVE_KEY = 'pigSwineSave';

/** Current save format version */
export const SAVE_VERSION = 3;

/** Default chapter1 flags — used by migration and reset */
const CHAPTER1_DEFAULTS = {
  started: false,
  enteredOffice: false,
  pigRevealedCrisis: false,
  metMuras: false,
  receivedCaseSummary: false,
  hasLawBinder: false,
  hasRightsMemo: false,
  recruitedRak: false,
  recruitedWymysl: false,
  coffeeTutorialSeen: false,
  coffeeBuff: null,
  courtUnlocked: false,
  courtStarted: false,
  arguedDefectiveService: false,
  arguedFairHearing: false,
  arguedRemedy: false,
  wonCourt: false,
  receivedSwinePostcard: false,
  complete: false
};

/**
 * Migrate a save from any older version to the current SAVE_VERSION.
 * Each step is cumulative: v1→v2→v3.
 * @param {object} saveData - Raw parsed save data from localStorage
 * @returns {object} Migrated save data at SAVE_VERSION
 */
export function migrateSave(saveData) {
  // v1 → v2: add nowakEvidence, badges, incidentCooldown, lastIncidentId
  if (!saveData.version || saveData.version < 2) {
    saveData.version = 2;
    if (!saveData.state) saveData.state = {};
    saveData.state.nowakEvidence = saveData.state.nowakEvidence || { lease: false, poster: false, notice: false };
    saveData.state.badges = saveData.state.badges || [];
    saveData.state.incidentCooldown = saveData.state.incidentCooldown || 0;
    saveData.state.lastIncidentId = saveData.state.lastIncidentId || null;
    if (!saveData.room) saveData.room = { current: 'overworld' };
  }

  // v2 → v3: add chapter tracking, chapter1 flags, incidentHistory
  if (saveData.version === 2) {
    saveData.version = 3;
    saveData.state.chapter = saveData.state.chapter || 1;
    saveData.state.chapter1 = saveData.state.chapter1 || { ...CHAPTER1_DEFAULTS };
    saveData.state.incidentHistory = saveData.state.incidentHistory || [];
  }

  return saveData;
}

/** Save the full game state to localStorage */
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
      incidentHistory: [...state.incidentHistory],
      chapter: state.chapter,
      chapter1: { ...state.chapter1 },
    },
    player: {
      x: player.x,
      y: player.y,
      facing: player.facing,
    },
    room: {
      current: room.current,
    },
    itemsTaken,
    timestamp: Date.now(),
  };

  try {
    localStorage.setItem(SAVE_KEY, JSON.stringify(saveData));
    state.flashMessage = 'Game Saved!';
    state.flashTimer = 90;
    return true;
  } catch (e) {
    return false;
  }
}

/** Load game state from localStorage, applying migrations if needed */
export function loadGame() {
  const saveStr = localStorage.getItem(SAVE_KEY);
  if (!saveStr) return null;

  try {
    let saveData = JSON.parse(saveStr);

    // Apply version migrations
    if (saveData.version !== SAVE_VERSION) {
      saveData = migrateSave(saveData);
      // Re-persist migrated save
      localStorage.setItem(SAVE_KEY, JSON.stringify(saveData));
    }

    // Restore state
    state.gold = saveData.state.gold;
    state.reputation = saveData.state.reputation;
    state.stress = saveData.state.stress;
    state.coffee = saveData.state.coffee;
    state.files = saveData.state.files;
    state.evidence = saveData.state.evidence;
    state.rightsMemo = saveData.state.rightsMemo;

    // Restore nowakEvidence
    if (saveData.state.nowakEvidence) {
      Object.assign(state.nowakEvidence, saveData.state.nowakEvidence);
    }

    // Restore quests
    Object.assign(state.quests, saveData.state.quests);

    // Restore badges
    if (saveData.state.badges) {
      state.badges = saveData.state.badges.map(b => ({ ...b }));
    }

    // Restore incident state
    state.incidentCooldown = saveData.state.incidentCooldown || 0;
    state.lastIncidentId = saveData.state.lastIncidentId || null;
    state.incidentHistory = saveData.state.incidentHistory || [];

    // Restore chapter tracking
    state.chapter = saveData.state.chapter || 1;
    if (saveData.state.chapter1) {
      Object.assign(state.chapter1, saveData.state.chapter1);
    }

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
    return null;
  }
}

/** Check whether a save exists in localStorage */
export function hasSave() {
  return !!localStorage.getItem(SAVE_KEY);
}

/** Show the "Game Saved!" flash message */
export function showSaveFlash() {
  state.flashMessage = 'Game Saved!';
  state.flashTimer = 90;
}
