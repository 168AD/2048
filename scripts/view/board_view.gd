extends Node2D
class_name BoardView

@export var entry: PackedScene
@export var entries = {}

var row = 4
var column = 4
var x_start = 224.0
var y_start = 14.0
var offset = 128.0

func _ready() -> void:
	_create_entries()
	
func update_grid(board: Array):
	for i in row:
		for j in column:
			var entry0: Entry = entries[Vector2(i, j)]
			entry0.value = board[i][j]

func _create_entries():
	for i in row:
		for j in column:
			var temp: Entry = entry.instantiate()
			add_child(temp)
			temp.position = _entry_position(Vector2(i, j))
			entries[Vector2(i, j)] = temp

func _entry_position(pos: Vector2):
	var new_x = x_start + offset * pos.y
	var new_y = y_start + offset * pos.x
	
	return Vector2(new_x, new_y)
