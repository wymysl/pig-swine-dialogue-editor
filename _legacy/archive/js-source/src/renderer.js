// === Renderer ===
// All canvas drawing: iso math, tiles, sprites, portraits, UI chrome.
import { state, player, ui, camera } from './state.js';
import { TILE_W, TILE_H, TILE_PALETTE } from './data/maps.js';
import { PORTRAIT_PALETTES } from './data/characters.js';

let ctx, W, H, ORIGIN_X, ORIGIN_Y;

export function initRenderer(canvas) {
  ctx = canvas.getContext('2d');
  ctx.imageSmoothingEnabled = false;
  W = canvas.width;
  H = canvas.height;
  ORIGIN_X = W / 2;
  ORIGIN_Y = 92;
}

export function getCtx() { return ctx; }
export function getW() { return W; }
export function getH() { return H; }

// Camera-aware iso projection
export function iso(x, y, z = 0) {
  return {
    x: ORIGIN_X + (x - y) * TILE_W / 2 - camera.x,
    y: ORIGIN_Y + (x + y) * TILE_H / 2 - z - camera.y,
  };
}

// Shake offset
export function applyShake() {
  if (camera.shake > 0) {
    const intensity = camera.shakeIntensity * (camera.shake / 10);
    ctx.translate(
      (Math.random() - 0.5) * intensity,
      (Math.random() - 0.5) * intensity
    );
    camera.shake--;
  }
}

export function triggerShake(frames = 8, intensity = 6) {
  camera.shake = frames;
  camera.shakeIntensity = intensity;
}

// Update camera to follow player smoothly
export function updateCamera(px, py, mapW, mapH) {
  const target = iso(px, py);
  // We want player roughly centered; compute offset needed
  camera.targetX = (px - py) * TILE_W / 2 - 0; // keep centered at ORIGIN_X
  camera.targetY = (px + py) * TILE_H / 2 - (H / 2 - ORIGIN_Y);
  // Smooth lerp
  camera.x += (camera.targetX - camera.x) * 0.08;
  camera.y += (camera.targetY - camera.y) * 0.08;
}

// === Drawing primitives ===
export function diamond(x, y, w, h, top, edge) {
  ctx.fillStyle = top;
  ctx.beginPath();
  ctx.moveTo(x, y - h / 2); ctx.lineTo(x + w / 2, y); ctx.lineTo(x, y + h / 2); ctx.lineTo(x - w / 2, y);
  ctx.closePath(); ctx.fill();
  ctx.strokeStyle = edge; ctx.lineWidth = 2; ctx.stroke();
}

function lighten(hex, amt) {
  let n = parseInt(hex.slice(1), 16);
  let r = Math.min(255, (n >> 16) + amt);
  let g = Math.min(255, ((n >> 8) & 255) + amt);
  let b = Math.min(255, (n & 255) + amt);
  return `rgb(${r},${g},${b})`;
}

export function drawBlock(x, y, front, side, h) {
  ctx.fillStyle = side;
  ctx.beginPath(); ctx.moveTo(x + 32, y); ctx.lineTo(x + 32, y - h); ctx.lineTo(x, y + 16 - h); ctx.lineTo(x, y + 16); ctx.closePath(); ctx.fill();
  ctx.fillStyle = front;
  ctx.beginPath(); ctx.moveTo(x - 32, y); ctx.lineTo(x - 32, y - h); ctx.lineTo(x, y + 16 - h); ctx.lineTo(x, y + 16); ctx.closePath(); ctx.fill();
  ctx.fillStyle = lighten(front, 18);
  ctx.beginPath(); ctx.moveTo(x, y - 16 - h); ctx.lineTo(x + 32, y - h); ctx.lineTo(x, y + 16 - h); ctx.lineTo(x - 32, y - h); ctx.closePath(); ctx.fill();
  ctx.strokeStyle = '#202536'; ctx.stroke();
}

// === Tile rendering ===
export function drawTile(x, y, t, frame) {
  const p = iso(x, y);
  const [a, b] = TILE_PALETTE[t] || TILE_PALETTE.park;
  diamond(p.x, p.y, TILE_W, TILE_H, a, b);

  if (t === 'building' || t === 'court') {
    drawBlock(p.x, p.y, t === 'court' ? '#d8d1bd' : '#4f5872', t === 'court' ? '#aaa28e' : '#303850', 42);
  }
  if (t === 'court') {
    ctx.strokeStyle = 'rgba(79,75,68,.35)'; ctx.lineWidth = 1;
    ctx.beginPath(); ctx.moveTo(p.x - 24, p.y); ctx.lineTo(p.x + 24, p.y); ctx.stroke();
    ctx.fillStyle = '#6d2f45'; ctx.fillRect(p.x - 15, p.y - 26, 30, 5);
  }
  if (t === 'office') {
    ctx.strokeStyle = 'rgba(62,43,34,.45)'; ctx.lineWidth = 1;
    for (let i = -22; i <= 22; i += 8) { ctx.beginPath(); ctx.moveTo(p.x + i, p.y - 10); ctx.lineTo(p.x + i + 18, p.y + 6); ctx.stroke(); }
    ctx.fillStyle = '#3e2b22'; ctx.fillRect(p.x - 14, p.y - 20, 28, 12);
    ctx.fillStyle = '#ffd76c'; ctx.fillRect(p.x - 8, p.y - 17, 16, 4);
    ctx.fillStyle = 'rgba(245,234,210,.9)'; ctx.fillRect(p.x + 7, p.y - 13, 7, 5); ctx.fillRect(p.x - 17, p.y - 6, 8, 4);
  }
  if (t === 'cafe') {
    ctx.fillStyle = '#2e2018'; ctx.fillRect(p.x - 16, p.y - 18, 32, 10);
    ctx.fillStyle = '#f5ead2'; ctx.fillRect(p.x - 11, p.y - 16, 22, 5);
    ctx.fillStyle = '#d7a84f'; ctx.fillRect(p.x - 18, p.y - 5, 5, 4); ctx.fillRect(p.x + 13, p.y - 3, 5, 4);
  }
  if (t === 'archive') {
    ctx.fillStyle = '#5b4634'; ctx.fillRect(p.x - 18, p.y - 24, 36, 16);
    const bookColors = ['#c96c78', '#e0b35b', '#7fb069', '#d7a84f', '#8bb1e0', '#aa3d42'];
    for (let i = 0; i < 6; i++) { ctx.fillStyle = bookColors[i]; ctx.fillRect(p.x - 15 + i * 5, p.y - 22, 4, 12); }
  }
  if (t === 'tram') {
    ctx.fillStyle = '#e1d156'; ctx.fillRect(p.x - 22, p.y - 23, 44, 16);
    ctx.fillStyle = '#222'; ctx.fillRect(p.x - 15, p.y - 20, 12, 7); ctx.fillRect(p.x + 4, p.y - 20, 12, 7);
  }
  if (t === 'door') {
    ctx.fillStyle = '#d7a84f'; ctx.fillRect(p.x - 8, p.y - 18, 16, 16);
    ctx.fillStyle = '#a07830'; ctx.fillRect(p.x - 6, p.y - 16, 12, 12);
    ctx.fillStyle = '#ffd76c'; ctx.fillRect(p.x + 3, p.y - 10, 3, 3); // door handle
  }
}

// === Sprite rendering ===
export function drawLawyerSprite(x, y, s, coat, facing = 'down', walkFrame = 0) {
  ctx.save(); ctx.translate(x, y); ctx.scale(s, s);
  // Head
  ctx.fillStyle = '#f1bd93'; ctx.fillRect(5, 1, 8, 8);
  ctx.fillStyle = '#2b1a12'; ctx.fillRect(4, 0, 10, 3);
  // Body
  ctx.fillStyle = coat; ctx.fillRect(3, 9, 12, 14);
  ctx.fillStyle = '#f5ead2'; ctx.fillRect(7, 10, 4, 10);
  ctx.fillStyle = '#aa3d42'; ctx.fillRect(8, 13, 2, 7);
  // Legs — animate walk
  const legOffset = Math.sin(walkFrame * 0.4) * 2;
  ctx.fillStyle = '#1b1f31';
  ctx.fillRect(4, 23 + (legOffset > 0 ? legOffset : 0), 4, 7);
  ctx.fillRect(11, 23 + (legOffset < 0 ? -legOffset : 0), 4, 7);
  // Shoes
  ctx.fillStyle = '#0b0d16';
  ctx.fillRect(3, 30 + (legOffset > 0 ? legOffset : 0), 5, 2);
  ctx.fillRect(11, 30 + (legOffset < 0 ? -legOffset : 0), 5, 2);
  // Facing indicator (back view)
  if (facing === 'up') {
    ctx.fillStyle = '#2b1a12'; ctx.fillRect(5, 1, 8, 8); // hair covers face
  }
  ctx.restore();
}

export function drawPigSeal(x, y, s) {
  ctx.save(); ctx.translate(x, y); ctx.scale(s, s);
  ctx.fillStyle = '#d88992'; ctx.fillRect(0, 8, 30, 20); ctx.fillRect(5, 2, 6, 8); ctx.fillRect(20, 2, 6, 8);
  ctx.fillStyle = '#b95f6b'; ctx.fillRect(9, 15, 12, 8);
  ctx.fillStyle = '#1b1f31'; ctx.fillRect(7, 12, 3, 3); ctx.fillRect(21, 12, 3, 3);
  ctx.restore();
}

export function drawPortrait(npcId, x, y) {
  ctx.save(); ctx.translate(x, y);
  const p = PORTRAIT_PALETTES[npcId] || PORTRAIT_PALETTES.tram;
  ctx.scale(2, 2);
  ctx.fillStyle = p.base; ctx.fillRect(2, 2, 28, 28);
  ctx.fillStyle = p.shadow;
  ctx.fillRect(2, 2, 2, 28); ctx.fillRect(2, 28, 28, 2); ctx.fillRect(28, 2, 2, 28);
  ctx.fillStyle = p.face; ctx.fillRect(8, 8, 16, 16);
  if (npcId !== 'pig') { ctx.fillStyle = p.hair || '#33415f'; ctx.fillRect(8, 6, 16, 4); }
  ctx.fillStyle = p.eyes;
  if (npcId === 'rak') { ctx.fillRect(10, 10, 4, 3); ctx.fillRect(18, 10, 4, 3); }
  else { ctx.fillRect(11, 10, 3, 3); ctx.fillRect(18, 10, 3, 3); }
  // Character-specific
  if (npcId === 'pig') { ctx.fillStyle = p.snout; ctx.fillRect(12, 18, 8, 4); ctx.fillStyle = p.eyes; ctx.fillRect(13, 19, 2, 2); ctx.fillRect(17, 19, 2, 2); }
  else if (npcId === 'muras') { ctx.fillStyle = p.glasses; ctx.fillRect(14, 12, 4, 1); ctx.fillStyle = p.hair; ctx.fillRect(10, 9, 5, 1); ctx.fillRect(17, 9, 5, 1); }
  else if (npcId === 'rak') { ctx.fillStyle = p.hair; ctx.fillRect(9, 8, 6, 2); ctx.fillRect(17, 8, 6, 2); }
  else if (npcId === 'wymysl') { ctx.fillStyle = p.mouth; ctx.fillRect(13, 20, 6, 2); ctx.fillStyle = p.hair; ctx.fillRect(10, 9, 5, 1); ctx.fillRect(17, 9, 5, 1); }
  else if (npcId === 'clerk') { ctx.fillStyle = '#1b1f31'; ctx.fillRect(13, 20, 6, 1); ctx.fillStyle = p.shadow; ctx.fillRect(8, 6, 16, 2); }
  else if (npcId === 'nowak') { ctx.fillStyle = p.scarf; ctx.fillRect(8, 6, 16, 4); ctx.fillStyle = p.hair; ctx.fillRect(10, 9, 5, 1); ctx.fillRect(17, 9, 5, 1); if (state.quests.nowakCase) { ctx.fillStyle = '#1b1f31'; ctx.fillRect(13, 20, 6, 1); } }
  else { ctx.fillStyle = (p.smile || '#d7a84f'); ctx.fillRect(13, 20, 6, 2); }
  ctx.restore();
}

// === Text rendering ===
export function writeWrapped(text, x, y, maxWidth, lineHeight, color, maxLines = 99) {
  ctx.fillStyle = color; ctx.font = `${lineHeight - 6}px monospace`;
  const words = String(text).split(' '); let line = ''; let lines = 0;
  for (const w of words) {
    const test = line + w + ' ';
    if (ctx.measureText(test).width > maxWidth) {
      if (lines >= maxLines - 1) {
        while (ctx.measureText(line + '…').width > maxWidth && line.length > 3) line = line.slice(0, -2);
        ctx.fillText(line.trim() + '…', x, y); return y + lineHeight;
      }
      ctx.fillText(line, x, y); lines++; line = w + ' '; y += lineHeight;
    } else line = test;
  }
  if (line) { ctx.fillText(line, x, y); y += lineHeight; }
  return y;
}

export function pixelText(txt, x, y, size, fill, shadow) {
  ctx.font = `900 ${size}px monospace`; ctx.textAlign = 'center';
  ctx.fillStyle = shadow; ctx.fillText(txt, x + 4, y + 4);
  ctx.fillStyle = fill; ctx.fillText(txt, x, y);
}

export function box(x, y, w, h) {
  ctx.fillStyle = '#f5ead2'; ctx.fillRect(x, y, w, h);
  ctx.strokeStyle = '#1b1f31'; ctx.lineWidth = 4; ctx.strokeRect(x, y, w, h);
  ctx.strokeStyle = '#d7a84f'; ctx.lineWidth = 2; ctx.strokeRect(x + 7, y + 7, w - 14, h - 14);
}

// === Background ===
export function drawBackground(currentArea, frame) {
  const g = ctx.createLinearGradient(0, 0, 0, H);
  if (currentArea && currentArea !== 'outside') {
    g.addColorStop(0, '#2a2130'); g.addColorStop(1, '#171827');
  } else {
    g.addColorStop(0, '#222943'); g.addColorStop(1, '#1a2134');
  }
  ctx.fillStyle = g; ctx.fillRect(0, 0, W, H);
  ctx.globalAlpha = currentArea === 'outside' ? .25 : .10;
  drawPixelWarsawSkyline(frame);
  ctx.globalAlpha = 1;
}

export function drawPixelWarsawSkyline(frame) {
  ctx.fillStyle = '#0e1120'; ctx.fillRect(0, 360, W, 280);
  const b = [60, 90, 50, 130, 70, 105, 44, 160, 70, 88, 55, 118, 40]; let x = 35;
  b.forEach((h, i) => {
    ctx.fillRect(x, 360 - h, 50, h);
    for (let yy = 360 - h + 14; yy < 348; yy += 18) {
      for (let xx = x + 8; xx < x + 44; xx += 16) {
        ctx.fillStyle = (i + yy + frame) % 3 ? '#242b45' : '#d7a84f';
        ctx.fillRect(xx, yy, 6, 8);
      }
    }
    ctx.fillStyle = '#0e1120'; x += 62;
  });
  ctx.fillStyle = '#0e1120';
  ctx.fillRect(730, 170, 56, 190); ctx.fillRect(748, 122, 20, 50); ctx.fillRect(755, 92, 6, 36);
}

// === Transition effect ===
export function drawTransition(alpha) {
  ctx.fillStyle = `rgba(11, 13, 22, ${alpha})`;
  ctx.fillRect(0, 0, W, H);
}
