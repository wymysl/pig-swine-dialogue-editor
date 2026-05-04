// === Coffee Mini-Game ===
// Brew coffee to reduce Procedural Anxiety.
import { state, ui } from '../state.js';
import { box, writeWrapped, getCtx, getW, getH } from '../renderer.js';

let coffeeMiniGame = null;
let canvasRef = null;
let _flashDialog = null;
let _saveGame = null;

export function getCoffeeMiniGame() { return coffeeMiniGame; }

export function initCoffeeCallbacks(flashDialog, saveGame) {
  _flashDialog = flashDialog;
  _saveGame = saveGame;
}

export function startCoffeeMiniGame(canvas) {
  canvasRef = canvas;
  coffeeMiniGame = { brewCount: 0, brewTimer: 300, active: true }; // 5s at 60fps
  // Add click handler for brew button
  canvas._coffeeClick = function(e) {
    if (!coffeeMiniGame || !coffeeMiniGame.active) {
      canvas.removeEventListener('click', canvas._coffeeClick);
      return;
    }
    const rect = canvas.getBoundingClientRect();
    const W = canvas.width;
    const x = (e.clientX - rect.left) * (canvas.width / rect.width);
    const y = (e.clientY - rect.top) * (canvas.height / rect.height);
    const btnX = W / 2 - 60, btnY = 300, btnW = 120, btnH = 50;
    if (x >= btnX && x <= btnX + btnW && y >= btnY && y <= btnY + btnH) {
      clickBrewButton();
    }
  };
  canvas.addEventListener('click', canvas._coffeeClick);
}

export function drawCoffeeMiniGame(frame) {
  if (!coffeeMiniGame || !coffeeMiniGame.active) return;
  const ctx = getCtx();
  const W = getW(), H = getH();
  ctx.save();
  ctx.fillStyle = 'rgba(8,10,18,.85)';
  ctx.fillRect(0, 0, W, H);
  box(200, 150, 560, 340);
  ctx.textAlign = 'center';
  ctx.fillStyle = '#1b1f31';
  ctx.font = '28px monospace';
  ctx.fillText('BREW COFFEE', W / 2, 200);
  ctx.font = '18px monospace';
  writeWrapped('Click the brew button 3 times within 5 seconds to brew coffee. Reduces Procedural Anxiety by 10.', 250, 230, 460, 22, '#1b1f31');
  // Brew button
  const btnX = W / 2 - 60, btnY = 300, btnW = 120, btnH = 50;
  ctx.fillStyle = Math.floor(frame / 10) % 2 ? '#d7a84f' : '#c96c78';
  ctx.fillRect(btnX, btnY, btnW, btnH);
  ctx.strokeStyle = '#ffd76c'; ctx.lineWidth = 2; ctx.strokeRect(btnX, btnY, btnW, btnH);
  ctx.fillStyle = '#1b1f31'; ctx.font = '20px monospace';
  ctx.fillText('BREW', W / 2, btnY + 32);
  // Progress
  ctx.fillStyle = '#526f45'; ctx.font = '18px monospace';
  ctx.fillText(`Brewed: ${coffeeMiniGame.brewCount}/3`, W / 2, 380);
  // Timer
  ctx.fillStyle = '#aa3d42';
  ctx.fillText(`Time left: ${Math.ceil(coffeeMiniGame.brewTimer / 60)}s`, W / 2, 410);
  // Update timer
  coffeeMiniGame.brewTimer--;
  if (coffeeMiniGame.brewTimer <= 0) resolveCoffeeMiniGame(false);
  ctx.restore();
}

export function resolveCoffeeMiniGame(success, flashDialog, saveGame) {
  if (!coffeeMiniGame) return;
  coffeeMiniGame.active = false;
  const fd = flashDialog || _flashDialog;
  const sg = saveGame || _saveGame;
  if (success) {
    state.stress = Math.max(0, state.stress - 10);
    state.coffee++;
    state.reputation++;
    if (fd) fd('Coffee brewed! Procedural Anxiety reduced by 10. Mr. Pig would be proud — if he weren\'t busy panicking about rent.');
    if (sg) sg();
  } else {
    if (fd) fd('Coffee spilled! The machine hisses. Mr. Pig shouts: "That was our last filter!"');
  }
  coffeeMiniGame = null;
  if (canvasRef && canvasRef._coffeeClick) {
    canvasRef.removeEventListener('click', canvasRef._coffeeClick);
  }
}

function clickBrewButton() {
  if (!coffeeMiniGame || !coffeeMiniGame.active) return;
  coffeeMiniGame.brewCount++;
  if (coffeeMiniGame.brewCount >= 3) resolveCoffeeMiniGame(true);
}
