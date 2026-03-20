extends Node2D
class_name BoardView

@export var entry: PackedScene
@export var entries = {}
@export var direction: String

const MOVE_DURATION := 0.1

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

func move_grid(board: Array):
	if direction == "left":
		for i in row:
			var zero_entries = []
			var index = 0
			for j in column:
				var entry0: Entry = entries[Vector2(i, j)]
				if entry0.value == 0:
					zero_entries.append(entry0)
					continue
				elif entry0.value != board[i][index]:
					var entry_next: Entry = entries[Vector2(i, min(j+1, 3))]
					entry_next.value = 0
				entry0.move_to_position = Vector2(i, index)
				index += 1
			for entry0 in zero_entries:
				entry0.value = 0
				entry0.move_to_position = Vector2(i, index)
				index += 1
	
	_move_animate()
	
func _generate_tranverse_set() -> Array:
	var tranverse_set = []
	if direction == "left" or direction == "up":
		for i in row:
			tranverse_set.append(i)
	else:
		for i in row:
			tranverse_set.append(3-i)
			
	return tranverse_set

func _create_entries():
	for i in row:
		for j in column:
			var temp: Entry = entry.instantiate()
			add_child(temp)
			temp.position = _entry_position(Vector2(i, j))
			temp.position_in_grid = Vector2(i, j)
			entries[Vector2(i, j)] = temp

func _entry_position(pos: Vector2):
	var new_x = x_start + offset * pos.y
	var new_y = y_start + offset * pos.x
	
	return Vector2(new_x, new_y)

func _move_animate():
	var tween = create_tween()
	tween.set_parallel(true)
	
	var new_entries = {}
	for i in row:
		for j in column:
			var entry0: Entry = entries[Vector2(i, j)]
			var move_to_position = _entry_position(entry0.move_to_position)
			tween.tween_property(entry0, "position", move_to_position, MOVE_DURATION)
			new_entries[Vector2(entry0.move_to_position)] = entry0
	
	entries = new_entries
