// === Random Office Incidents ===
import { state } from '../state.js';

export const incidents = [
  { id: 'printer_jam', name: 'Printer Jam!', prompt: 'The office printer is jammed again. Papers are everywhere. Mr. Pig whispers: not the toner budget.',
    options: [
      { text: 'Open and unjam it fast, accepting personal paper cuts.', effectId: 'printer_quick' },
      { text: 'Ask Rak to diagnose it like a crime scene.', effectId: 'printer_strategic' }
    ] },
  { id: 'invoice_crisis', name: 'Invoice Crisis!', prompt: 'A client sent an invoice with a glaring error. Mr. Pig is already breathing into a file folder.',
    options: [
      { text: 'Hide it and fix quietly before panic becomes billable.', effectId: 'invoice_sneaky' },
      { text: 'Tell Muraś immediately and create a proper paper trail.', effectId: 'invoice_honest' }
    ] },
  { id: 'deadline_surprise', name: 'Deadline Surprise!', prompt: 'A deadline appears from behind a stack of binders. The court clerk is waiting.',
    options: [
      { text: 'Rush to court with heroic but suspicious speed.', effectId: 'deadline_panic' },
      { text: 'Call Wymysl for a procedural theory before running.', effectId: 'deadline_strategic' }
    ] },
  { id: 'client_call', name: 'Client Call!', prompt: 'A client asks whether human rights can also fix a broken radiator.',
    options: [
      { text: 'Give practical lease-law advice first.', effectId: 'client_practical' },
      { text: 'Give a beautiful abstract lecture on dignity.', effectId: 'client_abstract' }
    ] },
  { id: 'coffee_shortage', name: 'Coffee Shortage!', prompt: 'The coffee tin is empty. The firm briefly considers filing for interim measures.',
    options: [
      { text: 'Brew the mysterious emergency beans.', effectId: 'coffee_emergency' },
      { text: 'Save the beans for trial prep and drink water like an adult.', effectId: 'coffee_adult' }
    ] },
  { id: 'swine_postcard', name: 'Postcard from Japan!', prompt: 'Mr. Swine sends a ski photo captioned: comparative powder conditions excellent.',
    options: [
      { text: 'Frame it as morale support.', effectId: 'postcard_morale' },
      { text: 'Calculate the exchange rate damage.', effectId: 'postcard_budget' }
    ] },
];

export const incidentEffects = {
  printer_quick()  { state.stress += 1; return 'You unjammed it. Papers scattered. Mr. Pig is relieved, but your stress increased.'; },
  printer_strategic() {
    if (state.quests.friends) { state.stress = Math.max(0, state.stress - 2); return 'Rak fixed it with surgical precision. Stress reduced!'; }
    else { state.stress += 2; return 'Rak is not around. You struggled and made it worse.'; }
  },
  invoice_sneaky() { state.stress += 1; return 'You hid it and fixed the error. Mr. Pig never knew... but your conscience weighs heavy.'; },
  invoice_honest() {
    if (state.quests.guide) { state.reputation += 1; return 'Muraś helped you fix it properly. Mr. Pig was impressed by your honesty!'; }
    else { state.stress += 1; return 'Muraś is not around. You told Mr. Pig and he panicked even more.'; }
  },
  deadline_panic()    { state.stress += 2; return 'You rushed to court. The clerk was annoyed but accepted the filing. Stress increased!'; },
  deadline_strategic() {
    if (state.quests.rights) { state.reputation += 1; return 'Wymysl reminded you of a loophole. You filed an extension! Brilliant!'; }
    else { state.stress += 1; return 'Wymysl is not around. You panicked and filed late. Mr. Pig is disappointed.'; }
  },
  client_practical()  { state.reputation += 1; return 'You explain lease obligations, repairs, and Article 8 without promising radiator miracles. Sensible.'; },
  client_abstract()   { state.stress += 1; return 'The dignity lecture is moving. The radiator remains cold. Mr. Pig asks if it is billable.'; },
  coffee_emergency()  { state.coffee += 1; state.stress = Math.max(0, state.stress - 1); return 'Emergency beans deployed. Everyone moves slightly faster and trusts the legal system slightly less.'; },
  coffee_adult()      { state.reputation += 1; return 'You choose water. Muraś marks this as evidence of maturity, possibly admissible.'; },
  postcard_morale()   { state.reputation += 1; return 'The postcard becomes morale support. Mr. Pig cries, but only administratively.'; },
  postcard_budget()   { state.stress += 1; state.gold = Math.max(0, state.gold - 1); return 'The exchange rate calculation hurts. Firm Liquidity loses zł 1 to emotional accounting.'; },
};

export function checkForRandomIncident(flashDialog) {
  if (state.activeDialog || state.choiceMenu) return;
  if (state.incidentCooldown > 0) { state.incidentCooldown--; return; }
  if (Math.random() < 0.03) {
    let pool = incidents.filter(i => i.id !== state.lastIncidentId);
    if (pool.length === 0) pool = incidents;
    const incident = pool[Math.floor(Math.random() * pool.length)];
    state.lastIncidentId = incident.id;
    state.incidentCooldown = 18;
    state.incidentHistory.push(incident.id);
    if (state.incidentHistory.length > 8) state.incidentHistory.shift();
    state.choiceMenu = { title: incident.name, prompt: incident.prompt, options: incident.options };
  }
}
