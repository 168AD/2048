extends Node2D
class_name SaveManager

const SAVE_DIR: String = "user://save"
const SAVE_FILE_PATH: String = "user://save/sav.tres"
const SAVE_BACKUP_PATH: String = "user://save/sav_backup.tres"
const SAVE_TEMP_PATH: String = "user://save/sav_temp.tres"

@export var save_resource: SaveRes
@export var version: String = "0.0"

func _ready() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		var err = DirAccess.make_dir_absolute(SAVE_DIR)
		if err != OK:
			GlobalLogger.warning("存档目录创建失败", "存档")
			
	_load()

func _exit_tree() -> void:
	_save()

#region 存档
func _save() -> void:
	var data_dict = save_resource.save_dict
	for node in get_tree().get_nodes_in_group("Persist"):
		if not node.has_method("_save"):
			GlobalLogger.warning("节点" + node.name + "误入Persist组", "存档")
			continue
			
		var data = node._save()
		if data:
			data_dict[node.get_path()] = data
		else:
			GlobalLogger.warning("节点" + node.name + "返回空存档数据", "存档")
			
	save_resource.time_tamp = Time.get_date_string_from_system()
	save_resource.version = version
	
	var result = ResourceSaver.save(save_resource, SAVE_TEMP_PATH)
	if result == OK:
		GlobalLogger.info("临时存档保存成功", "存档")
	else:
		GlobalLogger.error("临时存档保存失败！", "存档")
		push_error("临时存档保存失败！", result)
	
	if FileAccess.file_exists(SAVE_BACKUP_PATH):
		var err = DirAccess.remove_absolute(SAVE_BACKUP_PATH)
		if err != OK:
			GlobalLogger.warning("删除旧备份失败，可能影响存档轮替", "存档")
	
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var err = DirAccess.rename_absolute(SAVE_FILE_PATH, SAVE_BACKUP_PATH)
		if err != OK:
			GlobalLogger.warning("重命名旧存档为备份存档失败", "存档")
	
	var rename_err = DirAccess.rename_absolute(SAVE_TEMP_PATH, SAVE_FILE_PATH)
	if rename_err != OK:
		GlobalLogger.error("临时存档重命名失败，存档可能丢失", "存档")
		return
	
	GlobalLogger.info("存档成功", "存档")
	
func save_to_manager(path: String, res: Resource) -> void:
	save_resource.save_dict[path] = res
#endregion

func _load() -> void:
	if not ResourceLoader.exists(SAVE_FILE_PATH):
		return 
		
	var save_data = ResourceLoader.load(SAVE_FILE_PATH) as SaveRes
	if save_data:
		save_resource = save_data
	else:
		GlobalLogger.error("读档失败！", "读档")

func get_from_manager(path: String) -> Resource:
	if save_resource.save_dict.has(path):
		return save_resource.save_dict[path]
	else:
		GlobalLogger.warning("未查询到" + path + "请求的数据", "存档")
		return null
