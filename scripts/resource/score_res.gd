extends GameRes
class_name ScoreRes

@export var score: int
@export var history: int
@export var highest: int

signal score_updated(new_socre: int)
signal highest_updated(new_highest: int)

func score_update(x: int):
	score += x
	score_updated.emit(score)
	if score > highest:
		highest = score
		highest_updated.emit(highest)
	
func save_history():
	history = score
	
func undo():
	score = history
	score_updated.emit(score)

func new_game():
	score = 0
	history = 0
	score_updated.emit(score)

func load_initial() -> void:
	score_updated.emit(score)
	highest_updated.emit(highest)
