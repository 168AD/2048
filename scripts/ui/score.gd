extends Persist
class_name Score

@export var score_res: ScoreRes
@onready var score_display: Label = $Container/ScoreDisplay
		
func save_data() -> Resource:
	return score_res

func load_data(_res: Resource) -> bool:
	if _res is ScoreRes:
		score_res = _res
		score_display.text = str(score_res.score)
		return true
	else:
		GlobalLogger.warning("无相应分数资源", "存档")
		return false

func score_update(x: int):
	score_res.score += x
	score_display.text = str(score_res.score)
	if score_res.score > score_res.highest:
		score_res.highest = score_res.score
	
func save_history():
	score_res.history = score_res.score
	
func undo():
	score_res.score = score_res.history
	score_display.text = str(score_res.score)

func new_game():
	score_res.score = 0
	score_display.text = str(score_res.score)
