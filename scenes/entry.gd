extends Node2D
class_name Entry

@export var value: int = 0:
	set(x):
		value = x
		label.visible = x != 0
		label.text = str(x)
		
var position_in_grid: Vector2
var move_to_position: Vector2

@onready var label: Label = $Label

#func get_value() -> int:
	#return value
