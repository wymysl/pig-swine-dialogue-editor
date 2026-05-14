## scripts/ui/battle_screen.gd
##
## Casebook Battle System — Court Round UI controller.
##
## Attach to scenes/ui/battle_screen.tscn. Drives the two-phase battle UI
## by calling BattleController and reflecting its state; never reads
## State.data directly. All game-state writes flow through BattleController.
##
## Expected node structure (create in the editor):
##
##   BattleScreen (Control)
##   ├─ PhaseLabel           (Label)       — "Witness Examination" / "Closing Argument"
##   ├─ JudgeSpeechBox       (PanelContainer + Label)   — judge counter-question text
##   ├─ WitnessSpeechBox     (PanelContainer + Label)   — witness response text
##   ├─ CooperationBar       (ProgressBar)  — Phase 1 witness_cooperation remaining
##   ├─ PatienceBar          (ProgressBar)  — Phase 2 judicial_patience remaining
##   ├─ OptionsContainer     (VBoxContainer) — dynamically populated option buttons
##   └─ ResultOverlay        (Control)      — hidden until encounter ends
##       ├─ ResultLabel      (Label)
##       └─ ContinueButton   (Button)
##
## Owner: Code role (AGENTS.md §File ownership).
## TODO: wire ResultOverlay ContinueButton.pressed → Signals.battle_screen_closed.

extends Control


# ---------------------------------------------------------------------------
# Node references — fill in the editor or adjust paths to match your tscn.
# ---------------------------------------------------------------------------

@onready var phase_label: Label         = $PhaseLabel
@onready var judge_speech_box: Label    = $JudgeSpeechBox/Label
@onready var witness_speech_box: Label  = $WitnessSpeechBox/Label
@onready var cooperation_bar: ProgressBar = $CooperationBar
@onready var patience_bar: ProgressBar  = $PatienceBar
@onready var options_container: VBoxContainer = $OptionsContainer
@onready var result_overlay: Control    = $ResultOverlay
@onready var result_label: Label        = $ResultOverlay/ResultLabel
@onready var continue_button: Button    = $ResultOverlay/ContinueButton


# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------

var _controller: BattleController = null

## _round_path — set before add_child / show.
var round_path: String = ""


# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
    result_overlay.hide()
    if round_path != "":
        start_battle(round_path)


## start_battle — create a BattleController, load the round, and begin.
## Call this if you set round_path after _ready, or directly.
func start_battle(path: String) -> void:
    if _controller != null:
        _controller.queue_free()

    _controller = BattleController.new()
    add_child(_controller)

    if not _controller.load_round(path):
        push_error("BattleScreen.start_battle: failed to load round '%s'" % path)
        return

    _controller.start()
    _refresh_ui()


# ---------------------------------------------------------------------------
# UI refresh
# ---------------------------------------------------------------------------

func _refresh_ui() -> void:
    if _controller == null:
        return
    var snap: Dictionary = _controller.get_battle_state_snapshot()
    var phase: int = snap.get("current_phase", BattleController.Phase.IDLE)

    match phase:
        BattleController.Phase.PHASE1_WITNESS:
            _show_phase1(snap)
        BattleController.Phase.PHASE2_CLOSING:
            _show_phase2(snap)
        BattleController.Phase.RESULT:
            _show_result(snap)
        _:
            pass


func _show_phase1(snap: Dictionary) -> void:
    phase_label.text = "Witness Examination"
    cooperation_bar.visible = true
    patience_bar.visible    = false
    judge_speech_box.get_parent().hide()
    witness_speech_box.get_parent().show()

    var coop_max: int = _controller._round_data.get("phase1", {}) \
        .get("witness_cooperation_max", 6)
    cooperation_bar.max_value = coop_max
    cooperation_bar.value     = snap.get("witness_cooperation_remaining", 0)

    ## Populate options for the current witness.
    _clear_options()
    var witnesses: Array = _controller._round_data.get("phase1", {}).get("witnesses", [])
    var wi: int = snap.get("current_witness_index", 0)
    if wi < witnesses.size():
        var witness: Dictionary = witnesses[wi]
        witness_speech_box.text = witness.get("intro_line", "")
        for opt in witness.get("options", []):
            _add_option_button(
                opt.get("label", opt.get("id", "?")),
                func(): _on_witness_option_pressed(wi, opt.get("id", ""))
            )


func _show_phase2(snap: Dictionary) -> void:
    phase_label.text = "Closing Argument"
    cooperation_bar.visible = false
    patience_bar.visible    = true
    witness_speech_box.get_parent().hide()
    judge_speech_box.get_parent().show()

    var jp_max: int = _controller._round_data.get("phase2", {}) \
        .get("judicial_patience_max", 10)
    patience_bar.max_value = jp_max
    patience_bar.value     = snap.get("judicial_patience_remaining", 0)

    var cqs: Array = _controller._round_data.get("phase2", {}) \
        .get("counter_questions", [])
    var cq_idx: int = snap.get("current_cq_index", 0)
    if cq_idx < cqs.size():
        judge_speech_box.text = cqs[cq_idx].get("judge_line", "")

    ## Populate available citations.
    _clear_options()
    for cit in _controller.get_available_citations():
        _add_option_button(
            "%s — %s" % [cit.get("judgment", "?"), cit.get("principle", "?")],
            func(): _on_citation_pressed(cit.get("id", ""))
        )


func _show_result(snap: Dictionary) -> void:
    _clear_options()
    result_overlay.show()
    var outcome: String = snap.get("outcome", "loss")
    var outcomes: Dictionary = _controller._round_data.get("phase2", {}) \
        .get("outcomes", {})
    var branch: Dictionary = outcomes.get(outcome, {})
    result_label.text = branch.get("result_text", outcome.capitalize())


# ---------------------------------------------------------------------------
# Option button helpers
# ---------------------------------------------------------------------------

func _clear_options() -> void:
    for child in options_container.get_children():
        child.queue_free()


func _add_option_button(label_text: String, callback: Callable) -> void:
    var btn := Button.new()
    btn.text = label_text
    btn.pressed.connect(callback)
    options_container.add_child(btn)


# ---------------------------------------------------------------------------
# Input handlers
# ---------------------------------------------------------------------------

func _on_witness_option_pressed(witness_index: int, option_id: String) -> void:
    if _controller == null:
        return
    var result: Dictionary = _controller.submit_witness_option(witness_index, option_id)
    if result.get("success", false):
        witness_speech_box.text = result.get("response", "")
    _refresh_ui()


func _on_citation_pressed(citation_id: String) -> void:
    if _controller == null:
        return
    var result: Dictionary = _controller.submit_citation(citation_id)
    if result.get("success", false):
        ## TODO: animate result text (bucket flash, argument_strength bar update).
        judge_speech_box.text = result.get("result_text", "")
    if result.get("encounter_over", false):
        _refresh_ui()
    else:
        _refresh_ui()


func _on_continue_button_pressed() -> void:
    ## TODO: emit Signals.battle_screen_closed once signal is declared.
    hide()
