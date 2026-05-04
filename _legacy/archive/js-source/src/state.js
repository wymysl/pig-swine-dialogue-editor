// === Game State ===
// All mutable game state lives here. Imported by everything, owned by main.js.

export const state = {
  mode: 'title',
  gold: 12,
  reputation: 0,
  stress: 0,
  coffee: 0,
  files: 0,
  evidence: 0,
  rightsMemo: 0,
  nowakEvidence: { lease: false, poster: false, notice: false },
  activeDialog: null,
  choiceMenu: null,
  flashMessage: null,
  flashTimer: 0,
  incidentCooldown: 0,
  lastIncidentId: null,
  incidentHistory: [],
  currentArea: 'outside',
  message: 'Press Space to begin Dr. A. Kula\'s adventure.',
  quests: {
    orientation: false, guide: false, friends: false,
    law: false, rights: false, court: false,
    archive: false, courtHall: false, coffeeRun: false, nowakCase: false
  },
  badges: [],

  // Chapter progress tracking
  chapter: 1,

  // Chapter 1 quest flags — see docs/chapters/1.md
  chapter1: {
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
  },
};

export const player = {
  x: 8, y: 12,
  facing: 'down',
  moving: false,
  bob: 0,
  visualX: 8, visualY: 12,
  moveTimer: 0,
  walkFrame: 0,
  walkCycle: 0,
};

export const BADGES = [
  { id: 'orientation', name: 'First Day',    desc: 'Completed orientation with Mr. Pig',   color: '#FFD700' },
  { id: 'guide',       name: 'Mentor',       desc: 'Found Muraś the guide',               color: '#FFA500' },
  { id: 'friends',     name: 'Ally',         desc: 'Recruited Rak and Wymysl',             color: '#7fb069' },
  { id: 'law',         name: 'Law Binder',   desc: 'Collected Polish law binder',          color: '#4a6b8a' },
  { id: 'rights',      name: 'Human Rights', desc: 'Found human rights memo',              color: '#e1d156' },
  { id: 'court',       name: 'Courtroom',    desc: 'Won first court case',                 color: '#8bb1e0' },
  { id: 'archive',     name: 'Archivist',    desc: 'Explored The Archive',                 color: '#8b5a2b' },
  { id: 'courtHall',   name: 'Court Hall',   desc: 'Accessed expanded court hall',         color: '#4a6b8a' },
  { id: 'coffeeRun',   name: 'Barista',      desc: 'Completed coffee run',                 color: '#6b3fa0' },
  { id: 'nowakCase',   name: 'Eviction Defender', desc: 'Saved Ms. Nowak from eviction',   color: '#d46a6b' },
];

// UI overlay toggles
export const ui = {
  showMap: false,
  showDocket: false,
  showCaseBag: false,
  showResult: false,
  showDaySummary: false,
  showDialogTopics: false,
  activeTopicIdx: 0,
  activeTopicResponse: null,
  resultData: null,
  coffeeMiniGame: null,
  frame: 0,
};

// Camera state for smooth scrolling
export const camera = {
  x: 0,
  y: 0,
  targetX: 0,
  targetY: 0,
  shake: 0,
  shakeIntensity: 0,
};

// Current room (for interior transitions)
export const room = {
  current: 'overworld', // 'overworld', 'office', 'court', 'cafe', 'archive', 'apartment'
  transitioning: false,
  transitionAlpha: 0,
  transitionTarget: null,
  transitionPlayerPos: null,
};

export function resetState() {
  Object.assign(state, {
    mode: 'title', gold: 12, reputation: 0, stress: 0, coffee: 0,
    files: 0, evidence: 0, rightsMemo: 0,
    nowakEvidence: { lease: false, poster: false, notice: false },
    activeDialog: null, choiceMenu: null, flashMessage: null, flashTimer: 0,
    incidentCooldown: 0, lastIncidentId: null, incidentHistory: [],
    currentArea: 'outside',
    message: 'Press Space to begin Dr. A. Kula\'s adventure.',
    quests: { orientation: false, guide: false, friends: false, law: false, rights: false, court: false, archive: false, courtHall: false, coffeeRun: false, nowakCase: false },
    badges: [],
    chapter: 1,
    chapter1: {
      started: false, enteredOffice: false, pigRevealedCrisis: false,
      metMuras: false, receivedCaseSummary: false,
      hasLawBinder: false, hasRightsMemo: false,
      recruitedRak: false, recruitedWymysl: false,
      coffeeTutorialSeen: false, coffeeBuff: null,
      courtUnlocked: false, courtStarted: false,
      arguedDefectiveService: false, arguedFairHearing: false,
      arguedRemedy: false, wonCourt: false,
      receivedSwinePostcard: false, complete: false
    },
  });
  Object.assign(player, { x: 8, y: 12, facing: 'down', moving: false, bob: 0, visualX: 8, visualY: 12, moveTimer: 0, walkFrame: 0, walkCycle: 0 });
  Object.assign(camera, { x: 0, y: 0, targetX: 0, targetY: 0, shake: 0, shakeIntensity: 0 });
  Object.assign(room, { current: 'overworld', transitioning: false, transitionAlpha: 0, transitionTarget: null, transitionPlayerPos: null });
}
