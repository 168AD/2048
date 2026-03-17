extends Node2D
class_name GameManager

@onready var board_view: BoardView = $BoardView
@onready var board_manager: BoardManager = $BoardManager
@onready var input_manager: InputManager = $InputManager
@onready var score: Score = $Score
@onready var new_game: Button = $NewGame

func _ready() -> void:
	input_manager.move_requested.connect(_on_move_requested)
	
	input_manager.undo_requested.connect(_on_undo_requested)
	
	board_manager.board_updated.connect(board_view.update_grid)
	board_view.update_grid(board_manager.board)

	board_manager.merge_happened.connect(score.score_update)
	
	board_manager.game_over.connect(game_over)
	
	new_game.pressed.connect(board_manager.new_game)
	new_game.pressed.connect(score.new_game)
	
	GlobalLogger.info("---游戏启动---")

func game_over():
	GlobalLogger.info("游戏结束")

func _on_move_requested(direction: String):
	score.save_history()
	board_manager.move(direction)
	
func _on_undo_requested():
	score.undo()
	board_manager.undo()

func _exit_tree() -> void:
	GlobalLogger.info("---游戏关闭---")
