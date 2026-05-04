// === Dialogue Data ===
// All NPC dialogue text — static topics, quest-gated topics, NPC lines.
import { state } from '../state.js';

// Static dialogue topics (Ask about Mr. Swine / printer / coffee)
export const dialogTopics = {
  pig: [
    { label: 'Ask about Mr. Swine', text: 'Mr. Swine sends expenses from Japan faster than postcards. Last invoice: heated ski boots, comparative-law volume not included.' },
    { label: 'Ask about the printer', text: 'The printer is sentient and malevolent. It senses important deadlines and chooses that moment to jam catastrophically. I have considered legal action against it.' },
    { label: 'Ask about coffee', text: 'The firm runs on coffee, optimism, and one very important binder. Mostly coffee.' },
  ],
  muras: [
    { label: 'Ask about Mr. Swine', text: 'Mr. Swine? Excellent skier, questionable partner. He faxes strategy from Japan. The fax number is correct. The strategy is debatable.' },
    { label: 'Ask about the printer', text: 'The printer is on a performance-improvement plan. It was written up after the incident with the court brief. I filed the paperwork. In triplicate. The printer ate one copy.' },
    { label: 'Ask about coffee', text: 'Coffee is filed under essential supplies, subsection: litigation fuel. I track consumption. It is not reassuring.' },
  ],
  rak: [
    { label: 'Ask about Mr. Swine', text: 'Swine in Japan. Classic avoidance strategy. I have spotted seventeen inconsistencies in his expense reports. Classic Pig & Swine.' },
    { label: 'Ask about the printer', text: 'I examined the printer. The jam was not accidental. There are tooth marks on the brief. The printer has motive and opportunity.' },
    { label: 'Ask about coffee', text: 'Coffee and evidence go together. One sharpens the mind. The other is admissible. Both are essential.' },
  ],
  wymysl: [
    { label: 'Ask about Mr. Swine', text: 'Swine in Japan is actually a strategic masterstroke. Remote jurisdiction, sympathetic postcards, human interest angle. Chaotic but clever.' },
    { label: 'Ask about the printer', text: 'Theory: the printer is a neutral third party with standing to obstruct proceedings. My legal theory holds. The paper does not.' },
    { label: 'Ask about coffee', text: 'Coffee is chaos, but useful chaos. Like my legal strategies: unpredictable, caffeinated, occasionally brilliant.' },
  ],
  clerk: [
    { label: 'Ask about Mr. Swine', text: 'The court has no record of Mr. Swine filing anything recently. The court does have a postcard he sent from Japan. Inadmissible but charming.' },
    { label: 'Ask about the printer', text: 'Court printers are government issue. They jam precisely once per important filing. This is documented. I have the stamp.' },
    { label: 'Ask about coffee', text: 'No outside beverages in the court corridor. This rule is posted, ignored, and enforced selectively.' },
  ],
  tram: [
    { label: 'Ask about Mr. Swine', text: 'Ding ding. I have carried a lawyer named Swine once. He got off at the wrong stop. Called it a shortcut. It was not.' },
    { label: 'Ask about the printer', text: 'Ding ding. Warsaw trams do not jam. Warsaw printers always do. This is the difference between public infrastructure and private suffering.' },
    { label: 'Ask about coffee', text: 'Ding ding. The best coffee stop is three stops past the courthouse. You will be late but caffeinated. Choose wisely.' },
  ],
  archivist: [
    { label: 'Ask about Mr. Swine', text: 'Shh. Mr. Swine donated seventeen boxes of unsorted files and one pair of ski goggles. The goggles are misfiled under Evidence. They stay.' },
    { label: 'Ask about the printer', text: 'Shh. The archive uses a hand-stamp and carbon paper. The printer is not welcome here. The archive has standards.' },
    { label: 'Ask about coffee', text: 'Shh. No beverages near the case files. I will look the other way for one small cup. Do not spill on the precedents.' },
  ],
  judge: [
    { label: 'Ask about Mr. Swine', text: 'The court has observed the absence of Mr. Swine. The court has noted it. The court does not ski and considers this morally relevant.' },
    { label: 'Ask about the printer', text: 'Order! The court transcript is typed by hand. Correctly. In triplicate. The printer is below the dignity of these proceedings.' },
    { label: 'Ask about coffee', text: 'The court takes a recess at eleven. The court does not comment on what occurs during recess. Order.' },
  ],
  barista: [
    { label: 'Ask about Mr. Swine', text: 'A Swine? Yes, tall lawyer, ordered the most expensive thing, asked if we had a receipt for his partner\'s expense report. We did not.' },
    { label: 'Ask about the printer', text: 'My espresso machine never jams. It is Italian. The printer is envious. I have seen them side by side. The tension is real.' },
    { label: 'Ask about coffee', text: 'Today\'s special: Procedural Anxiety Reduction Blend. Strong, dark, slightly bitter — like Warsaw court proceedings, but warmer.' },
  ],
  nowak: [
    { label: 'Ask about Mr. Swine', text: 'Mr. Swine? I read a profile. Very distinguished. Is he really skiing in Japan during my eviction case? That seems like a lot.' },
    { label: 'Ask about the printer', text: 'The landlord sent the eviction notice by fax. It jammed twice. I considered this a sign. My lawyer disagreed. You are my lawyer.' },
    { label: 'Ask about coffee', text: 'I have been so stressed I forgot to buy coffee. The human rights poster keeps me going. And possibly you.' },
  ],
};

// Quest-gated case topic
export function getCaseTopic(npcId) {
  const q = state.quests;
  if (q.nowakCase && q.court) return { label: 'Ask about the case', text: 'All is well — all quiet on the legal front. For now. Enjoy the toner while it lasts.' };

  if (q.nowakCase) {
    const map = {
      rak: 'Nowak case: I spotted three things. The lease agreement in the office — column four, subsection two. The human rights poster in the cafe. And a missing annex from the landlord notice. Classic.',
      wymysl: 'Eviction defense theory: Article 2 of Protocol 1 — right to housing as a human right. Chaotic but clever. Pair it with the lease agreement and the notice. Chaos to case.',
      muras: 'Nowak needs three things: the lease agreement, the human rights poster, and the landlord notice. I have a checklist. The checklist is laminated.',
      pig: 'Ms. Nowak is counting on us. Firm Liquidity is dangerously low. Win this case and we can afford toner — and possibly a second stapler.',
    };
    return { label: 'Ask about the case', text: map[npcId] || 'Nowak eviction case is live. Find the evidence, consult Rak and Wymysl, then argue in court. Deadlines do not ski in Japan.' };
  }

  if (q.rights && !q.court) {
    const map = {
      rak: 'You have the binder and the memo. The argument is: defective service → right to fair hearing. Present that in court. Sharp, precise, admissible.',
      wymysl: 'Court time: Article 2 of Protocol 1, fair hearing angle, human rights hook. The human rights memo is your ace. Play it.',
      pig: 'Court is ready. Firm Liquidity is dangerously low — we need this win. Go argue. Mr. Swine faxed his moral support from a ski lift.',
    };
    return { label: 'Ask about the case', text: map[npcId] || 'You are ready for court. Binder and memo collected. Head to the Court Hall.' };
  }

  if (q.law && !q.rights) {
    const map = {
      muras: 'Good — you have the binder. Now find the human rights memo. It was last seen near the archive. The archivist may know. Or may not.',
      rak: 'Binder: heavy. Contents: useful. Next: find the human rights memo — it has the fair trial argument. Check the archive.',
    };
    return { label: 'Ask about the case', text: map[npcId] || 'Polish law binder collected. Now find the human rights memo to complete your legal toolkit.' };
  }

  if (q.friends && !q.law) {
    const map = {
      muras: 'Find the Polish law binder. It is in the office — somewhere near the desk. I filed a memo about it. The memo is also missing.',
      pig: 'Firm Liquidity is dangerously low. The printer has been making threats. Find that law binder and move this case forward, please.',
    };
    return { label: 'Ask about the case', text: map[npcId] || 'Next step: find the Polish law binder in the office. It has everything you need — civil procedure, constitutional principles, twelve colored tabs.' };
  }

  if (q.guide && !q.friends) {
    return { label: 'Ask about the case', text: 'Talk to Rak and Wymysl — they are your key allies. Rak finds the facts. Wymysl builds the argument. You are the third leg of this legal stool.' };
  }

  return { label: 'Ask about the case', text: 'You are new. Find Muraś first — the guide who knows how Pig & Swine actually works. Ask about everything. Especially the printer.' };
}

export function getContextualTopics(npcId) {
  const base = (dialogTopics[npcId] || dialogTopics.pig).filter(t => !t.close);
  const caseTopic = getCaseTopic(npcId);
  return [...base, caseTopic, { label: '[Close]', close: true }];
}

// NPC line generators (quest-state-sensitive)
export function getNpcLines(npcId) {
  const q = state.quests;
  switch (npcId) {
    case 'pig':
      if (q.court) return ['Dr. A. Kula! Day One complete. Pig & Swine survives. Mr. Swine is still skiing.', 'The toner budget is safe. Justice, it seems, is billable.', 'We can buy toner for the printer now! It was plotting against us.', 'The firm survives another day. Rent invoice still pending, but we have toner.'];
      if (q.rights) return ['You have the rights memo. Now go to court — defective service awaits.', 'Remember: fair hearing, proportionality, and Mr. Swine is still in Japan.'];
      if (q.law) return ['You found the binder. Heavy, isnt it? Polish law always is.', 'Now find the human rights memo near the court. Dignity is just a filing away.'];
      if (q.friends) return ['Rak and Wymysl are with you. Good. The firm needs a legal strike team.', 'Now find the Polish law binder in the office.'];
      if (q.guide) return ['Muraś found. Good. He will guide you through Pig & Swine.', 'Find Rak and Wymysl next. They are your real friends.'];
      return ['Dr. A. Kula, welcome to Pig & Swine.', 'Our financial situation is very difficult. The firm is held together by coffee, unpaid invoices, and procedural optimism.', 'Mr. Swine is skiing in Japan, so you must help us survive Warsaw courts, Polish law, and human rights cases.', 'Find Muraś. He will guide you through the firm.'];
    case 'muras':
      if (q.court) return ['Day One complete. The firm survives. Mr. Swine still skis.', 'Rest. Tomorrow brings new deadlines, new archives, new anxieties.', 'I have the court transcript. It\'s 40 pages. I\'ll summarize: you were great.', 'The archive is organized. For now.'];
      if (q.rights && !q.court) return ['You have the rights memo! Now go to court — the Clerk awaits Dr. A. Kula.', 'Defective service, fair hearing, proportionality. You have all the pieces.'];
      if (q.law && !q.rights) return ['Excellent. The Polish law binder is heavy because justice requires gravity.', 'Now find the human rights memo near the court building. It explains dignity and proportionality.'];
      if (q.friends && !q.law) return ['Good. Rak and Wymysl are with you. The firm now has a legal strike team.', 'Next: collect the Polish law binder from the office. It explains why every simple matter has seven attachments.'];
      if (q.guide && !q.friends) return ['You found me. Now find Rak and Wymysl near the cafe.', 'They are your real friends — they will help with courts, Polish law, and human rights.'];
      return ['I am Muraś, your guide in Pig & Swine.', 'First rule: never enter the archive without a quest. Second rule: always know who your real friends are.', 'Find me near reception. If lost, follow the smell of binders.'];
    case 'rak':
      if (q.court) return ['Rak reporting. Day One complete. The archive grows, the deadlines multiply.', 'See you tomorrow, Dr. A. Kula. Bring coffee.', 'Evidence from the case is filed. Also, your coffee mug is chipped.', 'I spotted three missing annexes already. Classic Pig & Swine.'];
      if (q.nowakCase) return ['Nowak case: eviction notice, lease agreement, human rights poster.', 'I spotted the missing annex on the landlord notice. Classic Pig & Swine.', 'Evidence checklist: lease agreement (office), human rights poster (cafe), landlord notice (Nowak).', 'My sharp eyes see all. Also, your coffee is cold.'];
      if (q.rights) return ['You have the memo! Now for court — defective service awaits.', 'I have spotted three missing annexes already. Classic Pig & Swine.'];
      if (q.law) return ['Binder acquired. My sharp eyes approve.', 'Now find the human rights memo near the court. Dignity needs evidence.'];
      if (q.friends) return ['Rak reporting for duty. I can spot a missing annex from across Warsaw.', 'eyes sharp, evidence and coffee ready.'];
      return ['Dr. A. Kula! We heard Pig & Swine is in trouble.', 'Wymysl and I are your real friends. We will help you sort facts from office folklore.'];
    case 'wymysl':
      if (q.nowakCase) return ['Nowak case: eviction defense. Polish lease law + human rights defense.', 'Article 2 of Protocol 1: right to peaceful enjoyment of possessions.', 'My chaotic but clever strategy: combine lease law with human rights memo.', 'Wymysl here. Theory brewing for Nowak\'s case.'];
      if (q.court) return ['Wymysl here. Day One done. Strategy proved correct.', 'Tomorrow: new cases, new chaos, same Swine in Japan.', 'The legal theory holds. Next time, we\'ll add a human rights glitter bomb.', 'Chaos to case, completed.'];
      if (q.rights) return ['Memo secured! The court will not know what hit it.', 'Strategy: defective service + human rights = victory.'];
      if (q.law) return ['Binder found. Good. Now the human rights memo — near the court building.', 'Strategy: read the law, protect rights, avoid printer jams.'];
      if (q.friends) return ['Wymysl here. Strategy: read the law, protect human rights, avoid printer jams.', 'theory brewing. Chaos to case in three steps.'];
      return ['A difficult financial situation? Classic Pig & Swine.', 'Gather Rak, me, and the binder. Then we go from chaos to case theory.'];
    case 'clerk':
      if (q.court) return ['The court quest is complete. Pig & Swine survives another docket.', 'The court record is closed. Don\'t lose the stamped copy. Again.', 'Case filed. Justice served. For now.'];
      if (q.law && q.rights) return ['You have the binder, the rights memo, and a calm face. The court is ready for Dr. A. Kula.'];
      return ['Court corridor rule: bring the right binder, the rights memo, and a calm face.', 'If you understand Polish law and human rights, the hearing may actually go well.'];
    case 'tram':
      return ['Ding ding. Warsaw wisdom: courts are near, deadlines are nearer.', 'Mr. Swine sends a postcard from Japan: "excellent powder, terrifying exchange rate."'];
    case 'archivist':
      if (q.archive) return ['The Archive is organized. For now. Come back if you need more ancient case files.'];
      return ['Shh! This is The Archive. Ancient case files, dusty precedents, and Mr. Swine\'s old ski photos.', 'Find the Ancient Case Files hidden behind the shelves. They contain powerful legal arguments.'];
    case 'judge':
      if (q.court) return ['Court is adjourned. Pig & Swine survives. For now.'];
      return ['Order! The court expects proper filings, Polish law knowledge, and human rights awareness.', 'Dr. A. Kula, bring your binder and memo. Justice waits for no invoice.'];
    case 'barista':
      if (q.coffeeRun) return ['Specialty Coffee Beans activated! More coffee? Reduces anxiety like magic.'];
      if (state.coffee >= 3) return ['More coffee? You know it reduces Procedural Anxiety. Pig & Swine runs on caffeine.'];
      return ['Welcome to the Coffee Shop. We serve the best legal brew in Warsaw.', 'Drink coffee to reduce stress. Press B when near me to brew a cup!'];
    case 'nowak':
      if (q.nowakCase) return ['Thank you, Dr. A. Kula. The eviction notice is defeated. My home is safe.', 'Pig & Swine is a lifesaver. Mr. Swine would be proud — if he were not skiing in Japan.'];
      return ['Dr. A. Kula! I have an eviction notice. My landlord says I violated the lease, but I only hung a human rights poster!', 'Please help me. The court date is tomorrow. I need Polish law and human rights support.'];
    default:
      return ['...'];
  }
}
