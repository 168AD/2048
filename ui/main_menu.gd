extends Control
class_name MainMenu

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_start_pressed():
	animation_player.play("start_game")

func _on_exit_pressed():
	get_tree().quit()
