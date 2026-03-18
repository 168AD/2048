extends Node2D
class_name Persist

func _enter_tree() -> void:
	add_to_group("Persist")
	GlobalLogger.debug("持久化节点" + self.name + "已加载", "存档")
	await self.ready
	load_res(GlobalSave.get_from_manager(self.get_path()))

func _exit_tree() -> void:
	var resource = save_res()
	if resource == null:
		return
	GlobalSave.save_to_manager(self.get_path(), resource)
	
#@export var res_class: GDScript
#@export var res: GameRes

func save_res() -> GameRes:
	#return res
	push_error("持久化节点%s未实现返回资源函数" % self.name)
	return null
	
func load_res(_res: GameRes) -> void:
	#if _res is res_class:
		#res = _res
	#else:
		#GlobalLogger.warning("无%s所请求的资源" % self.name, "存档")
		#res = res_class.new()
		#res.new_game()
	#
	#_connect_signals()
	#res.load_initial()
	push_error("持久化节点%s未实现加载资源函数" % self.name)

func _connect_signals():
	push_error("持久化节点实例未实现连接信号函数")
