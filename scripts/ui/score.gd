extends Control
class_name Score

var score: int = 0
var history: int = 0

@onready var score_display: Label = $Container/ScoreDisplay

#func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed("ui_accept"):
		#score_update(2)

func score_update(x: int):
	score += x
	score_display.text = str(score)
	
func save():
	history = score
	
func undo():
	score = history
	score_display.text = str(score)

func new_game():
	score = 0
	score_display.text = str(score)
