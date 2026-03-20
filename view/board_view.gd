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
	match direction:
		"left":
			_move_left(board)
		"right":
			_move_right(board)
		"up":
			_move_up(board)
		"down":
			_move_down(board)
			
	_move_animate()

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
			new_entries[Vector2(entry0.move_to_position)] = entry0
			if entry0.value == 0:
				entry0.position = move_to_position
				continue
			tween.tween_property(entry0, "position", move_to_position, MOVE_DURATION)
	
	entries = new_entries

#region 移动坐标计算
func _move_left(board: Array):
	for i in row:
		var zero_entries = []
		var index = 0
		for j in column:
			var entry0: Entry = entries[Vector2(i, j)]
			if entry0.value == 0:
				zero_entries.append(entry0)
				continue
			elif entry0.value != board[i][index]:
				entry0.value = board[i][index]
				var entry_next: Entry = entries[Vector2(i, min(j+1, 3))]
				entry_next.value = 0
			entry0.move_to_position = Vector2(i, index)
			index += 1
		for entry0 in zero_entries:
			entry0.value = 0
			entry0.move_to_position = Vector2(i, index)
			index += 1
			
func _move_right(board: Array):
	for i in row:
		var zero_entries = []
		var index = column - 1
		for j in range(column - 1, -1, -1):
			var entry0: Entry = entries[Vector2(i, j)]
			if entry0.value == 0:
				zero_entries.append(entry0)
				continue
			elif entry0.value != board[i][index]:
				entry0.value = board[i][index]
				var entry_next: Entry = entries[Vector2(i, max(j-1, 0))]
				entry_next.value = 0
			entry0.move_to_position = Vector2(i, index)
			index -= 1
		for entry0 in zero_entries:
			entry0.value = 0
			entry0.move_to_position = Vector2(i, index)
			index -= 1
			
func _move_up(board: Array):
	for j in column:
		var zero_entries = []
		var index = 0
		for i in row:
			var entry0: Entry = entries[Vector2(i, j)]
			if entry0.value == 0:
				zero_entries.append(entry0)
				continue
			elif entry0.value != board[index][j]:
				entry0.value = board[index][j]
				var entry_next: Entry = entries[Vector2(min(i+1, 3), j)]
				entry_next.value = 0
			entry0.move_to_position = Vector2(index, j)
			index += 1
		for entry0 in zero_entries:
			entry0.value = 0
			entry0.move_to_position = Vector2(index, j)
			index += 1
			
func _move_down(board: Array):
	for j in column:
		var zero_entries = []
		var index = row - 1
		for i in range(row - 1, -1, -1):
			var entry0: Entry = entries[Vector2(i, j)]
			if entry0.value == 0:
				zero_entries.append(entry0)
				continue
			elif entry0.value != board[index][j]:
				entry0.value = board[index][j]
				var entry_next: Entry = entries[Vector2(max(i-1, 0), j)]
				entry_next.value = 0
			entry0.move_to_position = Vector2(index, j)
			index -= 1
		for entry0 in zero_entries:
			entry0.value = 0
			entry0.move_to_position = Vector2(index, j)
			index -= 1
#endregion
