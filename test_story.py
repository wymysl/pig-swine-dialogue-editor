from pathlib import Path

HTML = Path(__file__).with_name('index.html').read_text(encoding='utf-8')


def check(condition, message):
    if not condition:
        raise AssertionError(message)


def test_new_campaign_cast_is_present():
    for name in ['Dr. A. Kula', 'Mr. Pig', 'Mr. Swine', 'Rak', 'Wymysl', 'Muraś']:
        check(name in HTML, f'missing cast member: {name}')


def test_new_story_beats_are_present():
    required = [
        'financial situation',
        'skiing in Japan',
        'human rights',
        'Polish law',
        'courts',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing story beat: {phrase}')


def test_new_quest_flags_exist():
    for flag in ['orientation', 'guide', 'friends', 'law', 'rights', 'court']:
        check(f'{flag}:false' in HTML or f'{flag}: false' in HTML, f'missing quest flag: {flag}')


def test_interaction_markers_are_implemented():
    required = [
        'function drawInteractHint',
        'getNearbyInteractable',
        'Press Space',
        'item.label',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing interaction marker implementation: {phrase}')


def test_docket_overlay_is_implemented():
    required = [
        'showDocket',
        'function drawDocket',
        'DOCKET',
        "e.key.toLowerCase()==='q'",
        'Muraś note',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing docket overlay implementation: {phrase}')


def test_case_bag_overlay_is_implemented():
    required = [
        'showCaseBag',
        'function drawCaseBag',
        'CASE BAG',
        "e.key.toLowerCase()==='i'",
        'Polish law binder',
        'human rights memo',
        'Procedural Anxiety',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing case bag overlay implementation: {phrase}')


def test_mr_pig_opening_scene_is_implemented():
    required = [
        'function startOpeningScene',
        "state.quests.orientation=true",
        'Welcome to Pig & Swine, Dr. A. Kula',
        'Mr. Swine is skiing in Japan',
        'Find Muraś',
        "state.quests.guide=true",
    ]
    for phrase in required:
        check(phrase in HTML, f'missing Mr. Pig opening scene implementation: {phrase}')


def test_court_argument_choice_is_implemented():
    required = [
        'choiceMenu',
        'function startCourtArgumentChoice',
        'function drawChoiceMenu',
        'function resolveCourtChoice',
        'defective service affected the right to a fair hearing',
        'Mr. Swine is skiing in Japan',
        'Press 1, 2, or 3',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing court argument choice implementation: {phrase}')


def test_court_result_screen_is_implemented():
    required = [
        'function drawResultScreen',
        'showResult',
        'resultData',
        'CASE RESULT',
        'CASE DISMISSED',
        'Argument Quality',
        'Human Rights Angle',
        'Firm Liquidity: +',
        'Bar Reputation: +',
        'We may yet afford toner',
        'Day One complete',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing court result screen implementation: {phrase}')


def test_smooth_movement_is_implemented():
    required = [
        'visualX',
        'visualY',
        'MOVE_SPEED',
        'moveCooldown',
        'keyup',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing smooth movement implementation: {phrase}')


def test_save_load_system_is_implemented():
    required = [
        'function saveGame',
        'function loadGame',
        'localStorage.setItem',
        'localStorage.getItem',
        'pigSwineSave',
        'showSaveFlash',
        'checkLoadOnStart',
        'Game Saved!',
        'S: Save Game',
        'L: Load Game',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing save/load implementation: {phrase}')


def test_npc_post_quest_dialogue_variety():
    """NPCs should have varied dialogue for different game states (pre/during/post quest)."""
    # New phrases for during-quest states (when player has partial progress)
    required_phrases = [
        # Muraś during-quest: player has law binder but not rights memo
        'binder is heavy',
        'gravity',
        # Rak during-quest: spotting evidence
        'eyes sharp',
        'evidence and coffee',
        # Wymysl during-quest: strategy forming
        'theory brewing',
        'chaos to case',
        # Clerk during-quest: pre-court advice
        'binder, the rights memo',
        'calm face',
        # Mr. Pig post-court victory
        'toner',
        'fax about this victory',
        # Tram Oracle additional wisdom
        'deadlines are nearer',
        'exchange rate',
    ]
    for phrase in required_phrases:
        check(phrase in HTML, f'missing NPC dialogue variety: {phrase}')


def test_quest_tracking_is_fixed():
    required = [
        'if(state.quests.court) return',
        'if(state.quests.rights && !state.quests.court) return',
        'if(state.quests.law && !state.quests.rights) return',
        'if(state.quests.friends && !state.quests.law) return',
        'if(state.quests.guide && !state.quests.friends) return',
        'saveGame()',  # Check that saveGame is called in onTalk
    ]
    for phrase in required:
        check(phrase in HTML, f'missing quest tracking fix: {phrase}')


def test_pixel_portraits_implemented():
    required = [
        'function drawPortrait',
        'drawPortrait(npcId, x, y)',
        'hasPortrait = !!state.activeDialog.npcId',
        'drawPortrait(state.activeDialog.npcId, 90, 480)',
        'npcId === \'pig\'',
        'npcId === \'muras\'',
        'npcId === \'rak\'',
        'npcId === \'wymysl\'',
        'npcId === \'clerk\'',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing pixel portrait implementation: {phrase}')

def test_coffee_mini_game_is_implemented():
    """Coffee mini-game: brew coffee to reduce Procedural Anxiety."""
    required = [
        'coffeeMachine',
        'function startCoffeeMiniGame',
        'function drawCoffeeMiniGame',
        'function resolveCoffeeMiniGame',
        'Coffee brewed!',
        'Coffee spilled!',
        'brewCount',
        'brewTimer',
        'Procedural Anxiety',
        'clickBrewButton',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing coffee mini-game implementation: {phrase}')

def test_sound_system_is_implemented():
    """Sound effects for UI interactions and quest milestones."""
    required = [
        'function playSound',
        'AudioContext',
        'toggleBgMusic',
        'toggleMute',
        'initAudio',
        'playSound(\'docket\')',
        'playSound(\'casebag\')',
        'playSound(\'badge\')',
        'playSound(\'move\')',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing sound system implementation: {phrase}')

def test_enhanced_npc_post_quest_dialogue():
    """Enhanced post-quest dialogue with character-specific humor and running jokes."""
    required_phrases = [
        # Mr. Pig post-quest: printer joke, financial relief
        'toner for the printer',
        'plotting against us',
        # Muraś post-quest: dry summary, knows too much
        '40 pages',
        'summarize: you were great',
        # Rak post-quest: observant, evidence + coffee
        'Evidence from the case is filed',
        'coffee mug is chipped',
        # Wymysl post-quest: chaotic, glitter bomb
        'legal theory holds',
        'human rights glitter bomb',
        # Court Clerk post-quest: gatekeeper, stamped copy joke
        'court record is closed',
        'lose the stamped copy',
    ]
    for phrase in required_phrases:
        check(phrase in HTML, f'missing enhanced NPC post-quest dialogue: {phrase}')

def test_day_two_client_ms_nowak():
    """Day Two client Ms. Nowak with new legal puzzle setup."""
    required = [
        'Ms. Nowak',
        'nowak',  # NPC id
        "npcId === 'nowak'",  # Portrait support
        'eviction notice',  # Legal issue from dialogue
        'Day Two',
        'nowakCase',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing Day Two client Ms. Nowak: {phrase}')


def test_nowak_court_puzzle_implemented():
    """Ms. Nowak eviction case needs court puzzle with evidence and choices."""
    required = [
        'startNowakCourtChoice',
        'function drawNowakCourtChoice',
        'function resolveNowakCourt',
        'leaseAgreement',
        'humanRightsPoster',
        'landlordNotice',
        'Polish lease law',
        'NOWAK CASE RESULT',
        'Firm Liquidity: +',
        '30',
        'Bar Reputation: +',
        '5',
        'Mr. Swine is skiing in Japan',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing Ms. Nowak court puzzle: {phrase}')

def test_rak_nowak_evidence_hint():
    """Rak gives evidence hints for Nowak case as the fact specialist."""
    required = [
        'nowakCase',  # Rak should have dialogue for Nowak case
        'lease agreement',  # Evidence hint 1
        'human rights poster',  # Evidence hint 2
        'landlord notice',  # Evidence hint 3
        'missing annex',  # Rak's sharp/observant character trait
        'evidence and coffee',  # Existing Rak line to confirm character voice
    ]
    for phrase in required:
        check(phrase in HTML, f'missing Rak Nowak evidence hint: {phrase}')

def test_wymysl_nowak_strategy_hint():
    """Wymysl gives legal strategy hints for Nowak case as the argument specialist."""
    required = [
        'nowakCase',  # Wymysl should have dialogue for Nowak case
        'Polish lease law',  # Legal strategy hint 1
        'human rights defense',  # Legal strategy hint 2
        'Article 2 of Protocol 1',  # Human rights legal basis
        'chaotic but clever',  # Wymysl's character trait (inventive, ironic, chaotic)
        'theory brewing',  # Existing Wymysl line to confirm character voice
    ]
    for phrase in required:
        check(phrase in HTML, f'missing Wymysl Nowak strategy hint: {phrase}')

def test_nowak_evidence_items_in_world():
    """Nowak evidence items placed in game world: Lease Agreement (office), Human Rights Poster (cafe), Landlord Notice (from Nowak)."""
    required = [
        # Item definitions in items array (match actual format)
        "id:'leaseAgreement', x:11, y:4",  # Lease Agreement in office
        "id:'humanRightsPoster', x:18, y:14",  # Human Rights Poster in Coffee Shop
        # Landlord Notice given by Nowak directly (not a world item)
        'Landlord Eviction Notice received from Ms. Nowak',
        # Item labels for player-facing text
        'Lease Agreement',
        'Human Rights Poster',
        # Nowak evidence tracking in state
        'nowakEvidence',
        'lease: false',
        'poster: false',
        'notice: false',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing Nowak evidence item in world: {phrase}')


def test_day_two_overlays_track_nowak_evidence():
    """Docket and Case Bag should guide Day Two by showing Nowak case objectives and collected evidence."""
    required = [
        'DOCKET: Day Two — Nowak Eviction Defense',
        'nowakQuestSteps',
        'Evidence checklist',
        'Lease Agreement (office)',
        'Human Rights Poster (cafe)',
        'Landlord Notice (from Ms. Nowak)',
        'Nowak evidence: ${nowakEvidenceCount()}/3',
        'function nowakEvidenceCount',
        'Housing is a human right',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing Day Two overlay evidence tracking: {phrase}')


def test_playtest_regressions_fixed():
    """User playtest findings: incidents must not spam, correct options must vary, text must clip safely, portraits must be larger."""
    required = [
        'incidentCooldown',
        'Math.random() < 0.03',
        "state.lastIncidentId",
        'No default answer',
        'writeWrapped(text,x,y,maxWidth,lineHeight,color,maxLines=99)',
        'ctx.scale(2,2)',
        "{correct:false, text:'Because Pig & Swine has a difficult financial situation",
        "{ text: 'Mr. Swine is skiing in Japan and sends his apologies",
        'areaAt(player.x, player.y)',
        'Pig & Swine Office',
        'Archive Interior',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing playtest regression fix: {phrase}')

def test_dialogue_choices_implemented():
    """NPCs should offer 2-3 player-selectable dialogue topics, not just auto-cycling lines."""
    required = [
        # Core dialogue choice system
        'dialogTopics',
        'function drawDialogTopics',
        'function selectDialogTopic',
        'activeTopicIdx',
        # At least some NPC-specific topic labels (funny/character-specific)
        'Ask about Mr. Swine',
        'Ask about the printer',
        'Ask about coffee',
        # Player can navigate topics with arrow keys
        'ArrowUp',
        'ArrowDown',
        # Topic selection closes or advances dialogue
        'selectDialogTopic',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing dialogue choices implementation: {phrase}')


def test_quest_gated_dialogue_topics():
    """NPCs should have a quest-aware 'Ask about the case' topic that changes based on current quest progress."""
    required = [
        # Core mechanism: function that returns contextual topics based on quest state
        'function getContextualTopics',
        # Quest-gated case topic label
        'Ask about the case',
        # Muraś gives law-binder hint before player collects it
        'Find the Polish law binder',
        # Rak gives evidence hint when nowakCase active
        'lease agreement in the office',
        # Wymysl gives strategy hint when nowakCase active
        'Article 2 of Protocol 1',
        # Mr. Pig gives financial pressure hint early
        'Firm Liquidity is dangerously low',
        # Generic fallback for case topic when no active quest
        'all quiet on the legal front',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing quest-gated dialogue topics: {phrase}')


if __name__ == '__main__':
    tests = [test_new_campaign_cast_is_present, test_new_story_beats_are_present, test_new_quest_flags_exist, test_interaction_markers_are_implemented, test_docket_overlay_is_implemented, test_case_bag_overlay_is_implemented, test_mr_pig_opening_scene_is_implemented, test_court_argument_choice_is_implemented, test_court_result_screen_is_implemented, test_smooth_movement_is_implemented, test_save_load_system_is_implemented, test_quest_tracking_is_fixed, test_pixel_portraits_implemented, test_coffee_mini_game_is_implemented, test_sound_system_is_implemented, test_enhanced_npc_post_quest_dialogue, test_day_two_client_ms_nowak, test_nowak_court_puzzle_implemented, test_rak_nowak_evidence_hint, test_wymysl_nowak_strategy_hint, test_nowak_evidence_items_in_world, test_day_two_overlays_track_nowak_evidence, test_playtest_regressions_fixed, test_dialogue_choices_implemented, test_quest_gated_dialogue_topics]
    for test in tests:
        test()
    print(f'{len(tests)} story checks passed')
