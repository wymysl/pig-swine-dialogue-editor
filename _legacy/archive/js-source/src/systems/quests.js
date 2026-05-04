// === Quest System ===
// Quest logic, court puzzles, badge awards, item pickup.
import { state, player, BADGES } from '../state.js';
import { playSound } from '../audio.js';
import { triggerShake } from '../renderer.js';

// --- Badge system ---
export function awardBadge(questId, saveGame) {
  const badge = BADGES.find(b => b.id === questId);
  if (badge && !state.badges.some(b => b.id === questId)) {
    state.badges.push({ ...badge });
    state.flashMessage = `Badge earned: ${badge.name}!`;
    state.flashTimer = 120;
    playSound('badge');
    triggerShake(10, 4);
    if (saveGame) saveGame();
  }
}

// --- Quest step helpers ---
export function nextQuest() {
  if (!state.quests.orientation) return 'Speak with Mr. Pig about the financial crisis';
  if (!state.quests.guide) return 'Find Muraś, your guide through Pig & Swine';
  if (!state.quests.friends) return 'Find Rak and Wymysl, your real friends';
  if (!state.quests.law) return 'Collect the Polish law binder';
  if (!state.quests.rights) return 'Recover the human rights memo';
  if (!state.quests.court) return 'Go to court and save Pig & Swine';
  if (!state.quests.nowakCase) return 'Day Two: Help Ms. Nowak with eviction notice';
  return 'Day Two: Defend human rights in Warsaw courts';
}

export function questSteps() {
  return [
    { flag:'orientation', text:'Speak with Mr. Pig about the firm\u2019s financial crisis' },
    { flag:'guide', text:'Find Muraś, your guide through Pig & Swine' },
    { flag:'friends', text:'Find Rak and Wymysl, Dr. A. Kula\u2019s real friends' },
    { flag:'law', text:'Collect the Polish law binder' },
    { flag:'rights', text:'Recover the human rights memo' },
    { flag:'court', text:'Go to court and save Pig & Swine' }
  ];
}

export function nowakQuestSteps() {
  return [
    { done: state.nowakEvidence.notice, text:'Landlord Notice (from Ms. Nowak)' },
    { done: state.nowakEvidence.lease, text:'Lease Agreement (office)' },
    { done: state.nowakEvidence.poster, text:'Human Rights Poster (cafe)' },
    { done: state.quests.nowakCase, text:'Argue housing, expression, and proportionality in court' }
  ];
}

export function nowakEvidenceCount() {
  return ['notice', 'lease', 'poster'].filter(k => state.nowakEvidence[k]).length;
}

export function docketNote() {
  if (state.quests.court && !state.quests.nowakCase) return `Muraś note: Evidence checklist first, heroics second. Nowak evidence: ${nowakEvidenceCount()}/3. Housing is a human right, but judges prefer exhibits.`;
  if (state.quests.nowakCase) return 'Muraś note: Ms. Nowak is safe. Pig & Swine may invoice justice gently.';
  if (!state.quests.orientation) return 'Muraś note: Start with Mr. Pig. Panic is not a procedural remedy.';
  if (!state.quests.guide) return 'Muraś note: I am near reception. If lost, follow the smell of binders.';
  if (!state.quests.friends) return 'Muraś note: Find your friends before the firm mistakes you for office furniture.';
  if (!state.quests.law) return 'Muraś note: The binder is heavy because Polish law contains gravity.';
  if (!state.quests.rights) return 'Muraś note: Human rights arguments work best when actually brought to court.';
  if (!state.quests.court) return 'Muraś note: You have law, rights, and friends. That is almost a litigation strategy.';
  return 'Muraś note: Pig & Swine survives. For now. Mr. Swine remains in Japan.';
}

// --- Court puzzles ---
export function startCourtArgumentChoice() {
  state.choiceMenu = {
    title: 'Court Argument — Urgent Filing',
    prompt: 'Court Clerk: Dr. A. Kula, why should the court accept this filing despite the procedural chaos?',
    options: [
      { correct:false, text:'Because Pig & Swine has a difficult financial situation and the printer suffered emotionally.' },
      { correct:false, text:'Because the filing deadline was unreasonable and courts should be more understanding of small firms.' },
      { correct:true, text:'Because defective service affected the right to a fair hearing, and the human rights memo supports proportionality.' },
      { correct:false, text:'Because Mr. Swine is skiing in Japan and cannot be expected to process defeat across time zones.' }
    ]
  };
}

export function resolveCourtChoice(index, saveGame, incidentEffects, flashDialog) {
  if (!state.choiceMenu) return;
  const opt = state.choiceMenu.options[index];
  state.choiceMenu = null;
  if (!opt) return;
  // Handle incident choices (have effectId)
  if (opt.effectId && incidentEffects[opt.effectId]) {
    const msg = incidentEffects[opt.effectId]();
    if (msg) flashDialog(msg);
    return { type: 'incident' };
  }
  // Handle court choices (have correct property)
  if (opt.correct) {
    state.quests.court = true;
    state.reputation += 3;
    state.gold += 20;
    awardBadge('court', saveGame);
    saveGame();
    return { type: 'court', victory: true };
  } else {
    state.stress += 1;
    return { type: 'court', victory: false };
  }
}

export function startNowakCourtChoice() {
  if (state.choiceMenu) return;
  playSound('docket');
  state.choiceMenu = {
    title: 'NOVAK EVICTION DEFENSE',
    prompt: 'Ms. Nowak faces eviction for hanging a human rights poster. Choose your legal argument:',
    options: [
      { text: 'The printer jammed and ate the lease agreement, so no eviction is valid', correct: false },
      { text: 'Human rights defense + Polish lease law: posters are protected expression under ECHR and Polish constitution', correct: true },
      { text: 'The landlord failed to provide proper notice under civil procedure, making the eviction procedurally void', correct: false },
      { text: 'Mr. Swine is skiing in Japan and sends his apologies (and a postcard)', correct: false }
    ]
  };
}

export function resolveNowakCourt(index, saveGame) {
  if (!state.choiceMenu) return;
  const opt = state.choiceMenu.options[index];
  state.choiceMenu = null;
  if (!opt) return;
  if (opt.correct) {
    state.quests.nowakCase = true;
    state.reputation += 5;
    state.gold += 30;
    awardBadge('nowakCase', saveGame);
    saveGame();
    return { victory: true, caseName: 'Nowak Eviction' };
  } else {
    state.stress += 2;
    return { victory: false, caseName: 'Nowak Eviction' };
  }
}

// --- Item pickup ---
export function takeItem(item, saveGame, flashDialog) {
  item.taken = true;
  if (item.id === 'lawBinder') {
    state.files++;
    state.quests.law = true;
    state.reputation++;
    awardBadge('law', saveGame);
    flashDialog('You found the Polish law binder: civil procedure, constitutional principles, and twelve colored tabs.');
    saveGame();
  }
  if (item.id === 'rightsMemo') {
    state.rightsMemo++;
    state.quests.rights = true;
    state.reputation++;
    awardBadge('rights', saveGame);
    flashDialog('Human rights memo recovered. Dr. A. Kula now has arguments about dignity, fair trial, and proportionality.');
    saveGame();
  }
  if (item.id === 'ancientCaseFiles') {
    state.quests.archive = true;
    state.reputation++;
    awardBadge('archive', saveGame);
    flashDialog('You found Ancient Case Files! They contain powerful legal arguments.');
    saveGame();
  }
  if (item.id === 'courtStamps') {
    state.quests.courtHall = true;
    state.reputation++;
    awardBadge('courtHall', saveGame);
    flashDialog('You found Court Stamps! The Judge will be impressed.');
    saveGame();
  }
  if (item.id === 'specialtyCoffee') {
    state.quests.coffeeRun = true;
    state.coffee += 3;
    awardBadge('coffeeRun', saveGame);
    flashDialog('You found Specialty Coffee Beans! +3 Coffee.');
    saveGame();
  }
  // Nowak evidence tracking
  if (item.id === 'leaseAgreement') {
    state.nowakEvidence.lease = true;
    flashDialog('Lease Agreement collected: 2-bedroom apartment, valid through 2025. Rent paid on time.');
    saveGame();
  }
  if (item.id === 'humanRightsPoster') {
    state.nowakEvidence.poster = true;
    flashDialog('Human Rights Poster: "Housing is a Human Right — ECHR Article 8". Perfect for apartment walls.');
    saveGame();
  }
  if (item.id === 'landlordNotice') {
    state.nowakEvidence.notice = true;
    flashDialog('Landlord Eviction Notice: "Lease violated due to unauthorized wall decorations (posters)".');
    saveGame();
  }
}

// --- Case bag items ---
export function caseBagItems() {
  return [
    { name:'Polish law binder', owned:state.quests.law, desc:'A sacred red binder. Heavy enough to support legal arguments and unstable furniture.' },
    { name:'human rights memo', owned:state.quests.rights, desc:'Notes on dignity, fair trial, proportionality, and why bureaucracy should fear Dr. A. Kula.' },
    { name:'Lease Agreement (office)', owned:state.nowakEvidence.lease, desc:'Ms. Nowak paid on time. Useful against creative landlord arithmetic.' },
    { name:'Human Rights Poster (cafe)', owned:state.nowakEvidence.poster, desc:'Housing is a human right — and apparently a wall decoration emergency.' },
    { name:'Landlord Notice (from Ms. Nowak)', owned:state.nowakEvidence.notice, desc:'The landlord called a poster a lease breach. Rak called it evidence.' },
    { name:'Coffee reserve', owned:state.coffee > 0, desc: state.coffee > 0 ? 'Procedural fuel. The true source of interim relief.' : 'Empty. Dangerous for both deadlines and morale.' },
    { name:'Mr. Swine postcard', owned:true, desc:'Greetings from Japan: excellent powder, alarming expenses, unclear comparative-law value.' }
  ];
}
