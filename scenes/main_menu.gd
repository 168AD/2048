extends Control
class_name MainMenu

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var start: Button = $VBoxContainer/Start


func _on_start_pressed():
	animation_player.play("start_game")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		animation_player.play("RESET")
		start.grab_focus()
