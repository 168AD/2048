extends Button

var language_array: Array = ["zh_CN", "zh_TW", "en", "ja"]
var index: int = 0

signal language_update

func _on_pressed() -> void:
	index = (index + 1) % len(language_array)
	TranslationServer.set_locale(language_array[index])
	language_update.emit()
