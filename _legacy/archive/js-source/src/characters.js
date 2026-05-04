import { PORTRAIT_PALETTES } from './data/characters.js';

/**
 * Renders a Tier 1 character portrait at 64x64.
 * @param {CanvasRenderingContext2D} ctx - The canvas rendering context.
 * @param {string} npcId - The character ID (kula, pig, swine, muras, rak, wymysl).
 * @param {number} x - X coordinate to draw.
 * @param {number} y - Y coordinate to draw.
 * @param {string} expression - One of 'neutral', 'agitated', 'deadpan', 'panic', 'sly'.
 */
export function drawPortraitV2(ctx, npcId, x, y, expression = 'neutral') {
  ctx.save();
  ctx.translate(x, y);

  const p = PORTRAIT_PALETTES[npcId] || PORTRAIT_PALETTES.pig;
  
  // Background block
  ctx.fillStyle = p.base;
  ctx.fillRect(0, 0, 64, 64);
  ctx.fillStyle = p.shadow;
  ctx.fillRect(0, 0, 4, 64);
  ctx.fillRect(0, 60, 64, 4);
  ctx.fillRect(60, 0, 4, 64);
  
  // Body
  ctx.fillStyle = p.suit || p.jacket || p.shadow;
  ctx.fillRect(12, 48, 40, 16);
  
  // Face
  ctx.fillStyle = p.face;
  ctx.fillRect(16, 16, 32, 32);

  // Base features
  let eyeY = 26;
  let eyeSize = 4;
  let mouthY = 40;
  let mouthW = 10;
  let mouthH = 2;
  
  let leftEyeY = eyeY;
  let rightEyeY = eyeY;
  let leftEyeH = eyeSize;
  let rightEyeH = eyeSize;
  let leftBrowRot = 0;
  let rightBrowRot = 0;
  let browY = eyeY - 4;
  let mouthOffsetX = 0;

  // Apply expressions
  if (expression === 'agitated') {
    leftBrowRot = 0.3;
    rightBrowRot = -0.3;
    browY += 2;
    mouthW = 12;
    mouthH = 6;
    mouthY -= 2;
  } else if (expression === 'deadpan') {
    leftEyeH = 2;
    rightEyeH = 2;
    leftEyeY += 1;
    rightEyeY += 1;
    mouthW = 14;
    mouthH = 2;
  } else if (expression === 'panic') {
    leftEyeH = 6;
    rightEyeH = 6;
    leftEyeY -= 1;
    rightEyeY -= 1;
    leftBrowRot = -0.3;
    rightBrowRot = 0.3;
    browY -= 2;
    mouthW = 6;
    mouthH = 8;
  } else if (expression === 'sly') {
    leftEyeH = 2;
    leftEyeY += 1;
    rightBrowRot = 0.2;
    mouthW = 10;
    mouthOffsetX = 4;
    mouthY -= 1;
  }

  // Hair / Pig Ears
  if (npcId === 'pig' || npcId === 'swine') {
    ctx.fillStyle = p.shadow;
    ctx.fillRect(12, 10, 10, 10);
    ctx.fillRect(42, 10, 10, 10);
  } else {
    ctx.fillStyle = p.hair || '#33415f';
    ctx.fillRect(14, 12, 36, 8); // top hair
    if (npcId === 'kula') {
      ctx.fillRect(14, 20, 6, 12); // side hair
      ctx.fillRect(44, 20, 6, 12);
    } else if (npcId === 'rak') {
      ctx.fillRect(16, 20, 4, 8); // sideburns
      ctx.fillRect(44, 20, 4, 8);
    }
  }

  // Brows
  ctx.fillStyle = (npcId === 'pig' || npcId === 'swine') ? p.shadow : (p.hair || '#1b1f31');
  ctx.save(); ctx.translate(22, browY); ctx.rotate(leftBrowRot); ctx.fillRect(-6, 0, 12, 2); ctx.restore();
  ctx.save(); ctx.translate(42, browY); ctx.rotate(rightBrowRot); ctx.fillRect(-6, 0, 12, 2); ctx.restore();

  // Eyes
  ctx.fillStyle = p.eyes;
  ctx.fillRect(20, leftEyeY, 4, leftEyeH);
  ctx.fillRect(40, rightEyeY, 4, rightEyeH);

  // Character specific
  if (npcId === 'pig' || npcId === 'swine') {
    ctx.fillStyle = p.snout;
    ctx.fillRect(22, 34, 20, 12);
    ctx.fillStyle = p.eyes; // Nostrils
    if (expression === 'panic') {
      ctx.fillRect(24, 38, 4, 6);
      ctx.fillRect(36, 38, 4, 6);
    } else {
      ctx.fillRect(26, 38, 4, 4);
      ctx.fillRect(34, 38, 4, 4);
    }
  } else {
    if (npcId === 'muras') {
      ctx.fillStyle = p.glasses;
      ctx.fillRect(16, leftEyeY - 2, 12, 2); ctx.fillRect(16, leftEyeY + 4, 12, 2);
      ctx.fillRect(16, leftEyeY - 2, 2, 8); ctx.fillRect(26, leftEyeY - 2, 2, 8);
      ctx.fillRect(36, rightEyeY - 2, 12, 2); ctx.fillRect(36, rightEyeY + 4, 12, 2);
      ctx.fillRect(36, rightEyeY - 2, 2, 8); ctx.fillRect(46, rightEyeY - 2, 2, 8);
      ctx.fillRect(28, eyeY + 2, 8, 2); // bridge
    }
    
    // Mouth
    ctx.fillStyle = p.mouth || '#aa3d42';
    if (expression === 'deadpan') ctx.fillStyle = p.eyes;
    ctx.fillRect(32 - mouthW/2 + mouthOffsetX, mouthY, mouthW, mouthH);
    
    if (npcId === 'wymysl') {
      ctx.fillStyle = p.hair;
      ctx.fillRect(28, mouthY + mouthH, 8, 4); // goatee
    }
  }

  ctx.restore();
}
