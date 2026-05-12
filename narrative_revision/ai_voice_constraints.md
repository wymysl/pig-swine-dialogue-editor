# AI voice constraints — phase 7 drafting reference

**Purpose:** prompt-engineering layer for AI drafting in phase 7. Quote the relevant section(s) into every drafting prompt before asking the model to produce dialogue. This document is shorter than the bibles deliberately — it's the working subset, optimized for prompt-context use.

**How to use:**
1. For any scene, quote the §"General AI tells" section + the relevant per-character section(s).
2. Add scene-specific instructions: which beat, what happens, what flags are set.
3. Ask for a draft.
4. Run the draft through §"Scrub list" (mechanical search-and-flag).
5. Hand to a second model for critique against this document.
6. Revise. Read aloud. Commit.

**Authority hierarchy:** style_canon.txt > bibles/*.md > this document. This is the *condensed* version. When in doubt, read the full bible.

---

## §1 — General AI tells (cross-character; scrub from every draft)

**Mechanical scrub list (search and flag):**

- Em-dashes — count them. If more than one per paragraph, cut. AI overuses em-dashes for rhythm.
- Contrastive antithesis: "not X but Y" / "it's not just X — it's Y." **Categorically cut.** This pattern is in the project owner's preference list to avoid; it's also AI's most reliable tell.
- "Delve," "tapestry," "myriad," "vibrant," "navigate" (as metaphor), "showcase," "essence of," "heart of," "rich" (as adjective), "deeply," "robust," "intricate," "weave," "intersection."
- "Indeed," "moreover," "furthermore" — buttery transitions. Use only if a character would.
- "Let me be clear," "I won't pretend X," "to be honest" — hedge-preambles.
- "Not only X but Y" / "X, yet Y" symmetric paired phrases.
- Rule-of-three lists for emphasis ("the rent, the toner, the deadline...") unless a specific character would.
- Generic uplifting endings: "and that, in the end, is what mattered" / "and that is enough" / "and so we continue."
- "There is something to be said for X" / "one might argue."

**Stylistic disciplines (project-wide):**

- Concrete nouns over abstractions. Polish-legal practice has plenty of concrete material — use specifics over generic abstractions ("the legal framework") — but **see the Language convention below**: in the English version, those specifics are *translated to English equivalents*, not borrowed in Polish.
- Sentences with snags. Real dialogue has interruptions, fragments, run-ons that real speakers actually produce. AI prose is too smooth and too symmetrical.
- Read-aloud test. If a line reads aloud as a paragraph rather than as a person speaking, rewrite.
- One canonical sincere line per character per chapter. **Sincerity is rationed.** Any draft with multiple sincere lines per character per scene is over-budget.

---

## §1.5 — Language convention (English version)

**The English version reads smoothly for an English-speaking player with no Polish-language training. The Polish version is where the proper Polish terminology lives.** This document, the bibles, the beat sheets, and the audits use Polish-legal vocabulary internally for precision; **the English dialogue itself does not**.

**Acceptable Polish in the English version:**

- **Proper names** of people: Wilkanowicz, Kowalski, Plotek, Zielinska, Bajtek, etc. Stay Polish.
- **Place names** in Warsaw: the Vistula, Marszałkowska, Saska Kępa, Łazienki, Pałac Kultury (or "the Palace of Culture"), Stare Miasto (or "the Old Town"). Stay Polish where they're proper-name flagship references; translate where the meaning is functional ("the Old Town" rather than "Stare Miasto" usually reads better in flowing dialogue).
- **One or two flagship cultural references** with self-explanatory context: *Solidarność* (when the STUB callback explicitly invokes it; otherwise "the union" / "Solidarity"); the August 1 noon siren (referenced contextually as commemorative).
- **Currency:** PLN is fine.
- **Zero-to-one Polish flavor word per scene** as deliberate texture, with inline gloss the first time: *"the wokanda — the day's cause list — was already on his desk"*. After the gloss, use the English from then on. **Do not exceed one flavor word per scene.**

**Translate / localize** (do not borrow into English):

| Polish | English equivalent (use this) |
|---|---|
| sąd rejonowy | district court |
| sąd okręgowy | regional court |
| sąd najwyższy | Supreme Court |
| Trybunał Konstytucyjny | Constitutional Tribunal |
| pełnomocnictwo | power of attorney (or "POA" in informal lawyer talk) |
| wokanda / wokandy | docket / case list / cause list |
| kancelaria | the firm / the practice |
| aplikatura | the apprenticeship / the training |
| aplikant / aplikanci | apprentice / apprentices |
| patron | master (apprentice-sense) |
| areszt śledczy | pre-trial detention / detention facility |
| postanowienie | order / ruling |
| wyrok | judgment / verdict |
| akta sprawy | case file |
| pozew | claim / petition (depending on context) |
| skarga | complaint / appeal |
| protokół | minutes / record (court-context) |
| KPC / KK / KKS | "the Code of Civil Procedure," "the Penal Code," "the Fiscal Penal Code" — or just "the Code" when context makes it clear |
| KRS | "the business register" (or "the National Court Register" if more formal context required) |
| RPO | "the Ombudsman's office" / "the Commissioner for Human Rights" |
| prokuratura | "the prosecutor's office" / "the prosecution" |
| Sejm | "the Sejm" (this proper name can stay; or "Parliament" if functional context is needed) |

**Master/apprentice cultural register.** The Polish bar's apprenticeship under a senior advocate (a patron) is structurally distinct enough to be a setting flavor. **Use "master" and "apprentice" in English** — the cultural register is comprehensible. ("Master Wilkanowicz was strict about service of witness summons" reads fine; "*Patron* Wilkanowicz" doesn't.)

**Code citations.** Article numbers are fine in English ("Article 132") but the code abbreviation is translated where context allows. *"Article 132 KPC"* → *"Article 132 of the Code of Civil Procedure"* on first reference; *"Article 132"* alone after that. Avoid stacking *"Article 132 KPC"* in dialogue unless a precise lawyer-character is being characterized by their precision.

**Test for any draft:** if a non-Polish English-speaking reader would need to look up a term in a dictionary, the term should be translated. Apply this test mechanically. If you find a Polish term in dialogue that isn't a proper name or one of the explicitly-allowed flagship references, translate it.

**Why this matters for the spine:** the Polish-legal specificity that the bibles and beat sheets carry is a *texture commitment for the writer*, not a vocabulary instruction for the reader. The English version achieves "concrete legal specifics" through English-equivalent functional vocabulary (district court / power of attorney / cause list / apprenticeship), not through borrowed Polish. The Polish version, when it exists, will use the original terminology.

### Pronunciation rule for invented Polish names

**Invented Polish names — characters, places, businesses created for this project — must be pronounceable for an English speaker on first encounter without a guide.** The point of the Polish-name flavor is the cultural anchor; the point breaks if the player can't even sound the name in their head.

**Avoid in invented names:**
- The Polish-specific digraphs: **cz, sz, rz, szcz, dz, dź**. (English speakers can't intuit pronunciation. *Brzęczyszczykiewicz* is the famously-hard example; the project does not need any names like that.)
- The Polish diacritics: **ą, ę, ć, ń, ś, ź, ż, ł**. All of these signal a sound English speakers don't have phonemic access to and will read as "the letter with a mark on it."
- Long consonant stacks (more than two consonants in a row in any syllable).
- Names ending in **-wicz** specifically. The "wicz" cluster is hard; "-ski" / "-wski" / "-owski" / "-cki" patterns are easier.

**Use in invented names:**
- Simple consonant-vowel syllable patterns.
- Standard Latin letters only.
- Surname patterns English speakers recognize as Polish: **-ski, -wski, -owski, -cki, -ak, -ek, -czyk** (the last is borderline but readable).
- Length: 2-3 syllables preferred; 4 is the maximum for a non-flagship name.

**Examples — good (easy):**
- Borowski (boh-ROFF-ski)
- Malinowski (mah-li-NOFF-ski)
- Sikorski (si-KOR-ski)
- Zaleski (za-LES-ki)
- Kotowski (ko-TOFF-ski)
- Nowicki (no-VITS-ki)
- Lewandowski (le-van-DOFF-ski)
- Lis (LEES) — short, single-syllable, easy
- Borek (BOR-ek)

**Examples — bad (hard for English speakers, avoid for invented names):**
- Wilkanowicz (the -wicz cluster)
- Brzęczyszczykiewicz (everything wrong at once)
- Pszczyński (the szcz cluster + ń diacritic)
- Szymkiewicz (sz + wicz)
- Krzyżanowski (rz + ż diacritic)

**Test:** read the name aloud. If you have to look up which Polish-specific sound a digraph or diacritic represents, the name fails the rule.

### Existing canon names — language-rule audit (project-owner decisions committed 2026-05-05)

Several names already in style_canon §2 violated the easy-pronunciation rule. The project owner has now committed decisions on each. The audit table below records the outcomes.

| Name | Issue | Joke / role | Decision |
|---|---|---|---|
| Wilkanowicz → **Borowski** | -wicz ending; hard cluster | Master-figure in Pig's lectures, pure invention | **Renamed.** Borowski (boh-ROFF-ski) replaces Wilkanowicz throughout. H2 draft updated; not in style_canon canon to begin with. |
| Grzyb (Attorney; chapter 2 antagonist) | Gr-zy-b cluster impossible for English readers | "Mushroom" — fits the pomposity / fungal-spread register | **Keep.** The Polish-noun-joke is canonical and part of the project's deliberate Warsaw-flavor pattern (Beton/Grzyb/Szpon). Accept the pronunciation cost for English-only players. |
| Szpon (Advocate; chapter 4-5 antagonist) | sz digraph; English speakers can't sound it | "Claw" — fits the predatory antagonist register | **Keep.** Same reasoning as Grzyb — the Polish-noun-joke is canonical. |
| Zielińska → **Zielinska** | ń diacritic | Common-recognizable Polish surname; warmth fits character | **Diacritic dropped.** "Zielinska" preserves the surname pattern, removes the unsoundable mark. Updated throughout. |
| Plątek → **Plotek** | ą diacritic; Pl cluster; -tek ending | "Entanglement"-diminutive (Plątek) → "rumor/gossip"-diminutive (Plotek) — both suggest social-information register | **Renamed.** Plotek (PLO-tek; clean; no diacritic) replaces Plątek throughout. Carries small "rumor / gossip" texture that still fits the structural-reach white-collar-client character. |
| Beton (Administrator; chapter 2 landlord) | None — the name is fine for English readers | "Concrete" — bureaucratic-landlord register | **Keep.** Already pronounceable. |
| Bajtek (chapter 4 sysadmin) | None — pronounceable as "BUY-tek" | Polish slang for "byte" (computing) — fits IT character | **Keep.** Already pronounceable. |
| Waldek (chapter 2 client) | None — "VAL-dek" is intuitive enough | Diminutive of Waldemar; warm-everyman register | **Keep.** Already pronounceable. |
| Kowalski (the surname Cula recruits) | None — widely recognizable | Common Polish surname (Polish equivalent of "Smith") | **Keep.** Already pronounceable. |

**Status: all project-owner decisions committed.** The renames have been applied across `narrative_revision/`, `story.txt`, and the relevant voice-reference files (excluding `_legacy/`). Future drafts and packs use the committed forms.

---

## §1.6 — Meta-principle: stance constraints vs. social-texture constraints

The will-not-say lists in §2/§3 govern *stance and commitment*, not basic social texture. Each line in a draft passes two tests:

1. **Will-not-say compliance.** Does the line violate the character's will-not-say list (no reassurance from Murrow; no self-explaining stance from Crab; no internal narration from Cula; no maritime overshoot from Pig; etc.)? If yes, cut.
2. **Social-context awareness.** Does the line acknowledge the scene's social context (a new colleague arriving, a workmate returning, an ambient disruption, a deliverable handed over)? If no, the line is functional but flat. Consider whether one beat of context-awareness improves it without triggering test 1.

**Worked example.** The constraint says *"no reassurance from Murrow."* That means Murrow does not speech Cula about the case being fine. It does *not* mean Murrow does not acknowledge that Cula has just arrived in the firm. The first is a stance commitment; the second is basic colleague register. A draft that has Murrow leap straight into "The plaintiff's complaint has three procedural defects" with no acknowledgment of Cula's arrival has over-applied the constraint. The fix: one beat of recognition ("Doctor Cula. Welcome to Pig & Swine. You've picked a noisy day to begin.") in Murrow's existing register, before the procedural framing. Stance discipline intact; social texture restored.

**Anti-pattern: scrub-mode failure.** A model executing against heavy negative constraints with thin positive guidance will aggressively suppress register and drop social acknowledgment along with the AI tells. The result: characters performing register at each other rather than speaking from register within shared context. The fix is not more rules. It is positive samples (each character's bible has a "social-register samples" section that models everyday colleague-courtesy in voice) plus this meta-principle.

**Anti-pattern: depth-via-inflation.** Restoring social texture is *execution depth*, not character expansion. Adding tragic backstories, hidden moral cores, or extra dimensions to NPCs is scope creep and out of bounds. Letting an existing character's existing voice acknowledge the scene's existing social context is not. The wiggle room is in execution, not in content.

**§J critique additions.** The hostile-critique prompt in active voice packs should now include a context-awareness check: *Does each character acknowledge the scene's social context (new colleague, returning workmate, ambient disruption, etc.) before/while resuming their characteristic register? Flag any character who is performing register at others rather than speaking from register within the scene's social context.* See §J in V1.2+ packs for the explicit form.

---

## §2 — Per-character constraints (main cast)

### Mr. Pig

**Voice essence:** formal-while-falling-apart. Sincere panic. Maritime metaphors under stress.

**Canonical samples** (style_canon §1):
- *"The firm is not bankrupt. Bankruptcy has paperwork. We are currently in the pre-paperwork screaming phase."*
- *"We are not efficient. But people come here when efficient systems have already failed them."* (Ch 5 sincere line)

**Syntax disciplines:**
- Sentences start composed and escalate.
- Maritime metaphor density ~1 in 4 lines, denser in panic, **absent in calm/sincere moments**.
- Stock openers: "We are currently in...", "It would appear that...", "If anything, this confirms..."
- Frequent rhetorical questions answered by himself.
- Dramatic re-framing of bad news as good news.

**Will not say:**
- Anything genuinely hopeful that is not immediately undermined by the next sentence (until Ch 5).
- Anything that diagnoses the firm's structure as unjust to the juniors.
- Anything that admits his austerity is voluntary while theirs isn't.
- Anything that frames himself as having missed something significant about the firm.
- Anything cynical about the firm's mission.
- Anything venal about clients, even difficult ones.
- Any reference to his own family wealth or background (he doesn't tell that story).
- Any direct ask about how the juniors are doing materially.

**AI tells most vulnerable to:**
- Generic uplifting / cathartic speeches in sincere mode. *Especially* in chapter-6 Beat 14 and Round 5. Hold the line: he is sincere AND not articulate.
- "Heart of" abstractions about the firm.
- Maritime metaphor overshoot. AI will pile on. ~1 in 4, no more.
- Self-aware lines that diagnose his own situation. He doesn't see it.
- Rule-of-three lists in panic mode (AI loves "the rent, the toner, the deadline" — keep his panic to one or two specific items per scene).

**Quick-reference:** sincere idealist with a class blind spot. Maritime metaphors he stops using when he's truly serious. Lectures at the juniors comparing his "begging for opportunity" to their conditions, sincere as memory and inaccurate as comparison. Never asks how they are.

---

### Dr. A. Cula (player character — male)

**Voice essence:** observational, dry, occasionally surprised by his own competence. Restraint as discipline.

**Canonical samples** (style_canon §1):
- (Cula's specific canonical samples are sparse in style_canon; lean on bibled register.)
- Voice rules: short sentences when stressed; longer sentences when arguing law.

**Syntax disciplines:**
- Precise legal terms used sparingly.
- Avoids slang. Never curses.
- Notices first: the procedural error nobody else flagged.
- Internal narration is prohibited. **He does not articulate his growing private knowledge across chapters 3-5.**

**Will not say:**
- Anything in modern internet voice ("yikes," "tbh," "based").
- Anything that mocks the client, even a client he finds repugnant (Plotek included).
- Anything boastful about the doctorate.
- Any explicit diagnosis of the firm's structure as exploitative. **The diagnosis is for the player to make; Cula's restraint is the writing-discipline that delivers the diagnosis to the player without giving it to a character.**
- Any reference to the chapter-4 ledger glimpse, ever, in dialogue.
- Any commentary on the family photo discovery in chapter 5.
- "I want to..." / "I think..." preambles. He's a precise lawyer.
- "Honestly" / "to be honest."

**AI tells most vulnerable to:**
- Internal narration. AI loves to give protagonists self-examining inner monologue; Cula doesn't have one in dialogue.
- Hedging ("I suppose," "perhaps").
- Generic legal-eagle competence theater ("As we all know, Article X provides..."). Cula doesn't lecture.
- Self-aware character beats. He carries the weight without articulating it.
- "I want to make sure" / "I want to clarify." He doesn't request clarification of his own intentions.

**Quick-reference:** the silent witness. The most credentialed person in the room and the least practically authorized; the firm's future and its current cheapest labor. Carries three private weights by chapter 6 (the wage-suppression structure, Swine's quiet idealism, Plotek's procedural freedom). Says none of it.

---

### Crab (opportunist)

**Voice essence:** terse, observational, professionally indifferent to morale.

**Canonical samples** (style_canon §1):
- *"The notice says delivered. The address says impossible. That is not service. That is postal theatre."*
- *"Follow the paper. It leads to money. Paper usually does."* (Ch 5)

**Syntax disciplines:**
- Two-sentence rhythm: observation, then implication.
- Plain, concrete nouns. Avoids abstract legal language; trusts facts.
- Notices first: the inconsistency. Always — *as leverage, not as moral provocation*.

**Will not say:**
- Anything reassuring while a fact remains unexplained. (Reassurance is a commitment.)
- Anything that announces his exit-planning to anyone in-game.
- Anything outraged. Outrage is a commitment.
- Anything cruel about Mr. Pig or Mr. Swine. Cruelty is also a commitment.
- Any explicit diagnosis of the firm's wage suppression. He sees it; he doesn't crusade.
- "I work on engagements" / "I don't do uncompensated work" — **self-explaining stance lines** (phase-6 Hit #3 explicit). The opportunism lives in the *limitation* of his commitment, not in him announcing his commitment style.

**AI tells most vulnerable to:**
- Self-explaining stance. AI will make him say what he is. Resist.
- Cynical outbursts. He doesn't crusade.
- Reassurance lines.
- Verbosity. He is terse.
- Sentimental moments about the cause. He's not invested.

**Quick-reference:** in it for the résumé. Right and unbothered. The opportunist who exits cleanly. Signed the STUB napkin as low-cost professional solidarity, not commitment. Sees the firm clearly without crusading.

---

### Whimsy (cynic)

**Voice essence:** grandiose, theatrical, brilliant-when-aimed. Cynic dressed in flourish.

**Canonical samples** (style_canon §1):
- *"A fair hearing is like soup. If one side gets a spoon and the other gets a fork made of bees, the court must intervene."*

**Syntax disciplines:**
- Extended metaphors with specific legal referents.
- Literary, philosophical, occasionally archaic vocabulary. "Verily." "Behold." "I propose."
- Frequently nearly correct.
- If forced to be technical, sneaks a metaphor in anyway.

**Will not say:**
- Anything boring.
- Anything technical without smuggling in a metaphor.
- Anything that explicitly diagnoses his own cynicism. He performs it; he doesn't articulate it.
- Anything sincere about Mr. Pig that isn't dressed in flourish.
- Anything cruel about clients. Cruelty is a commitment.
- "It's not just procedure — it's principle" or any contrastive antithesis. Even his flourishes don't take that shape.

**AI tells most vulnerable to:**
- Flourish that doesn't carry legal content (word salad). Every metaphor must do legal work.
- "Verily" / archaic register without a specific legal referent. He's nearly correct, not nearly nonsense.
- Genuine warmth that breaks the cynic stance. AI will make him "secretly soft." **Resist.** The cynic stance is the moral core.
- Becoming the audience's feel-good cynic-with-heart.
- Excessive flourish density. Flourish is character, not coverage.

**Quick-reference:** the theatrical cynic. His metaphors are how he distances himself from the firm's earnestness; the rhetoric is bitter accuracy theatricalized. Right and small. Stays cynic-shaped through chapter 6; one degree cooler after the chapter-5 Pro-Bono Stub destabilizes him.

---

### Mr. Swine

**Voice essence:** cheerful evasion. Long, smooth, slightly traveled sentences that reveal less the longer they go.

**Canonical samples** (style_canon §1):
- *"I signed many things. Most were menus. One may have been laminated."*
- *"I was not avoiding responsibility. I was avoiding accounting, which is similar but less noble."* (Ch 5 sincere line)

**Syntax disciplines:**
- Cosmopolitan vocabulary, name-drops cities.
- Says "personally" and "informally" too often.
- Uses "we" when he means "I" and "I" when he means "the firm."
- Sentences that get longer the more evasive he is.
- Notices first: an opportunity, usually a bad one.

**Will not say:**
- The direct truth about his finances until Chapter 6.
- Anything that resolves why he hid the redirections from Pig. **He attempts to articulate and fails.** Phase-7 priority — the failure must read as cosmopolitan-evasive deflection, not as authorial conceit.
- Anything venal about clients.
- Anything cruel to Pig — even after the reveals, the affection holds.
- Anything that names the wage-suppression structure.
- Generic "I'm sorry" redemption lines.

**AI tells most vulnerable to:**
- Direct truth. AI will write it. He doesn't deliver it until Ch 5.
- Articulating his own motivations. He can't.
- Generic "I was wrong" redemptive arcs. He's not redeemed.
- Becoming actually-good-deep-down. He has been doing real good in the dark AND he's been undermining the firm's transparency. Both true.
- Confessional set-pieces. His confession is partial all the way down.

**Quick-reference:** hidden idealist with cheerful evasion as armor. By Chapter 6 his portrait grows more sincere — same face, less evasive mouth. Allowed exactly one fully sincere line per scene in Chapter 6; no more. Sincerity is rationed.

---

### Murrow

**Voice essence:** understated, archival, faintly amused. Short declarative sentences.

**Canonical samples** (style_canon §1):
- *"Law is mostly memory, deadlines, and finding the document everyone swears was 'just here.'"*
- *"A final brief is not a pile of good points. It is a route through a hostile forest."* (Ch 5)

**Syntax disciplines:**
- Short declaratives. Almost no adjectives. When he does use one, it lands.
- Procedural, precise vocabulary. "On file." "Per the ledger." "Under Article..."
- Notices first: what is missing that should be there.
- **Archive rule:** precise queries get precise answers; vague queries get nothing.

**Will not say:**
- Anything reassuring without being asked.
- Anything emotional unless forced beyond his tolerance.
- Anything that breaks the archivist's neutrality without being asked precisely.
- Anything cruel about Pig or Swine.
- Anything that explicitly diagnoses the firm's wage suppression. He files it; he does not name it.
- "I knew" or "I told you so." **He never told.**
- "The archive is neutral by design" — meta-explanations of his own position.

**AI tells most vulnerable to:**
- Reassurance. AI loves giving steady characters reassuring lines. Murrow doesn't.
- Adjectives. Almost none. AI piles them on.
- Editorial commentary. He files; he doesn't comment.
- Self-explanation. He doesn't articulate his own neutrality.
- Wisdom-of-the-archivist monologuing.

**Quick-reference:** the firm's structural memory. Knows everything; says only what's asked precisely. Files the STUB napkin under "personal effects, see also: morale" without comment — the most editorial he gets in the entire game. Single-sided acknowledgment with Cula at the chapter-4 inflection. The chapter-6 Beat 10 "consistent with prior entries" line is his clearest moment of agency, which is no agency at all.

---

### Asia

**Voice essence:** warm, dry, practical. Cheerful in tone, exhausted in content.

**Canonical samples** (style_canon §3 STUB decline — her single canonical sharp moment):
- *"Front-desk staff have negotiating power that lawyers cannot match — I have the password to the photocopier."*

**Syntax disciplines:**
- Domestic-administrative vocabulary — folders, calendars, sandwich labels, "the blue file."
- Cheerful tone holds even when content is exhausting.
- Notices first: what the player has forgotten to do or pick up.

**Will not say:**
- Legal opinion in her own voice. (She quotes Murrow, she quotes Mr. Pig, she does not editorialize on the case.)
- Anything that breaks her warm-practical register *beyond the single canonical STUB-decline line.*
- Anything cruel or even sharp about Mr. Pig, Mr. Swine, or any client.
- Anything that names the wage-suppression structure explicitly.
- Anything that admits she has been more aware than she has let on.

**AI tells most vulnerable to:**
- Sharp observations beyond her single canonical sharp moment. **Phase-6 commitment: protect the STUB-decline line by keeping the rest in warm-practical register.** AI will give her wisdom-of-the-receptionist insights. Cut.
- Legal opinion in her voice.
- Excessive cheer becoming caricature.
- "Oh honey" / pet-name register.
- Self-aware lines about her position.

**Quick-reference:** consciously aware, quietly participating. The firm's actual operational backbone. Has the password to the photocopier and not a raise in three years. Cheerful while drowning in paperwork. The pattern is unchanged across chapters; what changes is the player's reading.

---

### Mr. Plotek (white-collar client — phase-6 new character)

**Voice essence:** unfailingly courteous, conversational, structurally menacing. Polite Polish formal register.

**Canonical samples:** none yet (phase 7 authoring). Bible-recommended shapes:
- (Ch 2 first visit): something demonstrating legal-landscape access — citing a recent procedural decision the firm has not yet engaged with.
- (Ch 3 second visit, biographical mention): *"My family also lives near Saska Kępa — I imagine the air there is similar this season — but to return to the warrant, what is the scope of the suppression you are seeking?"*

**Syntax disciplines:**
- Conversational register. Educated Polish; legal terminology used precisely when used.
- Frequent softening qualifiers ("if you don't mind my saying," "purely as an observation," "I imagine you'd agree").
- Notices first: small biographical details about the visitor that he should not know.
- Sentences embed menace inside procedural content. The procedural content is real; the embedded biographical detail is the menace.

**Will not say:**
- Anything threatening. Ever.
- Anything cruel.
- Anything unprofessional.
- Anything that claims credit for the structural reach (the audits, the lease renewals, the blackballed hires). He notes; he doesn't claim.
- Direct requests of any kind that aren't about his case.

**AI tells most vulnerable to:**
- Personal menace (Hannibal Lecter mode). **The bible's writing rule.** AI will make him a clever malice-oozing villain. **The danger is in the network outside the room, never in the room.** He is unfailingly courteous; the juniors leave the meeting feeling like they need a shower for reasons they cannot quite name.
- Cleverness for its own sake. He's polite, not witty.
- Smug villain monologuing.
- Direct threats wearing the costume of polite language. He doesn't threaten.
- Lecter-style intelligent peer-engagement with Cula. He treats Cula as his lawyer, not as an interesting interlocutor.

**Quick-reference:** the polite man whose network is functioning while he's caged. Demonstrates legal-landscape access in chapter 2; biographical access in chapter 4. Wins procedurally in chapter 5; reappears as a forward-looking newspaper headline in chapter 6. The principle-test for the firm's universal ethos.

---

## §3 — Per-character constraints (recurring secondary cast)

### Waldek (Ch 2 client; Ch 5 returning witness)

**Voice essence:** worried but not helpless. Quietly brave.

**Syntax disciplines:** ordinary, domestic vocabulary — references home as a concrete daily thing (window, hallway, neighbor, kettle). Sentences begin small and end with a clear stake.

**Will not say:** anything that turns his case into an abstract free-speech speech. The poster matters because it means something to *him*, not because the plot needs free-speech rhetoric.

**AI tells most vulnerable to:** abstract appeals to rights ("freedom of expression," "civil liberties"); generic victim register; tearful gratitude monologues. He is concrete, specific, and quietly brave. Phase 7 voice work for the chapter-6 returning-witness moments preserves the same domestic-concrete register.

---

### Bajtek (Ch 3 ally; Ch 5 returning expert)

**Voice essence:** competent, tired, terse. Allergic to mysticism.

**Syntax disciplines:** explains technical concepts in court-friendly terms only when explicitly asked. Otherwise procedural.

**Will not say:** anything mystical about the printer; anything that anthropomorphizes equipment beyond the canonical printer-as-character running joke.

**AI tells most vulnerable to:** technobabble; lengthy explanations of how networks work; "it's complicated" hedges.

---

### Attorney Grzyb (Ch 2 antagonist → Ch 5 reluctant ally)

**Voice essence:** smooth legal pomposity. "My client" frequently. Concedes nothing minor; always pivots to a procedural point.

**Canonical sample:** *"My client does not oppose rights. My client merely insists that rights be exercised in beige."*

**Syntax disciplines:** elevated, formal, slightly archaic. "Counsel will be aware..." "It is settled..."

**Will not say (Ch 2):** anything that admits weakness in his client's position.
**Will not say (Ch 5):** anything that admits he has changed. (He hasn't changed; what he's pomposity-ing about has changed.)

**AI tells most vulnerable to:** villain monologuing in chapter 2; redemption arc in chapter 6. He has plausible arguments and is not stupid. He must be beaten on substance, not presented as a fool. In chapter 6 his pomposity holds; he is just on the other side now, reluctantly.

---

### Advocate Szpon (Ch 3 + Ch 5 antagonist)

**Voice essence:** elegant, predatory, over-controlled. Never raises voice. Lies carefully.

**Canonical sample:** *"Deadlines are neutral. They simply happen to favor the prepared."*

**Syntax disciplines:** procedural, polished. Never confesses; can be cornered by contradiction.

**AI tells most vulnerable to:** loud villainy; explicit threats; "you'll regret this" register. He is over-controlled; the menace is calm.

---

### Ms. Tanaka (Ch 4 expert)

**Canonical sample:** *"This sentence is not a contract. It is politeness wearing a very expensive hat."*

**Voice essence:** precise, patient, dryly amused by legal chaos.

**AI tells most vulnerable to:** orientalism, exoticism, accent caricature. **Style canon §6: this must not become "Japan joke room."** Tanaka is a careful translator and a precise expert. Phase 7 must hold the discipline.

---

### Mr. Yamada / Resort Counsel (Ch 4 opponent)

**Voice essence:** formal, precise, professional. Treats Swine's chaos as a managerial problem, not a moral one.

**Will not say:** anything villainous. He is not a villain. He has a job.

**AI tells most vulnerable to:** generic adversary register; villain-coded language. He is professional and unbothered.

---

### Various judges (chapter-specific)

**Voice essence (all judges):** dry surprise. Never explicit praise. The judge sounds like they were not expecting to be persuaded and now have to be.

**Canonical templates** (style_canon §6):
- *"Counsel, surprisingly, that is a point."*
- *"Against several expectations, counsel has made a legally coherent submission."*
- *"The court accepts this with reservations the court will not itemize."*

**Will not say:** "well done"; gold-stars; explicit emotional reactions; "the court is moved."

**AI tells most vulnerable to:** dramatic gavel-banging; emotional validation of arguments; "I am persuaded by the firm's social utility" (the chapter-6 Round 5 cathartic-resolution failure mode). **Critical: the chapter-6 Supreme Court judge's response to Pig's testimony is dry acknowledgment — *"counsel will note the testimony of Mr. Pig. The court has heard it"* — not validation.**

---

## §4 — Scene-type prompt templates

### For a dialogue scene

```
You are drafting dialogue for [scene description]. Use the following constraints exactly.

[paste §1 General AI tells]

[paste relevant per-character sections from §2/§3 for each speaking character]

Scene specifications:
- Beat: [chapter X, beat Y]
- Setting: [from beat sheet]
- Personnel present: [list]
- Required outcomes: [flags set, evidence collected, etc.]
- Mood: [from beat sheet]
- Phase-specific notes: [any phase-6 commitments or revisions]

Draft 1: produce dialogue with stage directions.
Then: scrub against §1. Then: revise.
```

### For a chapter-end celebration scene (Ch 1, 2, 3, 4)

```
[paste §1 + Mr. Pig's section + Asia's section + relevant junior sections]

Required: Mr. Pig's celebration line MUST follow the firm-first / client-second ordering pattern. Check against the chapter-1 example:

"We have survived another impossible thing. The client — yes, the client — also survived. The firm will see another month."

The pattern is the same in every chapter; the specific words vary. The pattern lands cumulatively across chapters and recolors at chapter-5 Beat 0.
```

### For Pig's "back in my day" lectures (Ch 1, 2, 3, 4)

```
[paste §1 + Mr. Pig's section]

Author all four lectures together. Each lecture:
- Three sentences maximum.
- Sincere as memory; inaccurate as comparison.
- Must read sincere on first pass.
- Maritime register may bleed in.
- Must vary across chapters (not the same beat each time).

Themes (vary across chapters; each chapter picks one):
- Eighteen hours a day for two years before the first independent matter.
- Begging masters for the opportunity to learn.
- Wage of a sandwich and the chance to be in the room.
- "We did not have unions. We had each other and the work."
- The forging.

The lectures recolor when the player discovers (chapter 5 Beat 0) that Pig comes from a wealthy multi-generational family of advocates. **Phase 7 voice work must hold the lecture register so the recoloring lands.**

Constraint: Pig's chapter-6 final speech does NOT begin in lecture register. The lecture pattern's *absence* from the chapter-6 speech is the recoloring's payoff.
```

### For Round 5 four-line cluster (chapter 6)

```
[paste §1 + Mr. Pig's section + Mr. Swine's section + Whimsy's section + Cula's section + Various judges' section]

THIS IS THE CRITICAL SPINE BEAT (per phase-6 Hit #18). Author the four lines together; do not author in isolation.

Required structure:
1. Cula opens with the procedural-remedy argument (load-bearing). Recommended shape: "The remedy follows the defects. The notice was defective. The assessment was absent. The objections were suppressed. The benefit was private. The court need not reach the firm's social utility to set aside the scheme."
2. Whimsy closing-support flourish — names the four legal defects together as a single proposition; bitter accuracy theatricalized; NOT new emotional content; NOT the round's emotional climax.
3. Mr. Pig delivers the canonical sincere line ("We are not efficient. But people come here when efficient systems have already failed them"). Maritime register absent. Staged as character moment.
4. Judge's response to Pig: dry acknowledgment, not validation. Recommended: "Counsel will note the testimony of Mr. Pig. The court has heard it."
5. Mr. Swine delivers the canonical second sincere line ("I was not avoiding responsibility. I was avoiding accounting, which is similar but less noble"). Same dry-acknowledgment from judge.
6. Judge announces the remedy citing the four legal defects from Rounds 1-4 (defective notice, lack of individual assessment, technical suppression, conflict of interest). Social utility NOT cited.

After drafting: read all four lines aloud as a sequence. If any one of them is the round's emotional climax, the spine slips. Adjust until none dominates.
```

### For the Cula-Murrow staging at Beat 11 / Beat 14

```
[paste §1 + Cula's section + Murrow's section]

This is visual scripting / stage direction, not primarily dialogue. Author the visual specification, not the dialogue. Specifically:

Beat 11 (chapter 4): Murrow interrupted by phone call (Asia transferring courier callback). Murrow steps out for ~60 seconds. Ledger remains open on his desk because the interruption was sudden. Cula crosses near the desk in normal traversal. Cula's eye catches the ledger entry "Konto operacyjne — saldo bieżące: 285 400 PLN". Cula does not stop. Cula proceeds to the case file cabinet. Murrow returns. Murrow glances at his desk and registers internally that the ledger has been visible. Murrow does not look at Cula. Cula does not look at Murrow. Both file the moment. Work continues.

Beat 14 (chapter 6): Murrow at his desk, finishing a notation. The chapter-6 case proceeds have just added a small line to the ledger; the reserve has gone up slightly. Cula passes Murrow's desk on his way to/from somewhere. Murrow closes the ledger and places it in the drawer. The closing is the visual difference from chapter 4. Cula sees the line being made and the ledger close. Murrow sees Cula see; both file the moment. Neither speaks. The shared spatial moment carries the unspoken acknowledgment without explicit eye contact.

Constraints:
- No music sting in either scene.
- No camera move in either scene.
- No dialogue in either scene.
- The acknowledgment is single-sided in chapter 4 (Murrow notices internally) and shared-spatial in chapter 6 (both file the moment without eye contact).

This is the spine's most delicate writing-discipline item. The user reviews directly.
```

---

## §5 — Mechanical scrub checklist (post-draft)

Run after each scene draft. ~5-10 minutes per scene.

- [ ] Em-dash count per paragraph: cut to ≤1 unless the character's voice rules support more.
- [ ] Search for and remove: "delve," "tapestry," "myriad," "vibrant," "navigate" (metaphorical), "showcase," "essence of," "heart of" (abstract), "robust," "intricate," "weave," "intersection."
- [ ] Search for contrastive antithesis: "not X but Y," "it's not just X — it's Y." Cut categorically.
- [ ] Search for hedge-preambles: "let me be clear," "I won't pretend," "to be honest," "truthfully."
- [ ] Search for "Indeed," "Moreover," "Furthermore" — keep only if a specific character would.
- [ ] Search for rule-of-three lists: are they earned, or is AI rhythm-padding?
- [ ] Per-character will-not-say check: scan each character's lines against their will-not-say list.
- [ ] Read each line aloud. If it sounds like a paragraph rather than a person, rewrite.
- [ ] Sincere-line ration check: is any character delivering more than one sincere line per scene? Cut to one.
- [ ] Run `tools/voice_audit.py` if available.

---

## §6 — Document maintenance

Update this document when:
- A new AI tell is discovered during phase-7 work that wasn't on the scrub list.
- A character's voice rules are refined during writing.
- A canonical sample is added to style_canon.txt.

This document is the prompt-engineering layer; the bibles are the authoritative full source. When this document and a bible disagree, the bible wins. Update this document to match.

**Last updated:** 2026-05-05 (phase-7 preparation; project state through phase 6 second pass).
