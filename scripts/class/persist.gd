extends Node2D
class_name Persist

#@export var resource: Resource

func _enter_tree() -> void:
	add_to_group("Persist")
	GlobalLogger.debug("持久化节点" + self.name + "已加载", "存档")
	await self.ready
	load_data(GlobalSave.get_from_manager(self.get_path()))

func _exit_tree() -> void:
	var resource = save_data()
	if resource == null:
		return
	GlobalSave.save_to_manager(self.get_path(), resource)

func save_data() -> Resource:
	return null
	
func load_data(_res: Resource) -> void:
	return
