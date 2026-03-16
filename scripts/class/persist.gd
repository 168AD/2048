extends Node2D
class_name Persist

#@export var resource: Resource

func _enter_tree() -> void:
	add_to_group("Persist")
	GlobalLogger.info("持久化节点" + self.name + "已加载", "存档")

func _exit_tree() -> void:
	var resource = _save()
	if resource == null:
		return
	GlobalSave.save_to_manager(self.get_path(), resource)

func _save() -> Resource:
	return null
	
func _load(_res: Resource) -> bool:
	return true
