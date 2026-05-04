// === Room Transition System ===
// Fade-to-black transitions between overworld and interior rooms.
// Reads/writes room.* state fields. Communicates via state, not direct imports.
import { room, player } from '../state.js';
import { ROOMS, OVERWORLD_DOORS, overworldTiles, MAP_W, MAP_H } from '../data/maps.js';

/** Transition phase constants */
const PHASE_NONE = 0;
const PHASE_OUT = 1;
const PHASE_SWAP = 2;
const PHASE_IN = 3;

/** Fade speed — alpha change per frame (0→1 in ~20 frames) */
const FADE_SPEED = 0.05;

/** Current transition phase */
let phase = PHASE_NONE;

/** Callbacks supplied by Integration via initTransitions */
let callbacks = {
  playSound: () => {},
  onRoomLoaded: () => {},
};

/** Initialize the transition system with callbacks */
export function initTransitions(config = {}) {
  if (config.playSound) callbacks.playSound = config.playSound;
  if (config.onRoomLoaded) callbacks.onRoomLoaded = config.onRoomLoaded;
}

/** Begin a room transition: fade out → swap room → fade in */
export function startTransition(targetRoom, playerPos) {
  if (room.transitioning) return;
  room.transitioning = true;
  room.transitionTarget = targetRoom;
  room.transitionPlayerPos = playerPos ? { x: playerPos.x, y: playerPos.y } : null;
  room.transitionAlpha = 0;
  phase = PHASE_OUT;
  callbacks.playSound('door');
}

/** Advance the transition animation by one frame. Call from the draw loop. */
export function updateTransition() {
  if (phase === PHASE_NONE) return;

  if (phase === PHASE_OUT) {
    room.transitionAlpha = Math.min(1, room.transitionAlpha + FADE_SPEED);
    if (room.transitionAlpha >= 1) {
      phase = PHASE_SWAP;
    }
    return;
  }

  if (phase === PHASE_SWAP) {
    // Perform the room swap at full black
    const target = room.transitionTarget;
    room.current = target;

    // Place player at the target position
    if (room.transitionPlayerPos) {
      player.x = room.transitionPlayerPos.x;
      player.y = room.transitionPlayerPos.y;
      player.visualX = player.x;
      player.visualY = player.y;
      player.moving = false;
      player.bob = 0;
    }

    // Notify Integration that the room has changed
    callbacks.onRoomLoaded(target);

    phase = PHASE_IN;
    return;
  }

  if (phase === PHASE_IN) {
    room.transitionAlpha = Math.max(0, room.transitionAlpha - FADE_SPEED);
    if (room.transitionAlpha <= 0) {
      // Transition complete
      room.transitioning = false;
      room.transitionTarget = null;
      room.transitionPlayerPos = null;
      room.transitionAlpha = 0;
      phase = PHASE_NONE;
    }
    return;
  }
}

/** Check if a transition is currently in progress */
export function isTransitioning() {
  return room.transitioning;
}

/** Get the active map data for the current room */
export function getActiveMap() {
  if (room.current === 'overworld') {
    return { tiles: overworldTiles, mapW: MAP_W, mapH: MAP_H };
  }
  const r = ROOMS[room.current];
  if (r) {
    return { tiles: r.tiles, mapW: r.w, mapH: r.h };
  }
  // Fallback to overworld if room ID is unknown
  return { tiles: overworldTiles, mapW: MAP_W, mapH: MAP_H };
}

/** Get the door array for the current room */
export function getActiveDoors() {
  if (room.current === 'overworld') {
    return OVERWORLD_DOORS;
  }
  const r = ROOMS[room.current];
  if (r && r.exit) {
    // Interior rooms have a single exit door
    return [{
      x: r.exit.x,
      y: r.exit.y,
      room: r.exit.targetRoom,
      targetPos: r.exit.targetPos,
      label: `Exit to ${r.exit.targetRoom === 'overworld' ? 'Outside' : r.exit.targetRoom}`
    }];
  }
  return [];
}

/** Get the room entry position for a target room */
export function getRoomEntry(roomId) {
  const r = ROOMS[roomId];
  if (r && r.entry) {
    return { x: r.entry.x, y: r.entry.y };
  }
  return null;
}
