extends CanvasLayer
## BattleScreen — minimal UI controller for legal encounters.

@onready var _phase_label: Label = $PhaseLabel
@onready var _cooperation_bar: ProgressBar = $CooperationBar
@onready var _patience_bar: ProgressBar = $PatienceBar
@onready var _cooperation_value_label: Label = $CooperationValueLabel
@onready var _patience_value_label: Label = $PatienceValueLabel


func _ready() -> void:
	_cooperation_bar.show_percentage = false
	_patience_bar.show_percentage = false
	_refresh_resource_labels()


func set_phase_label(text: String) -> void:
	_phase_label.text = text


func set_witness_cooperation(value: int, maximum: int = 10) -> void:
	_set_bar_value(_cooperation_bar, value, maximum)
	_refresh_resource_labels()


func set_judicial_patience(value: int, maximum: int = 10) -> void:
	_set_bar_value(_patience_bar, value, maximum)
	_refresh_resource_labels()


func _set_bar_value(bar: ProgressBar, value: int, maximum: int) -> void:
	bar.max_value = max(1, maximum)
	bar.value = clamp(value, 0, int(bar.max_value))


func _refresh_resource_labels() -> void:
	_cooperation_value_label.text = "%d/%d" % [int(_cooperation_bar.value), int(_cooperation_bar.max_value)]
	_patience_value_label.text = "%d/%d" % [int(_patience_bar.value), int(_patience_bar.max_value)]
