extends Control
class_name Entry

@export var value: int = 0:
	set(x):
		value = x
		label.visible = x != 0
		label.text = str(x)
		update_background_color()
		update_font_size()

var position_in_grid: Vector2
var move_to_position: Vector2

@onready var label: Label = $Label
@onready var background_panel: Panel = $Panel

func update_background_color() -> void:
	var color = get_color_by_value(value)
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = color
	stylebox.set_corner_radius_all(8)
	stylebox.border_color = Color(1,1,1)
	stylebox.border_width_bottom = 1.0
	stylebox.border_width_left = 1.0
	stylebox.border_width_right = 1.0
	stylebox.border_width_top = 1.0
	background_panel.add_theme_stylebox_override("panel", stylebox)

func update_font_size() -> void:
	var font_size = 64 if value < 1024 else 48
	if value > 8192:
		font_size = 32
	label.add_theme_font_size_override("font_size", font_size)

func get_color_by_value(val: int) -> Color:
	match val:
		2: return Color("#C7E9FB")
		4: return Color("#A3D8F4")
		8: return Color("#7BC4E8")
		16: return Color("#5AADE0")
		32: return Color("#3F95D4")
		64: return Color("#2A7FC4")
		128: return Color("#1E6BAE")
		256: return Color("#175A96")
		512: return Color("#124C7E")
		1024: return Color("#0E3F66")
		2048: return Color("#0B3350")
		4096: return Color("#4A2A8C")
		8192: return Color("#5E2A9E")
		16384: return Color("#722AB0")
		32768: return Color("#862AC2")
		65536: return Color("#9A2AD4")
		_: return Color("#9A2AD4")
