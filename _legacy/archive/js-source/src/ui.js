// === UI Drawing ===
// All overlay and HUD rendering: docket, case bag, result screen, dialog, etc.
import { state, player, ui, BADGES } from './state.js';
import {
  iso, getCtx, getW, getH, box, writeWrapped, pixelText,
  drawBackground, drawPixelWarsawSkyline, drawPigSeal, drawPortrait,
  drawLawyerSprite, diamond, drawBlock, drawTile
} from './renderer.js';
import { getRevealedText, isTypewriterDone, updateTypewriter } from './typewriter.js';
import { nextQuest, questSteps, nowakQuestSteps, nowakEvidenceCount, docketNote, caseBagItems } from './systems/quests.js';
import { getContextualTopics } from './data/dialogues.js';
import { overworldTiles, MAP_W, MAP_H, blocked } from './data/maps.js';

// --- HUD ---
export function drawHUD() {
  const ctx = getCtx();
  ctx.fillStyle = 'rgba(11,13,22,.84)'; ctx.fillRect(18, 16, 390, 98);
  ctx.strokeStyle = '#d7a84f'; ctx.strokeRect(18, 16, 390, 98);
  ctx.font = '16px monospace'; ctx.textAlign = 'left'; ctx.fillStyle = '#f5ead2';
  ctx.fillText(`zł ${state.gold}   Reputation ${state.reputation}   Coffee ${state.coffee}`, 34, 43);
  ctx.fillStyle = '#8bb1e0'; ctx.fillText(`Area: ${state.currentArea === 'outside' ? 'Warsaw Streets' : state.currentArea}`, 34, 68);
  const q = nextQuest();
  ctx.fillStyle = '#ffd76c';
  writeWrapped(`Quest: ${q}`, 34, 92, 350, 18, '#ffd76c', 1);
}

// --- Mini Map ---
export function drawMiniMap() {
  const ctx = getCtx();
  const sx = 732, sy = 20, sc = 7;
  ctx.fillStyle = 'rgba(11,13,22,.86)'; ctx.fillRect(sx - 12, sy - 12, 154, 154);
  ctx.strokeStyle = '#ffd76c'; ctx.strokeRect(sx - 12, sy - 12, 154, 154);
  for (let y = 0; y < MAP_H; y++) {
    for (let x = 0; x < MAP_W; x++) {
      ctx.fillStyle = blocked(x, y, overworldTiles, MAP_W, MAP_H)
        ? '#303647'
        : overworldTiles[y][x] === 'street' ? '#78869b'
        : overworldTiles[y][x] === 'park' ? '#526f45'
        : '#b99562';
      ctx.fillRect(sx + x * sc, sy + y * sc, sc - 1, sc - 1);
    }
  }
  ctx.fillStyle = '#ffd76c';
  ctx.fillRect(sx + player.x * sc, sy + player.y * sc, sc, sc);
}

// --- Docket ---
export function drawDocket() {
  const ctx = getCtx();
  const W = getW(), H = getH();
  ctx.save();
  const dayTwo = state.quests.court;
  ctx.fillStyle = 'rgba(8,10,18,.72)'; ctx.fillRect(0, 0, W, H);
  box(160, 84, 640, 470);
  ctx.textAlign = 'left';
  ctx.fillStyle = '#1b1f31'; ctx.font = dayTwo ? '25px monospace' : '28px monospace';
  ctx.fillText(dayTwo ? 'DOCKET: Day Two — Nowak Eviction Defense' : 'DOCKET: Day One — The Financial Crisis', 195, 130);
  ctx.font = '16px monospace'; ctx.fillStyle = '#6d2f45'; ctx.fillText('Press Q to close · Pig & Swine internal case file', 195, 158);
  const steps = dayTwo ? nowakQuestSteps() : questSteps();
  let y = 190;
  if (dayTwo) {
    ctx.fillStyle = '#aa3d42'; ctx.font = '17px monospace';
    ctx.fillText(`Evidence checklist · Nowak evidence: ${nowakEvidenceCount()}/3`, 205, y);
    y += 34;
  }
  for (const step of steps) {
    const done = dayTwo ? step.done : state.quests[step.flag];
    const mark = done ? '✓' : '□';
    ctx.fillStyle = done ? '#526f45' : '#1b1f31';
    ctx.font = done ? '18px monospace' : '19px monospace';
    ctx.fillText(`${mark} ${step.text}`, 205, y);
    y += 34;
  }
  ctx.fillStyle = '#f1e2bf'; ctx.fillRect(195, 405, 570, 92);
  ctx.strokeStyle = '#d7a84f'; ctx.lineWidth = 2; ctx.strokeRect(195, 405, 570, 92);
  writeWrapped(docketNote(), 215, 435, 530, 23, '#1b1f31');
  ctx.fillStyle = '#6d2f45'; ctx.font = '15px monospace';
  ctx.fillText(`Firm Liquidity: zł ${state.gold}   Bar Reputation: ${state.reputation}`, 215, 520);
  ctx.restore();
}

// --- Case Bag ---
export function drawCaseBag() {
  const ctx = getCtx();
  const W = getW(), H = getH();
  ctx.save();
  ctx.fillStyle = 'rgba(8,10,18,.72)'; ctx.fillRect(0, 0, W, H);
  box(130, 40, 700, 580);
  ctx.textAlign = 'left';
  ctx.fillStyle = '#1b1f31'; ctx.font = '30px monospace'; ctx.fillText('CASE BAG', 175, 120);
  ctx.font = '16px monospace'; ctx.fillStyle = '#6d2f45'; ctx.fillText('Press I to close · Evidence, notes, and survival objects', 175, 150);
  ctx.fillStyle = '#f1e2bf'; ctx.fillRect(170, 178, 600, 66);
  ctx.strokeStyle = '#d7a84f'; ctx.lineWidth = 2; ctx.strokeRect(170, 178, 600, 66);
  ctx.fillStyle = '#1b1f31'; ctx.font = '16px monospace';
  ctx.fillText(`Firm Liquidity: zł ${state.gold}`, 195, 205);
  ctx.fillText(`Bar Reputation: ${state.reputation}`, 430, 205);
  ctx.fillText(`Procedural Anxiety: ${state.stress}`, 195, 230);
  ctx.fillText(`Coffee: ${state.coffee}`, 430, 230);
  // Draw badges
  ctx.fillStyle = '#1b1f31'; ctx.font = '18px monospace'; ctx.fillText('BADGES:', 175, 260);
  let bx = 175, by = 270;
  if (state.badges.length === 0) {
    ctx.fillStyle = '#7b7f8e'; ctx.font = '14px monospace'; ctx.fillText('No badges yet.', bx, by + 12);
  } else {
    state.badges.forEach((badge, i) => {
      ctx.fillStyle = badge.color;
      ctx.fillRect(bx + i * 52, by, 36, 30);
      ctx.fillStyle = '#1b1f31'; ctx.font = '9px monospace'; ctx.fillText(badge.name, bx + i * 52, by + 42);
    });
  }
  let y = 320;
  for (const item of caseBagItems()) {
    if (y > 540) break;
    ctx.fillStyle = item.owned ? '#526f45' : '#7b7f8e';
    ctx.font = '16px monospace'; ctx.fillText(`${item.owned ? '✓' : '□'} ${item.name}`, 175, y);
    ctx.fillStyle = '#1b1f31'; ctx.font = '13px monospace';
    writeWrapped(item.desc, 200, y + 18, 560, 16, item.owned ? '#1b1f31' : '#59617f', 1);
    y += 42;
  }
  ctx.fillStyle = '#aa3d42'; ctx.font = '13px monospace'; ctx.textAlign = 'left';
  ctx.fillText('Muraś: A good case bag has law, facts, and one snack nobody admits owning.', 175, 558);
  ctx.fillStyle = '#1b1f31'; ctx.font = '13px monospace'; ctx.textAlign = 'center';
  ctx.fillText('S: Save   L: Load   B: Music   Ctrl+M: Mute', W / 2, 575);
  ctx.restore();
}

// --- Dialog Box ---
export function drawDialog() {
  const ctx = getCtx();
  box(48, 438, 864, 174);
  ctx.fillStyle = '#1b1f31'; ctx.font = '18px monospace'; ctx.textAlign = 'left';
  const hasPortrait = !!state.activeDialog.npcId;
  const textX = hasPortrait ? 178 : 84;
  const maxWidth = hasPortrait ? 680 : 790;
  const nextX = hasPortrait ? 660 : 700;
  if (hasPortrait) {
    drawPortrait(state.activeDialog.npcId, 90, 480);
  }
  ctx.fillText(state.activeDialog.name, textX, 466);
  updateTypewriter();
  writeWrapped(getRevealedText(), textX, 494, maxWidth, 22, '#1b1f31', 4);
  ctx.fillStyle = '#aa3d42'; ctx.font = '16px monospace';
  ctx.fillText(isTypewriterDone() ? 'Space/Enter: next ▶' : '▼▼▼', nextX, 586);
}

// --- Dialog Topics ---
export function drawDialogTopics(activeTopicIdx, activeTopicResponse) {
  if (!state.activeDialog) return;
  const ctx = getCtx();
  const npcId = state.activeDialog.npcId || 'pig';
  const topics = getContextualTopics(npcId);
  const hasPortrait = !!state.activeDialog.npcId;
  ctx.save();
  // Response line shown above topics
  if (activeTopicResponse) {
    box(48, 360, 864, 80);
    ctx.fillStyle = '#1b1f31'; ctx.font = '15px monospace'; ctx.textAlign = 'left';
    ctx.fillText(state.activeDialog.name, hasPortrait ? 178 : 84, 386);
    writeWrapped(activeTopicResponse, hasPortrait ? 178 : 84, 406, 700, 20, '#1b1f31', 2);
    if (hasPortrait) drawPortrait(npcId, 90, 400);
  }
  // Topics box
  box(48, 438, 864, 174);
  ctx.fillStyle = '#1b1f31'; ctx.font = '15px monospace'; ctx.textAlign = 'left';
  if (hasPortrait) drawPortrait(npcId, 90, 480);
  const startX = hasPortrait ? 178 : 84;
  ctx.fillStyle = '#6d2f45'; ctx.fillText('What would you like to ask?', startX, 462);
  const topicY0 = 488;
  const topicH = 28;
  topics.forEach((t, i) => {
    const isSelected = i === activeTopicIdx;
    const y = topicY0 + i * topicH;
    if (isSelected) {
      ctx.fillStyle = '#d7a84f'; ctx.fillRect(startX - 4, y - 18, 720, topicH);
      ctx.fillStyle = '#1b1f31';
    } else {
      ctx.fillStyle = '#526f45';
    }
    ctx.font = isSelected ? '16px monospace' : '15px monospace';
    ctx.fillText((isSelected ? '▶ ' : '  ') + t.label, startX, y);
  });
  ctx.fillStyle = '#aa3d42'; ctx.font = '14px monospace';
  ctx.fillText('↑↓: choose  Space/Enter: ask', 660, 586);
  ctx.restore();
}

// --- Choice Menu ---
export function drawChoiceMenu() {
  const ctx = getCtx();
  const W = getW(), H = getH();
  const menu = state.choiceMenu;
  if (!menu) return;
  ctx.save();
  ctx.fillStyle = 'rgba(8,10,18,.70)'; ctx.fillRect(0, 0, W, H);
  box(70, 86, 820, 470);
  ctx.textAlign = 'left';
  ctx.fillStyle = '#1b1f31'; ctx.font = '23px monospace'; ctx.fillText(menu.title, 108, 126);
  ctx.font = '16px monospace'; writeWrapped(menu.prompt, 108, 158, 744, 20, '#1b1f31', 3);
  const optionH = menu.options.length > 3 ? 74 : 88;
  let y = 244;
  menu.options.forEach((opt, idx) => {
    ctx.fillStyle = idx % 2 === 0 ? '#f7eed8' : '#f1e2bf'; ctx.fillRect(108, y - 30, 744, optionH);
    ctx.strokeStyle = '#d7a84f'; ctx.lineWidth = 2; ctx.strokeRect(108, y - 30, 744, optionH);
    ctx.fillStyle = '#1b1f31'; ctx.font = '15px monospace';
    writeWrapped(`${idx + 1}. ${opt.text}`, 128, y - 12, 704, 17, '#1b1f31', 4);
    y += optionH + 12;
  });
  ctx.fillStyle = '#aa3d42'; ctx.font = '16px monospace';
  ctx.fillText(`Press 1-${menu.options.length}. No default answer — read the legal theory.`, 108, 530);
  ctx.restore();
}

// --- Result Screen ---
export function drawResultScreen(resultData, frame) {
  const ctx = getCtx();
  const W = getW(), H = getH();
  ctx.save();
  ctx.fillStyle = 'rgba(8,10,18,.82)'; ctx.fillRect(0, 0, W, H);
  box(120, 60, 720, 520);
  ctx.textAlign = 'center';
  const victory = resultData && resultData.victory;
  const isNowak = resultData && resultData.caseName === 'Nowak Eviction';
  ctx.fillStyle = victory ? '#526f45' : '#aa3d42';
  ctx.font = '900 36px monospace';
  ctx.fillText(victory ? `⚖️  ${isNowak ? 'NOWAK CASE RESULT' : 'CASE RESULT'}  ⚖️` : '⚖️  CASE DISMISSED  ⚖️', W / 2, 110);
  ctx.textAlign = 'left'; ctx.font = '20px monospace';
  ctx.fillStyle = '#1b1f31'; ctx.fillText('Argument Quality:', 175, 160);
  ctx.fillStyle = victory ? '#526f45' : '#aa3d42';
  ctx.fillText(victory ? 'Strong — legally grounded' : 'Weak — comedically grounded', 420, 160);
  ctx.fillStyle = '#1b1f31'; ctx.fillText('Human Rights Angle:', 175, 195);
  ctx.fillStyle = victory ? '#526f45' : '#7b7f8e';
  ctx.fillText(victory ? 'Persuasive — proportionality cited' : 'Absent — Mr. Swine cited instead', 420, 195);
  ctx.fillText('Defective Service:', 175, 230);
  ctx.fillStyle = victory ? '#526f45' : '#7b7f8e';
  ctx.fillText(victory ? 'Identified — fair hearing affected' : 'Ignored — emotional printers cited', 420, 230);
  ctx.fillStyle = '#f1e2bf'; ctx.fillRect(165, 260, 630, 100);
  ctx.strokeStyle = '#d7a84f'; ctx.lineWidth = 2; ctx.strokeRect(165, 260, 630, 100);
  ctx.font = '22px monospace'; ctx.textAlign = 'center';
  if (victory) {
    ctx.fillStyle = '#526f45'; ctx.fillText(`Firm Liquidity: +${isNowak ? '30' : '20'} zł`, W / 2 - 150, 300);
    ctx.fillText(`Bar Reputation: +${isNowak ? '5' : '3'}`, W / 2 + 150, 300);
    ctx.fillStyle = '#1b1f31'; ctx.fillText('Procedural Anxiety: 0', W / 2, 340);
  } else {
    ctx.fillStyle = '#aa3d42'; ctx.fillText('Firm Liquidity: +0 zł', W / 2 - 150, 300);
    ctx.fillText('Bar Reputation: +0', W / 2 + 150, 300);
    ctx.fillText(`Procedural Anxiety: +${isNowak ? '2' : '1'}`, W / 2, 340);
  }
  ctx.textAlign = 'left';
  ctx.fillStyle = '#f1e2bf'; ctx.fillRect(165, 385, 630, 110);
  ctx.strokeStyle = '#c96c78'; ctx.lineWidth = 2; ctx.strokeRect(165, 385, 630, 110);
  drawPigSeal(195, 420, 1.5);
  ctx.fillStyle = '#1b1f31'; ctx.font = '18px monospace'; ctx.fillText('Mr. Pig:', 248, 410);
  ctx.font = '17px monospace';
  if (victory) {
    writeWrapped(isNowak
      ? '"Excellent! Ms. Nowak keeps her home, and we keep a client. Mr. Swine would be proud — if he ever leaves the Japanese slopes."'
      : '"We may yet afford toner. Mr. Swine will receive a fax about this victory — if he ever leaves the slopes."', 248, 435, 520, 21, '#1b1f31');
  } else {
    writeWrapped('"That was not a legal argument. That was a holiday postcard. Try again before the court loses all patience."', 248, 435, 520, 21, '#aa3d42');
  }
  ctx.textAlign = 'center';
  ctx.fillStyle = Math.floor(frame / 20) % 2 ? '#aa3d42' : '#1b1f31';
  ctx.font = '18px monospace';
  ctx.fillText(victory ? (isNowak ? 'Press Space to continue — Ms. Nowak saved!' : 'Press Space to continue — Day One complete') : 'Press Space to try again', W / 2, 545);
  ctx.restore();
}

// --- Day Summary Screen ---
export function drawDaySummary(frame) {
  const ctx = getCtx();
  const W = getW(), H = getH();
  ctx.save();
  ctx.fillStyle = 'rgba(8,10,18,.92)'; ctx.fillRect(0, 0, W, H);
  ctx.globalAlpha = .15; drawPixelWarsawSkyline(frame); ctx.globalAlpha = 1;
  box(100, 40, 760, 560);
  ctx.textAlign = 'center';
  ctx.fillStyle = '#d7a84f'; ctx.font = '900 32px monospace';
  ctx.fillText('DAY ONE COMPLETE', W / 2, 88);
  ctx.fillStyle = '#aa3d42'; ctx.font = '22px monospace';
  ctx.fillText('Dr. A. Kula — Pig & Swine, Warsaw', W / 2, 120);
  ctx.textAlign = 'left';
  const lines = [
    'Dr. A. Kula arrived at Pig & Swine on the worst possible morning.',
    'Mr. Pig confirmed the financial crisis. Mr. Swine remained in Japan.',
    'Muraś guided the way. Rak and Wymysl proved their loyalty.',
    'A Polish law binder was found. A human rights memo was recovered.',
    'In court, Dr. A. Kula argued that defective service violated',
    'the right to a fair hearing — and the court agreed.',
    '',
    'Pig & Swine survives. For now.'
  ];
  let y = 165;
  for (const line of lines) {
    ctx.fillStyle = '#1b1f31';
    ctx.font = line.startsWith('Pig & Swine') ? '900 20px monospace' : '18px monospace';
    if (line !== '') ctx.fillText(line, 150, y);
    y += 28;
  }
  ctx.fillStyle = '#f1e2bf'; ctx.fillRect(145, 400, 670, 80);
  ctx.strokeStyle = '#d7a84f'; ctx.lineWidth = 2; ctx.strokeRect(145, 400, 670, 80);
  ctx.font = '20px monospace'; ctx.textAlign = 'center';
  ctx.fillStyle = '#526f45'; ctx.fillText(`Firm Liquidity: zł ${state.gold}`, W / 2 - 180, 435);
  ctx.fillText(`Bar Reputation: ${state.reputation}`, W / 2 + 180, 435);
  ctx.fillStyle = '#1b1f31'; ctx.fillText(`Quests Completed: ${Object.values(state.quests).filter(v => v).length}/6`, W / 2, 465);
  ctx.textAlign = 'left';
  ctx.fillStyle = '#aa3d42'; ctx.font = '17px monospace';
  writeWrapped('Muraś note: Day One is done. Tomorrow the deadlines return, the archive grows, and Mr. Swine will still be skiing. Rest while you can.', 150, 510, 660, 21, '#aa3d42');
  ctx.textAlign = 'center';
  ctx.fillStyle = Math.floor(frame / 22) % 2 ? '#d7a84f' : '#1b1f31';
  ctx.font = '18px monospace';
  ctx.fillText('Press Space to return to Warsaw', W / 2, 580);
  ctx.restore();
}

// --- Flash Message ---
export function drawFlashMessage() {
  if (!state.flashMessage || state.flashTimer <= 0) return;
  const ctx = getCtx();
  const W = getW();
  state.flashTimer--;
  ctx.save();
  ctx.fillStyle = 'rgba(82,111,69,.85)';
  ctx.fillRect(W / 2 - 100, 20, 200, 40);
  ctx.strokeStyle = '#d7a84f'; ctx.lineWidth = 2; ctx.strokeRect(W / 2 - 100, 20, 200, 40);
  ctx.fillStyle = '#f5ead2'; ctx.font = '18px monospace'; ctx.textAlign = 'center';
  ctx.fillText(state.flashMessage, W / 2, 46);
  ctx.restore();
}

// --- Title Screen ---
export function drawTitleScreen(frame) {
  const ctx = getCtx();
  const W = getW(), H = getH();
  ctx.fillStyle = '#151827'; ctx.fillRect(0, 0, W, H);
  drawPixelWarsawSkyline(frame);
  ctx.textAlign = 'center';
  pixelText('PIG & SWINE', W / 2, 132, 48, '#ffd76c', '#6d2f45');
  pixelText('DR. A. KULA IN WARSAW', W / 2, 190, 24, '#f5ead2', '#22263a');
  drawLawyerSprite(W / 2 - 24, 278, 3, '#33415f');
  drawPigSeal(W / 2 + 88, 318, 2);
  box(170, 410, 620, 136);
  writeWrapped('Dr. A. Kula begins at Pig & Swine: Mr. Pig warns of a very difficult financial situation while Mr. Swine skis in Japan. Find Rak, Wymysl, and Muraś to face courts, Polish law, and human rights.', 205, 438, 550, 21, '#1b1f31');
  ctx.fillStyle = Math.floor(frame / 25) % 2 ? '#aa3d42' : '#1b1f31';
  ctx.font = '20px monospace'; ctx.fillText('Press Space / Enter', W / 2, 580);
}

// --- Interact hint ---
export function drawInteractHint(npcs, items, interactables, frame) {
  const target = getNearbyInteractable(npcs, items, interactables);
  if (!target || state.activeDialog || state.mode === 'title') return;
  const ctx = getCtx();
  const p = iso(target.x + .5, target.y + .5, 58 + Math.sin(frame / 10) * 4);
  ctx.save();
  ctx.textAlign = 'center';
  ctx.fillStyle = 'rgba(11,13,22,.82)';
  const label = target.type === 'item' ? `Pick up ${target.item.label}` : target.type === 'interactable' ? `Use ${target.name}` : `Talk to ${target.name}`;
  const text = `${label} · Press Space`;
  ctx.font = '16px monospace';
  const width = Math.min(420, ctx.measureText(text).width + 26);
  ctx.fillRect(p.x - width / 2, p.y - 34, width, 28);
  ctx.strokeStyle = '#ffd76c'; ctx.lineWidth = 2; ctx.strokeRect(p.x - width / 2, p.y - 34, width, 28);
  ctx.fillStyle = '#ffd76c'; ctx.fillText(text, p.x, p.y - 14);
  ctx.fillStyle = '#f5ead2'; ctx.beginPath(); ctx.moveTo(p.x, p.y); ctx.lineTo(p.x - 8, p.y - 10); ctx.lineTo(p.x + 8, p.y - 10); ctx.closePath(); ctx.fill();
  ctx.restore();
}

export function getNearbyInteractable(npcs, items, interactables) {
  const { manhattan } = require_manhattan();
  for (const n of npcs) if (manhattan(player, n) <= 1) return { type: 'npc', name: n.name, x: n.x, y: n.y };
  for (const item of items) if (!item.taken && manhattan(player, item) <= 1) return { type: 'item', name: item.label, x: item.x, y: item.y, item };
  for (const inter of interactables) if (manhattan(player, inter) <= 1) return { type: 'interactable', name: inter.name, x: inter.x, y: inter.y, inter };
  return null;
}

// Avoid circular dep — just inline manhattan
function require_manhattan() {
  return { manhattan: (a, b) => Math.abs(a.x - b.x) + Math.abs(a.y - b.y) };
}
