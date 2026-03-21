extends Node2D
class_name BoardView

@export var entry: PackedScene
@export var entries = {}
@export var direction: String

var is_animating := false

const MOVE_DURATION := 0.1

var row = 4
var column = 4
var x_start = 224.0
var y_start = 14.0
var offset = 128.0
	
func grid_initial(board: Array):
	if entries:
		for pos in entries.keys():
			entries[pos].queue_free()
	
	for i in row:
		for j in column:
			if board[i][j] == 0:
				continue
				
			var temp: Entry = entry.instantiate()
			add_child(temp)
			var pos = _entry_position(Vector2(i, j))
			temp.position_in_grid = Vector2(i, j)
			temp.position = pos
			temp.value = board[i][j]
			entries[Vector2(i, j)] = temp

func _entry_position(pos: Vector2):
	var new_x = x_start + offset * pos.y
	var new_y = y_start + offset * pos.x
	
	return Vector2(new_x, new_y)
	
func _on_move_processed(moves: Array, merges: Array, spawn: Dictionary):
	if is_animating:
		return
	
	is_animating = true
	var tween = create_tween()
	tween.set_parallel(true)
	
	for move in moves:
		var entry0 = entries.get(move.from)
		if entry0 == null:
			continue
		var target_pos = _entry_position(move.to)
		tween.tween_property(entry0, "position", target_pos, MOVE_DURATION)
	
	for merge in merges:
		var from_entry = entries.get(merge.from)
		var to_entry = entries.get(merge.to)
		if from_entry and to_entry:
			var target_pos = _entry_position(merge.to)
			tween.tween_property(from_entry, "position", target_pos, MOVE_DURATION)
			tween.tween_property(from_entry, "modulate:a", 0.0, MOVE_DURATION)
			var scale_tween = create_tween()
			scale_tween.tween_property(to_entry, "scale", Vector2(1.2, 1.2), MOVE_DURATION/2)
			scale_tween.tween_property(to_entry, "scale", Vector2(1.0, 1.0), MOVE_DURATION/2)
			to_entry.value = merge.new_value
			
	if spawn:
		var spawn_entry = entries.get(spawn.pos)
		if spawn_entry:
			spawn_entry.value = spawn.value
			spawn_entry.modulate = Color(1,1,1,0)
			tween.tween_property(spawn_entry, "modulate:a", 1.0, MOVE_DURATION)
		
	await tween.finished
	
	var new_entries = {}
	var to_delete = []
	for move in moves:
		var entry0: Entry = entries.get(move.from)
		if entry0 == null:
			continue
		entry0.position_in_grid = move.to
		new_entries[move.to] = entry0
		GlobalLogger.info("从" + str(move.from) + "到" + str(move.to), "BoardView")
		
	for merge in merges:
		var from_entry: Entry = entries.get(merge.from)
		var to_entry: Entry = new_entries.get(merge.to)
		if from_entry and to_entry:
			to_delete.append(from_entry)
			to_entry.position_in_grid = merge.to
			new_entries[merge.to] = to_entry
		else:
			GlobalLogger.warning("合并时找不到格子", "BoardView")
	
	if spawn:
		var spawn_entry: Entry = entries.get(spawn.pos)
		if spawn_entry:
			spawn_entry.position_in_grid = spawn.pos
			new_entries[spawn.pos] = spawn_entry
	
	for pos in entries:
		var entry0 = entries[pos]
		if entry0 in new_entries.values():
			continue
		if entry0 in to_delete:
			continue
		
		new_entries[pos] = entry0
	
	for entry0 in to_delete:
		entry0.queue_free()
		
	entries = new_entries
	
	for pos in entries.keys():
		var entry0: Entry = entries[pos]
		entry0.position = _entry_position(entry0.position_in_grid)
		
	is_animating = false
