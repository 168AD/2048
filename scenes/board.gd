extends Persist

@onready var board_view: BoardView = $BoardView
@onready var input_manager: InputManager = $InputManager
@onready var score: Score = $Score
@onready var new_game: Button = $NewGame
@onready var localization: Button = $Localization

@export var board_res: BoardRes

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
	score.save_history()
	board_view.direction = direction
	board_res.move(direction)
	
func _on_undo_requested():
	score.undo()
	board_res.undo()

func _connect_signals():
	input_manager.move_requested.connect(_on_move_requested)
	input_manager.undo_requested.connect(_on_undo_requested)

	if not board_res.board_updated.is_connected(board_view.update_grid):
		board_res.board_updated.connect(board_view.update_grid)
	if not board_res.board_moved.is_connected(board_view.move_grid):
		board_res.board_moved.connect(board_view.move_grid)
	if not board_res.board_created.is_connected(board_view.update_grid):
		board_res.board_created.connect(board_view.update_grid)
	if not board_res.merge_happened.is_connected(score.score_update):
		board_res.merge_happened.connect(score.score_update)
	if not board_res.game_over.is_connected(game_over):
		board_res.game_over.connect(game_over)
	
	new_game.pressed.connect(board_res.new_game)
	new_game.pressed.connect(score.new_game)
	
	localization.language_update.connect(score.language_update)
	
	GlobalLogger.info("---游戏启动---")
