extends Node2D
class_name InputManager

signal move_requested
signal undo_requested

func _process(_delta: float):
	if Input.is_action_just_pressed("ui_left"):
		move_requested.emit("left")
	
	if Input.is_action_just_pressed("ui_right"):
		move_requested.emit("right")
	
	if Input.is_action_just_pressed("ui_up"):
		move_requested.emit("up")
	
	if Input.is_action_just_pressed("ui_down"):
		move_requested.emit("down")
	
	if Input.is_action_just_pressed("ui_cancel"):
		undo_requested.emit()
