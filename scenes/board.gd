extends Persist

@onready var board_view: BoardView = $HBox/BoardView
@onready var input_manager: InputManager = $InputManager
@onready var score: Score = $HBox/VBox/Score
@onready var new_game: Button = $HBox/VBox/NewGame

@export var board_res: BoardRes

var pending_directions := []

#region 存读档
func save_res() -> GameRes:
	return board_res
	
func load_res(_res: GameRes) -> void:
	if _res is BoardRes:
		board_res = _res
	else:
		GlobalLogger.warning("无相应棋盘资源", "存档")
		board_res = BoardRes.new()
		board_res.new_game()
	
	_connect_signals()
	board_res.load_initial()
#endregion

func game_over():
	GlobalLogger.info("游戏结束")

func _on_move_requested(direction: String):
	if board_view.is_animating:
		pending_directions.append(direction)
		return
		
	score.save_history()
	board_view.direction = direction
	board_res.move(direction)
	
func _on_new_game_requested():
	#await SceneManager.fade_out_started
	pending_directions.clear()
	if board_view.is_animating:
		await board_view.animation_finished
	board_res.new_game()
	score.new_game()
	
func _on_undo_requested():
	score.undo()
	board_res.undo()
	
func _on_animation_finished():
	if pending_directions.is_empty():
		return
	var direction = pending_directions.pop_front()
	_on_move_requested(direction)

func _connect_signals():
	input_manager.move_requested.connect(_on_move_requested)
	input_manager.undo_requested.connect(_on_undo_requested)

	if not board_res.board_initial.is_connected(board_view.grid_initial):
		board_res.board_initial.connect(board_view.grid_initial)
	if not board_res.move_processed.is_connected(board_view._on_move_processed):
		board_res.move_processed.connect(board_view._on_move_processed)
	if not board_res.merge_happened.is_connected(score.score_update):
		board_res.merge_happened.connect(score.score_update)
	if not board_res.game_over.is_connected(game_over):
		board_res.game_over.connect(game_over)
	
	new_game.button_up.connect(_on_new_game_requested)
	
	#localization.language_update.connect(score.language_update)
	
	board_view.animation_finished.connect(_on_animation_finished)
	
	GlobalLogger.info("---游戏启动---")
