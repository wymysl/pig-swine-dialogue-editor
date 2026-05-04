// === Map Data ===
// Tile arrays, room definitions, collision logic.

export const MAP_W = 24, MAP_H = 24;
export const TILE_W = 64, TILE_H = 32;

// Generate overworld tiles
function generateOverworld() {
  const tiles = Array.from({ length: MAP_H }, (_, y) =>
    Array.from({ length: MAP_W }, (_, x) => {
      if (x === 0 || y === 0 || x === MAP_W - 1 || y === MAP_H - 1) return 'wall';
      if (x > 1 && x < 7 && y > 1 && y < 7) return 'archive';
      if ((x > 1 && x < 7 && y > 7 && y < 12) || (x > 10 && x < 16 && y > 2 && y < 7)) return 'building';
      if (x > 16 && x < 22 && y > 2 && y < 10) return 'court';
      if (x > 16 && x < 22 && y > 12 && y < 20) return 'cafe';
      if (x === 12 || y === 12 || (y === 8 && x > 3 && x < 18)) return 'street';
      if (x === 18 && y > 7 && y < 13) return 'street';
      if ((x + y) % 7 === 0) return 'cobble';
      return 'park';
    })
  );

  // Office interior
  for (let y = 9; y < 13; y++) for (let x = 3; x < 8; x++) tiles[y][x] = 'office';
  for (let x = 4; x < 7; x++) tiles[8][x] = 'street';
  tiles[11][5] = 'desk'; tiles[10][6] = 'books'; tiles[9][4] = 'files';

  // Court
  for (let y = 4; y < 8; y++) for (let x = 12; x < 16; x++) tiles[y][x] = 'court';
  tiles[7][14] = 'street';

  // Cafe
  for (let y = 13; y < 16; y++) for (let x = 11; x < 15; x++) tiles[y][x] = 'cafe';
  tiles[12][13] = 'street';
  tiles[15][8] = 'tram';

  return tiles;
}

export const overworldTiles = generateOverworld();

// Interior room maps (new!) — each is a small self-contained room
export const ROOMS = {
  office: {
    name: 'Pig & Swine Office',
    w: 16, h: 12,
    entry: { x: 8, y: 10 },
    exit: { x: 8, y: 11, targetRoom: 'overworld', targetPos: { x: 5, y: 12 } },
    tiles: generateOfficeRoom(),
    bgColor: ['#2a2130', '#1f1827'],
  },
  court: {
    name: 'Warsaw District Court',
    w: 14, h: 10,
    entry: { x: 7, y: 8 },
    exit: { x: 7, y: 9, targetRoom: 'overworld', targetPos: { x: 14, y: 8 } },
    tiles: generateCourtRoom(),
    bgColor: ['#252838', '#1a1d2d'],
  },
  cafe: {
    name: 'Café Paragraf',
    w: 12, h: 10,
    entry: { x: 6, y: 8 },
    exit: { x: 6, y: 9, targetRoom: 'overworld', targetPos: { x: 13, y: 16 } },
    tiles: generateCafeRoom(),
    bgColor: ['#2d2218', '#1f1812'],
  },
  archive: {
    name: 'The Archive',
    w: 12, h: 10,
    entry: { x: 6, y: 8 },
    exit: { x: 6, y: 9, targetRoom: 'overworld', targetPos: { x: 4, y: 7 } },
    tiles: generateArchiveRoom(),
    bgColor: ['#1f1a14', '#161210'],
  },
};

function generateOfficeRoom() {
  const w = 16, h = 12;
  return Array.from({ length: h }, (_, y) =>
    Array.from({ length: w }, (_, x) => {
      if (x === 0 || y === 0 || x === w - 1) return 'wall';
      if (y === h - 1 && x !== 8) return 'wall';
      if (y === h - 1 && x === 8) return 'door';
      // Desks
      if (y === 3 && (x === 3 || x === 4 || x === 11 || x === 12)) return 'desk';
      // Bookshelves along top wall
      if (y === 1 && x > 1 && x < w - 2) return 'books';
      // Filing cabinets
      if (x === 1 && y > 3 && y < 8) return 'files';
      // Mr. Pig's big desk
      if (y === 5 && x >= 7 && x <= 9) return 'desk';
      return 'office';
    })
  );
}

function generateCourtRoom() {
  const w = 14, h = 10;
  return Array.from({ length: h }, (_, y) =>
    Array.from({ length: w }, (_, x) => {
      if (x === 0 || y === 0 || x === w - 1) return 'wall';
      if (y === h - 1 && x !== 7) return 'wall';
      if (y === h - 1 && x === 7) return 'door';
      // Judge's bench
      if (y === 2 && x >= 5 && x <= 9) return 'desk';
      // Gallery benches
      if (y === 5 && (x >= 2 && x <= 5)) return 'desk';
      if (y === 5 && (x >= 9 && x <= 12)) return 'desk';
      if (y === 7 && (x >= 2 && x <= 5)) return 'desk';
      if (y === 7 && (x >= 9 && x <= 12)) return 'desk';
      return 'court';
    })
  );
}

function generateCafeRoom() {
  const w = 12, h = 10;
  return Array.from({ length: h }, (_, y) =>
    Array.from({ length: w }, (_, x) => {
      if (x === 0 || y === 0 || x === w - 1) return 'wall';
      if (y === h - 1 && x !== 6) return 'wall';
      if (y === h - 1 && x === 6) return 'door';
      // Counter
      if (y === 2 && x >= 2 && x <= 5) return 'desk';
      // Tables
      if (y === 5 && (x === 3 || x === 8)) return 'desk';
      if (y === 7 && (x === 3 || x === 8)) return 'desk';
      return 'cafe';
    })
  );
}

function generateArchiveRoom() {
  const w = 12, h = 10;
  return Array.from({ length: h }, (_, y) =>
    Array.from({ length: w }, (_, x) => {
      if (x === 0 || y === 0 || x === w - 1) return 'wall';
      if (y === h - 1 && x !== 6) return 'wall';
      if (y === h - 1 && x === 6) return 'door';
      // Shelving rows
      if (x === 3 && y > 1 && y < 8) return 'books';
      if (x === 6 && y > 1 && y < 5) return 'books';
      if (x === 9 && y > 1 && y < 8) return 'books';
      return 'archive';
    })
  );
}

// Tile palette — colors for each tile type
export const TILE_PALETTE = {
  street:   ['#536176', '#3c475c'],
  cobble:   ['#697077', '#4e5966'],
  park:     ['#57734b', '#3f5a38'],
  office:   ['#b99562', '#7d543c'],
  cafe:     ['#8b6d4b', '#5b4634'],
  court:    ['#c9c3ad', '#8f897d'],
  archive:  ['#8b6d4b', '#5b4634'],
  tram:     ['#b6a83e', '#6e692c'],
  files:    ['#b99562', '#7d543c'],
  wall:     ['#303647', '#202536'],
  building: ['#41485f', '#272d40'],
  desk:     ['#7b4b32', '#43291f'],
  books:    ['#66563a', '#332b26'],
  door:     ['#d7a84f', '#a07830'],
};

// Collision check
export function blocked(x, y, tiles, mapW, mapH) {
  if (x < 1 || y < 1 || x >= mapW - 1 || y >= mapH - 1) return true;
  const t = tiles[y]?.[x];
  return ['building', 'wall', 'desk', 'books'].includes(t);
}

// What area is the player in
export function areaAt(x, y, tiles) {
  const t = tiles[y]?.[x];
  if (['office', 'desk', 'books', 'files'].includes(t)) return 'Pig & Swine Office';
  if (t === 'court') return 'Court Hall';
  if (t === 'cafe') return 'Coffee Shop';
  if (t === 'archive') return 'Archive Interior';
  if (t === 'door') return 'Doorway';
  return 'outside';
}

// Door zones on the overworld — walk into these to trigger room transitions
export const OVERWORLD_DOORS = [
  { x: 5, y: 8,  room: 'office',  label: 'Enter Pig & Swine Office' },
  { x: 14, y: 7, room: 'court',   label: 'Enter Warsaw Court' },
  { x: 13, y: 12, room: 'cafe',   label: 'Enter Café Paragraf' },
  { x: 4, y: 7,  room: 'archive', label: 'Enter The Archive' },
];

export function manhattan(a, b) {
  return Math.abs(a.x - b.x) + Math.abs(a.y - b.y);
}
