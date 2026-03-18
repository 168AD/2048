extends Persist
class_name Score

@export var score_res: ScoreRes
@onready var score_display: Label = $Container/ScoreDisplay
@onready var highest_display: Label = $Container/HighestDisplay

func save_res() -> GameRes:
	return score_res
	
func load_res(_res: GameRes) -> void:
	if _res is ScoreRes:
		score_res = _res
	else:
		GlobalLogger.warning("无%s所请求的资源" % self.name, "存档")
		score_res = ScoreRes.new()
		score_res.new_game()
	
	_connect_signals()
	score_res.load_initial()

func score_display_updated(x: int) -> void:
	score_display.text = "分数：%d" % x
	
func highest_display_updated(x: int) -> void:
	highest_display.text = "最高分：%d" % x

func score_update(x: int):
	score_res.score_update(x)
	
func save_history():
	score_res.save_history()
	
func undo():
	score_res.undo()

func new_game():
	score_res.new_game()

func _connect_signals():
	if not score_res.score_updated.is_connected(score_display_updated):
		score_res.score_updated.connect(score_display_updated)
	if not score_res.highest_updated.is_connected(highest_display_updated):
		score_res.highest_updated.connect(highest_display_updated)
