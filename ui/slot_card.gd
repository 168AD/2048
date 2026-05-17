extends Control
class_name SlotCard


@export_category("Scene Manager Options")

@export var scene: String

@export_group("Fade Out Options")
@export var fade_out_speed: float = 1.0
@export var fade_out_pattern: String = "fade"
@export var fade_out_inverted: bool = false
@export_range(0.0, 1.0, 0.1) var fade_out_smoothness = 0.1

@export_group("Fade In Options")
@export var fade_in_speed: float = 1.0
@export var fade_in_pattern: String = "fade"
@export var fade_in_inverted: bool = false
@export_range(0.0, 1.0, 0.1) var fade_in_smoothness = 0.1

@export_group("General Options")
@export var color: Color = Color(0, 0, 0)
@export var timeout: float = 1.0
@export var clickable: bool = false
@export var add_to_back: bool = true


@onready var fade_out_options = SceneManager.create_options(fade_out_speed, fade_out_pattern, fade_out_smoothness, fade_out_inverted)
@onready var fade_in_options = SceneManager.create_options(fade_in_speed, fade_in_pattern, fade_in_smoothness, fade_in_inverted)
@onready var general_options = SceneManager.create_general_options(color, timeout, clickable, add_to_back)

@onready var title: Label = $HBoxContainer/Title
@onready var score: Label = $HBoxContainer/Score
@onready var highest: Label = $HBoxContainer/Highest
@onready var time_stamp: Label = $HBoxContainer/TimeStamp
@onready var button: Button = $Button

var slot: int
var selected: bool = false

signal slot_selected(slot_id: int)
#signal new_game_requested(slot_id: int)

#func _ready() -> void:
	#setup(1, GlobalSave.get_slot_meta(1))

func setup(slot_id: int, meta: MetaRes):
	slot = slot_id
	title.text = tr("KEY_SLOT") + str(slot_id)
	if meta:
		score.text = tr("KEY_SCORE") + ": %d" % meta.score
		highest.text = tr("KEY_HIGHEST") + ": %d" % meta.highest
		time_stamp.text = tr("KEY_TIME") + ": %s" % meta.time_stamp
	else:
		score.text = tr("KEY_SCORE") + ": --"
		highest.text = tr("KEY_HIGHEST") + ": --"
		time_stamp.text = tr("KEY_TIME") + ": --"
	
	gui_input.connect(_on_gui_requested)
	slot_selected.connect(GlobalSave.load_data)

func slot_on():
	button.grab_focus()

func _on_gui_requested(event):
	if selected:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		load_slot()
		
func load_slot():
	if selected:
		return
		
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
	selected = true
	slot_selected.emit(slot)
	SceneManager.change_scene(scene, fade_out_options, fade_in_options, general_options)
	GlobalLogger.info("选择存档%d" % slot, "存档选择")
