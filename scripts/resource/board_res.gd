extends Resource
class_name BoardRes

signal board_updated
signal merge_happened
signal game_over

@export var board = []
@export var board_history = []
@export var board_future = {}
@export var add_entry_future = {}

var row = 4
var column = 4

func new_game():
	for i in row:
		for j in column:
			board[i][j] = 0
	
	board_history = []
	board_future = {}
	add_entry_future = {}
	_add_entry_to_grid(2)
	GlobalLogger.info("新游戏开始")

func load_initial():
	if board.is_empty():
		board = _create_space_array()
		_add_entry_to_grid(2)
	board_updated.emit(board)

func undo():
	if not board_history:
		return
	board = board_history.duplicate(true)
	board_updated.emit(board)

func move(direction: String):
	var pre_board_history = board.duplicate(true)
	#for i in row:
		#print(board_history[i])
	#print("-----------------")
	var result
	match direction:
		"left":
			result = _move_left()
			
		"right":
			result = _move_right()
		
		"up":
			result = _move_up()
		
		"down":
			result = _move_down()
	
	if not result:
		return
	
	board_history = pre_board_history.duplicate(true)
	if direction in board_future and\
	board_future[direction] == board:
		var add_result = add_entry_future[direction]
		var old_x = add_result[0]
		var old_y = add_result[1]
		var value = add_result[2]
		board[old_x][old_y] = value
		board_updated.emit(board)
	else:
		if direction in board_future:
			board_future.clear()
			add_entry_future.clear()
		
		board_future[direction] = board.duplicate(true)
		var add_result = _add_entry_to_grid(1)
		add_entry_future[direction] = add_result.duplicate(true)
		
	if _game_is_over():
		game_over.emit()

func get_empty_entry() -> int:
	var res = 0
	for i in row:
		for j in column:
			if board[i][j] == 0:
				res += 1
	
	return res

func _game_is_over() -> bool:
	if get_empty_entry() > 0:
		return false
		
	for i in row:
		for j in column:
			var current = board[i][j]
			if j + 1 < column and board[i][j+1] == current:
				return false
			if i + 1 < row and board[i+1][j] == current:
				return false
	
	return true

func _create_space_array() -> Array:
	var array = []
	for i in row:
		array.append([])
		for j in column:
			array[i].append(0)
			
	return array

func _add_entry_to_grid(number: int) -> Array:
	var added_number := 0
	var result
	while added_number < number and get_empty_entry() > 0:
		var new_x = randi_range(0,3)
		var new_y = randi_range(0,3)
		if board[new_x][new_y] == 0:
			#print(new_x, new_y)
			var value = randi_range(1,2) * 2
			board[new_x][new_y] = value
			added_number += 1
			result = [new_x, new_y, value]
	
	board_updated.emit(board)
	return result

#region 移动方法
func _move_left() -> bool:
	var moved_or_merged = false
	var merged = false
	for i in row:
		var index = -1
		for j in column:
			if board[i][j] == 0:
				continue
			
			if index == -1 or merged or\
			 board[i][index] != board[i][j]:
				if index + 1 != j:
					board[i][index + 1] = board[i][j]
					board[i][j] = 0
					moved_or_merged = true
					
				index += 1
				merged = false
			else:
				board[i][index] *= 2
				board[i][j] = 0
				merged = true
				moved_or_merged = true
				merge_happened.emit(board[i][index])
	
	return moved_or_merged

func _move_right() -> bool:
	var moved_or_merged = false
	var merged = false
	for i in row:
		var index = column
		for j in range(column - 1, -1, -1):
			if board[i][j] == 0:
				continue
				
			if index == column or merged or\
			 board[i][index] != board[i][j]:
				if index - 1 != j:
					board[i][index - 1] = board[i][j]
					board[i][j] = 0
					moved_or_merged = true
					
				index -= 1
				merged = false
			else:
				board[i][index] *= 2
				board[i][j] = 0
				moved_or_merged = true
				merged = true
				merge_happened.emit(board[i][index])
	
	return moved_or_merged

func _move_up() -> bool:
	var moved_or_merged = false
	var merged = false
	for j in column:
		var index = -1
		for i in row:
			if board[i][j] == 0:
				continue
			
			var value = board[i][j]
			if index == -1 or merged or\
			 board[index][j] != value:
				if index + 1 != i:
					board[index + 1][j] = board[i][j]
					board[i][j] = 0
					moved_or_merged = true
					
				index += 1
				merged = false
			else:
				board[index][j] *= 2
				board[i][j] = 0
				moved_or_merged = true
				merged = true
				merge_happened.emit(board[index][j])
	
	return moved_or_merged

func _move_down() -> bool:
	var moved_or_merged = false
	var merged = false
	for j in column:
		var index = row
		for i in range(row - 1, -1, -1):
			if board[i][j] == 0:
				continue
			
			if index == row or merged or\
			 board[index][j] != board[i][j]:
				if index - 1 != i:
					board[index - 1][j] = board[i][j]
					board[i][j] = 0
					moved_or_merged = true
					
				index -= 1
				merged = false
			else:
				board[index][j] *= 2
				board[i][j] = 0
				moved_or_merged = true
				merged = true
				merge_happened.emit(board[index][j])
	
	return moved_or_merged
#endregion
