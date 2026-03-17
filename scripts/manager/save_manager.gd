extends Node2D
class_name SaveManager

# signal slot_changes

@export var save_resource: SaveRes
@export var version: String = "0.0"
@export var slot: int = 1

var SAVE_PATH: String = "user://sav%d.tres" % slot
var TEMP_PATH: String = "user://sav%d.tmp.tres" % slot
var BACKUP_PATH: String = "user://sav%d.bak.tres" % slot

func _ready() -> void:
	load_data()

func _exit_tree() -> void:
	save_data()

#region 存档
func save_data() -> void:
	# 1.保存当前数据
	var data_dict = save_resource.save_dict
	for node in get_tree().get_nodes_in_group("Persist"):
		if not node.has_method("save_data"):
			GlobalLogger.warning("节点 %s 误入Persist组" % node.name, "存档")
			continue
			
		var data = node.save_data()
		if data:
			data_dict[node.get_path()] = data
		else:
			GlobalLogger.warning("节点 %s 返回空存档数据" % node.name, "存档")
			
	save_resource.time_tamp = Time.get_date_string_from_system()
	save_resource.version = version

	# 2.新建临时存档
	var temp_err = ResourceSaver.save(save_resource, TEMP_PATH)
	if temp_err == OK:
		GlobalLogger.debug("临时存档保存成功", "存档")
	else:
		GlobalLogger.error("临时存档保存失败！错误码： %d" % temp_err , "存档")
		push_error("临时存档保存失败，存档中止！", temp_err)
		return

	# 3.删除旧备份存档
	if FileAccess.file_exists(BACKUP_PATH):
		var del_err = DirAccess.remove_absolute(BACKUP_PATH)
		if del_err == OK:
			GlobalLogger.debug("删除旧备份成功", "存档")
		else:
			GlobalLogger.warning("删除旧备份失败，错误码：%d" % del_err, "存档")
	
	# 4.重命名旧存档
	if FileAccess.file_exists(SAVE_PATH):
		var rename_err = DirAccess.rename_absolute(SAVE_PATH, BACKUP_PATH)
		if rename_err == OK:
			GlobalLogger.debug("重命名旧存档为备份存档成功", "存档")
		else:
			GlobalLogger.warning("重命名旧存档为备份存档失败，存档取消！错误码 %d" % rename_err, "存档")
			return

	# 5.重命名临时存档
	var result = DirAccess.rename_absolute(TEMP_PATH, SAVE_PATH)
	if result == OK:
		GlobalLogger.debug("临时存档重命名成功", "存档")
		GlobalLogger.info("存档成功", "存档")
	else:
		GlobalLogger.error("临时存档重命名失败，存档可能丢失，错误码： %d" % result, "存档")
		if not FileAccess.file_exists(BACKUP_PATH):
			GlobalLogger.error("备份存档丢失，无法恢复！", "存档")
			push_error("备份存档丢失，无法恢复！")
			return

		var err = DirAccess.rename_absolute(BACKUP_PATH, SAVE_PATH)
		if err != OK:
			GlobalLogger.error("恢复备份失败，存档可能丢失！", "存档")
			push_error("恢复备份存档失败")
			return
		else:
			GlobalLogger.info("已从备份恢复存档", "存档")
			if FileAccess.file_exists(TEMP_PATH):
				DirAccess.remove_absolute(TEMP_PATH)
	
func save_to_manager(path: String, res: Resource) -> void:
	save_resource.save_dict[path] = res
		
#endregion

func load_data() -> void:
	if not ResourceLoader.exists(SAVE_PATH):
		return 
		
	var saved_data = ResourceLoader.load(SAVE_PATH) as SaveRes
	if saved_data:
		save_resource = saved_data
	else:
		GlobalLogger.error("读档失败！", "读档")

func get_from_manager(path: String) -> Resource:
	if save_resource.save_dict.has(path):
		return save_resource.save_dict[path]
	else:
		GlobalLogger.warning("未查询到" + path + "请求的数据", "存档")
		return null
