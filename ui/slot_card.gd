extends Control

@onready var title: Label = $VBoxContainer/Title
@onready var score: Label = $VBoxContainer/Score
@onready var highest: Label = $VBoxContainer/Highest
@onready var time_stamp: Label = $VBoxContainer/TimeStamp

var slot: int
var selected: bool = false

signal slot_selected(slot_id: int)
#signal new_game_requested(slot_id: int)

func _ready() -> void:
	setup(1, GlobalSave.get_slot_meta(1))

func setup(slot_id: int, meta: MetaRes):
	await self.ready
	
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

func _on_gui_requested(event):
	if selected:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		selected = true
		slot_selected.emit(slot)
		get_tree().change_scene_to_file("res://scenes/board.tscn")
		GlobalLogger.info("选择存档%d" % slot, "存档选择")
