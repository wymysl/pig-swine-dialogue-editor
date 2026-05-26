extends SceneTree
## tests/test_battle_screen_wiring.gd — structural smoke test for battle_screen.tscn.
## Verifies that the scene loads, all required UI nodes are present, and the
## public API surface (set_phase_label, set_witness_cooperation,
## set_judicial_patience) mutates the correct child nodes.
##
## Does NOT test BattleController logic — that lives in test_court_packet_scoring.gd
## and test_chapter1_motion_packet_full_path.gd.
##
## Owner: QA role (append-only; see AGENTS.md §File ownership).
##
## Usage:
##   godot --headless --path godot --script tests/test_battle_screen_wiring.gd
##   godot --headless --path godot --script tests/test_battle_screen_wiring.gd --log-file /tmp/battle_screen.log

const _SCENE_PATH := "res://scenes/ui/battle_screen.tscn"
const _SCRIPT_PATH := "res://scripts/ui/battle_screen.gd"

func _init() -> void:
	var packed: PackedScene = load(_SCENE_PATH)
	if packed == null:
		printerr("[BattleScreenTest] FAIL: could not load ", _SCENE_PATH)
		quit(1)
		return

	var screen: Node = packed.instantiate()
	get_root().add_child(screen)
	# Two frames: first fires _ready() on screen; second fires _ready() on
	# TrialRecordPanel (instantiated child, deferred one frame behind parent).
	await process_frame
	await process_frame

	# --- Root node type and script ---
	if not screen is CanvasLayer:
		printerr("[BattleScreenTest] FAIL: root node is not CanvasLayer, got ", screen.get_class())
		quit(1)
		return
	print("[BattleScreenTest] root class: ", screen.get_class(), " ✓")

	# --- Required child nodes ---
	var required_nodes: Array[String] = [
		"PhaseLabel",
		"CooperationBar",
		"CooperationValueLabel",
		"PatienceBar",
		"PatienceValueLabel",
		"JudgeSpeechBox",
		"WitnessSpeechBox",
		"OptionsContainer",
		"ResultOverlay",
		"TrialRecordPanel",
	]
	for node_name in required_nodes:
		if screen.get_node_or_null(node_name) == null:
			printerr("[BattleScreenTest] FAIL: missing child node '%s'" % node_name)
			quit(1)
			return
		print("[BattleScreenTest] node '%s' present ✓" % node_name)

	# --- Public API presence ---
	var api_methods: Array[String] = [
		"set_phase_label",
		"set_witness_cooperation",
		"set_judicial_patience",
	]
	for method_name in api_methods:
		if not screen.has_method(method_name):
			printerr("[BattleScreenTest] FAIL: battle_screen.gd missing method '%s'" % method_name)
			quit(1)
			return
		print("[BattleScreenTest] method '%s' present ✓" % method_name)

	# --- set_phase_label mutates PhaseLabel.text ---
	var phase_label: Label = screen.get_node("PhaseLabel")
	screen.set_phase_label("Phase 2 — Closing Arguments")
	if phase_label.text != "Phase 2 — Closing Arguments":
		printerr("[BattleScreenTest] FAIL: set_phase_label did not update PhaseLabel.text")
		quit(1)
		return
	print("[BattleScreenTest] set_phase_label → PhaseLabel.text updated ✓")

	# --- set_witness_cooperation mutates CooperationBar ---
	var coop_bar: ProgressBar = screen.get_node("CooperationBar")
	screen.set_witness_cooperation(3, 10)
	if int(coop_bar.value) != 3:
		printerr("[BattleScreenTest] FAIL: set_witness_cooperation(3,10) → CooperationBar.value=%d, expected 3" % int(coop_bar.value))
		quit(1)
		return
	print("[BattleScreenTest] set_witness_cooperation(3,10) → CooperationBar.value=3 ✓")

	# --- set_judicial_patience mutates PatienceBar ---
	var patience_bar: ProgressBar = screen.get_node("PatienceBar")
	screen.set_judicial_patience(7, 10)
	if int(patience_bar.value) != 7:
		printerr("[BattleScreenTest] FAIL: set_judicial_patience(7,10) → PatienceBar.value=%d, expected 7" % int(patience_bar.value))
		quit(1)
		return
	print("[BattleScreenTest] set_judicial_patience(7,10) → PatienceBar.value=7 ✓")

	# --- Clamp boundary: value above max is clamped to max ---
	screen.set_witness_cooperation(999, 10)
	if int(coop_bar.value) != 10:
		printerr("[BattleScreenTest] FAIL: over-max clamp → CooperationBar.value=%d, expected 10" % int(coop_bar.value))
		quit(1)
		return
	print("[BattleScreenTest] over-max clamp → CooperationBar.value=10 ✓")

	# --- Clamp boundary: value below zero is clamped to 0 ---
	screen.set_judicial_patience(-5, 10)
	if int(patience_bar.value) != 0:
		printerr("[BattleScreenTest] FAIL: below-zero clamp → PatienceBar.value=%d, expected 0" % int(patience_bar.value))
		quit(1)
		return
	print("[BattleScreenTest] below-zero clamp → PatienceBar.value=0 ✓")

	# --- ResultOverlay starts hidden ---
	var result_overlay: Node = screen.get_node("ResultOverlay")
	if result_overlay.visible:
		printerr("[BattleScreenTest] FAIL: ResultOverlay should start hidden")
		quit(1)
		return
	print("[BattleScreenTest] ResultOverlay.visible=false at boot ✓")

	print("[BattleScreenTest] PASS: battle_screen.tscn structure and API surface verified.")
	quit(0)
