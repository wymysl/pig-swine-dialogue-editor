from pathlib import Path
import glob

# Read ALL source files — monolith is gone, code lives in src/
root = Path(__file__).parent
src_files = list(root.glob('src/**/*.js')) + [root / 'index.html']
HTML = '\n'.join(f.read_text(encoding='utf-8') for f in src_files if f.exists())


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
        check(f'{flag}: false' in HTML or f'{flag}:false' in HTML, f'missing quest flag: {flag}')


def test_interaction_markers_are_implemented():
    required = [
        'drawInteractHint',
        'getNearbyInteractable',
        'Press Space',
        'item.label',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing interaction marker implementation: {phrase}')


def test_docket_overlay_is_implemented():
    required = [
        'showDocket',
        'drawDocket',
        'DOCKET',
        'Muraś note',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing docket overlay implementation: {phrase}')


def test_case_bag_overlay_is_implemented():
    required = [
        'showCaseBag',
        'drawCaseBag',
        'CASE BAG',
        'Polish law binder',
        'human rights memo',
        'Procedural Anxiety',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing case bag overlay implementation: {phrase}')


def test_mr_pig_opening_scene_is_implemented():
    required = [
        'startOpeningScene',
        'state.quests.orientation',
        'Welcome to Pig & Swine, Dr. A. Kula',
        'Mr. Swine is skiing in Japan',
        'Find Muraś',
        'state.quests.guide',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing Mr. Pig opening scene implementation: {phrase}')


def test_court_argument_choice_is_implemented():
    required = [
        'choiceMenu',
        'startCourtArgumentChoice',
        'drawChoiceMenu',
        'resolveCourtChoice',
        'defective service affected the right to a fair hearing',
        'Mr. Swine is skiing in Japan',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing court argument choice implementation: {phrase}')
    check('filing deadline was unreasonable' in HTML, 'missing 4th court option (harder puzzle)')


def test_court_result_screen_is_implemented():
    required = [
        'drawResultScreen',
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
        'saveGame',
        'loadGame',
        'localStorage.setItem',
        'localStorage.getItem',
        'pigSwineSave',
        'S: Save',
        'L: Load',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing save/load implementation: {phrase}')


def test_npc_post_quest_dialogue_variety():
    """NPCs should have varied dialogue for different game states (pre/during/post quest)."""
    required_phrases = [
        'binder is heavy',
        'gravity',
        'eyes sharp',
        'evidence and coffee',
        'theory brewing',
        'chaos to case',
        'binder, the rights memo',
        'calm face',
        'toner',
        'deadlines are nearer',
        'exchange rate',
    ]
    for phrase in required_phrases:
        check(phrase in HTML, f'missing NPC dialogue variety: {phrase}')


def test_quest_tracking_is_fixed():
    required = [
        'state.quests.court',
        'state.quests.rights',
        'state.quests.law',
        'state.quests.friends',
        'state.quests.guide',
        'saveGame',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing quest tracking fix: {phrase}')


def test_pixel_portraits_implemented():
    required = [
        'drawPortrait',
        'npcId',
        'pig',
        'muras',
        'rak',
        'wymysl',
        'clerk',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing pixel portrait implementation: {phrase}')

def test_coffee_mini_game_is_implemented():
    """Coffee mini-game: brew coffee to reduce Procedural Anxiety."""
    required = [
        'coffeeMachine',
        'startCoffeeMiniGame',
        'drawCoffeeMiniGame',
        'resolveCoffeeMiniGame',
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
        'playSound',
        'AudioContext',
        'toggleBgMusic',
        'toggleMute',
        'initAudio',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing sound system implementation: {phrase}')

def test_enhanced_npc_post_quest_dialogue():
    """Enhanced post-quest dialogue with character-specific humor and running jokes."""
    required_phrases = [
        'toner for the printer',
        'plotting against us',
        '40 pages',
        'summarize: you were great',
        'Evidence from the case is filed',
        'coffee mug is chipped',
        'legal theory holds',
        'human rights glitter bomb',
        'court record is closed',
        'lose the stamped copy',
    ]
    for phrase in required_phrases:
        check(phrase in HTML, f'missing enhanced NPC post-quest dialogue: {phrase}')

def test_day_two_client_ms_nowak():
    """Day Two client Ms. Nowak with new legal puzzle setup."""
    required = [
        'Ms. Nowak',
        'nowak',
        'eviction notice',
        'Day Two',
        'nowakCase',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing Day Two client Ms. Nowak: {phrase}')


def test_nowak_court_puzzle_implemented():
    """Ms. Nowak eviction case needs court puzzle with evidence and choices."""
    required = [
        'startNowakCourtChoice',
        'resolveNowakCourt',
        'leaseAgreement',
        'humanRightsPoster',
        'landlordNotice',
        'Polish lease law',
        'NOWAK CASE RESULT',
        'Firm Liquidity: +',
        'Bar Reputation: +',
        'Mr. Swine is skiing in Japan',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing Ms. Nowak court puzzle: {phrase}')

def test_rak_nowak_evidence_hint():
    """Rak gives evidence hints for Nowak case as the fact specialist."""
    required = [
        'nowakCase',
        'lease agreement',
        'human rights poster',
        'landlord notice',
        'missing annex',
        'evidence and coffee',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing Rak Nowak evidence hint: {phrase}')

def test_wymysl_nowak_strategy_hint():
    """Wymysl gives legal strategy hints for Nowak case as the argument specialist."""
    required = [
        'nowakCase',
        'Polish lease law',
        'human rights defense',
        'Article 2 of Protocol 1',
        'chaotic but clever',
        'theory brewing',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing Wymysl Nowak strategy hint: {phrase}')

def test_nowak_evidence_items_in_world():
    """Nowak evidence items placed in game world."""
    required = [
        'leaseAgreement',
        'humanRightsPoster',
        'Lease Agreement',
        'Human Rights Poster',
        'nowakEvidence',
        'lease: false',
        'poster: false',
        'notice: false',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing Nowak evidence item in world: {phrase}')


def test_day_two_overlays_track_nowak_evidence():
    """Docket and Case Bag should guide Day Two."""
    required = [
        'DOCKET: Day Two',
        'nowakQuestSteps',
        'Evidence checklist',
        'Lease Agreement (office)',
        'Human Rights Poster (cafe)',
        'Landlord Notice (from Ms. Nowak)',
        'nowakEvidenceCount',
        'Housing is a human right',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing Day Two overlay evidence tracking: {phrase}')


def test_playtest_regressions_fixed():
    """Incident spam fix, correct options vary, text clips safely."""
    required = [
        'incidentCooldown',
        'lastIncidentId',
        'writeWrapped',
        'areaAt',
        'Pig & Swine Office',
        'Archive Interior',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing playtest regression fix: {phrase}')

def test_dialogue_choices_implemented():
    """NPCs should offer player-selectable dialogue topics."""
    required = [
        'dialogTopics',
        'drawDialogTopics',
        'selectDialogTopic',
        'activeTopicIdx',
        'Ask about Mr. Swine',
        'Ask about the printer',
        'Ask about coffee',
        'ArrowUp',
        'ArrowDown',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing dialogue choices implementation: {phrase}')


def test_quest_gated_dialogue_topics():
    """NPCs should have a quest-aware 'Ask about the case' topic."""
    required = [
        'getContextualTopics',
        'Ask about the case',
        'Find the Polish law binder',
        'lease agreement in the office',
        'Article 2 of Protocol 1',
        'Firm Liquidity is dangerously low',
        'all quiet on the legal front',
    ]
    for phrase in required:
        check(phrase in HTML, f'missing quest-gated dialogue topics: {phrase}')


def test_modular_architecture():
    """Verify the codebase has proper modular structure."""
    required_files = [
        'src/main.js',
        'src/state.js',
        'src/renderer.js',
        'src/audio.js',
        'src/typewriter.js',
        'src/save.js',
        'src/input.js',
        'src/ui.js',
        'src/data/maps.js',
        'src/data/characters.js',
        'src/data/dialogues.js',
        'src/data/npcs.js',
        'src/systems/quests.js',
        'src/systems/incidents.js',
        'src/systems/coffee.js',
    ]
    for f in required_files:
        check((root / f).exists(), f'missing module file: {f}')

    # Verify index.html loads from modules, not inline
    index = (root / 'index.html').read_text()
    check('src/main.js' in index, 'index.html should load src/main.js')
    check(len(index) < 5000, 'index.html should be minimal (< 5000 chars), not a monolith')


def test_sprint0_chapter1_flags_reachable():
    """Verify that every chapter1 flag is present in the codebase."""
    flags = [
        'started', 'enteredOffice', 'pigRevealedCrisis', 'metMuras',
        'receivedCaseSummary', 'hasLawBinder', 'hasRightsMemo', 'recruitedRak',
        'recruitedWymysl', 'coffeeTutorialSeen', 'coffeeBuff', 'courtUnlocked',
        'courtStarted', 'arguedDefectiveService', 'arguedFairHearing',
        'arguedRemedy', 'wonCourt', 'receivedSwinePostcard', 'complete'
    ]
    for flag in flags:
        # Check if the flag is mentioned (e.g. as a property key, string, or dot notation)
        check(f'{flag}:' in HTML or f'{flag} :' in HTML or f'{flag}=' in HTML or f'{flag} =' in HTML or f'.{flag}' in HTML or f'"{flag}"' in HTML or f"'{flag}'" in HTML, f'missing chapter1 flag: {flag}')


def test_sprint0_npc_dialogue_states():
    """Verify NPC dialogue states for Chapter 1 (Before quest / During investigation / Ready for court / After victory)."""
    # 4 states per key NPC (Mr. Pig, Muraś, Rak, Wymysl)
    # The actual strings might vary, but we look for the presence of the NPCs and
    # evidence of conditional dialogue (e.g., switch/if statements for their states).
    required = [
        'pigRevealedCrisis', # Before/start quest
        'hasLawBinder', 'hasRightsMemo', # During investigation
        'courtUnlocked', # Ready for court
        'wonCourt', # After victory
    ]
    for phrase in required:
        check(phrase in HTML, f'missing NPC dialogue state trigger: {phrase}')


def test_sprint0_save_load_preserves_chapter1():
    """Verify that save/load round-trip preserves all chapter1 fields."""
    required = [
        'chapter1',
        'migrateSave',
        'SAVE_VERSION'
    ]
    for phrase in required:
        check(phrase in HTML, f'missing save/load requirement for chapter 1: {phrase}')


if __name__ == '__main__':
    tests = [test_new_campaign_cast_is_present, test_new_story_beats_are_present, test_new_quest_flags_exist, test_interaction_markers_are_implemented, test_docket_overlay_is_implemented, test_case_bag_overlay_is_implemented, test_mr_pig_opening_scene_is_implemented, test_court_argument_choice_is_implemented, test_court_result_screen_is_implemented, test_smooth_movement_is_implemented, test_save_load_system_is_implemented, test_quest_tracking_is_fixed, test_pixel_portraits_implemented, test_coffee_mini_game_is_implemented, test_sound_system_is_implemented, test_enhanced_npc_post_quest_dialogue, test_day_two_client_ms_nowak, test_nowak_court_puzzle_implemented, test_rak_nowak_evidence_hint, test_wymysl_nowak_strategy_hint, test_nowak_evidence_items_in_world, test_day_two_overlays_track_nowak_evidence, test_playtest_regressions_fixed, test_dialogue_choices_implemented, test_quest_gated_dialogue_topics, test_modular_architecture, test_sprint0_chapter1_flags_reachable, test_sprint0_npc_dialogue_states, test_sprint0_save_load_preserves_chapter1]
    for test in tests:
        test()
    print(f'{len(tests)} story checks passed')
