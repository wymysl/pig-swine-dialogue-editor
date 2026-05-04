// === Character Data ===
// NPC definitions, portrait palettes, positions.

export const PORTRAIT_PALETTES = {
  kula:   { base: '#4a6b8a', shadow: '#385673', face: '#f1bd93', eyes: '#1b1f31', hair: '#0b0d16', highlight: '#8bb1e0' },
  pig:    { base: '#c96c78', shadow: '#b95f6b', face: '#f1bd93', eyes: '#1b1f31', snout: '#d7a84f' },
  swine:  { base: '#d88992', shadow: '#c96c78', face: '#f5ead2', eyes: '#1b1f31', snout: '#e0b35b' },
  muras:  { base: '#e0b35b', shadow: '#c89a32', face: '#f1bd93', eyes: '#1b1f31', glasses: '#d7a84f', hair: '#33415f' },
  rak:    { base: '#7fb069', shadow: '#6a9a52', face: '#f1bd93', eyes: '#1b1f31', hair: '#33415f', jacket: '#5b4634' },
  wymysl: { base: '#d7a84f', shadow: '#c0913a', face: '#f1bd93', eyes: '#1b1f31', mouth: '#aa3d42', hair: '#33415f' },
  clerk:  { base: '#8bb1e0', shadow: '#7a9bcc', face: '#f1bd93', eyes: '#1b1f31', hair: '#33415f' },
  tram:   { base: '#e1d156', shadow: '#c9b848', face: '#f1bd93', eyes: '#1b1f31', smile: '#d7a84f' },
  nowak:  { base: '#d46a6b', shadow: '#b85a5b', face: '#f1bd93', eyes: '#1b1f31', hair: '#33415f', scarf: '#8bb1e0' },
  archivist: { base: '#8b5a2b', shadow: '#6d4522', face: '#f1bd93', eyes: '#1b1f31', hair: '#33415f' },
  judge:  { base: '#4a6b8a', shadow: '#385673', face: '#f1bd93', eyes: '#1b1f31', hair: '#33415f' },
  barista: { base: '#6b3fa0', shadow: '#562f88', face: '#f1bd93', eyes: '#1b1f31', hair: '#33415f' },
};

export const FACING_OFFSETS = {
  down:  { bodyShift: 0, armSwing: true },
  up:    { bodyShift: 0, armSwing: true },
  left:  { bodyShift: -1, armSwing: true },
  right: { bodyShift: 1, armSwing: true },
};
