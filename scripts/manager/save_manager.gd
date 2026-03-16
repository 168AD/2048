extends Node2D
class_name SaveManager

const SAVE_DIR: String = "user://save"
const SAVE_FILE_PATH: String = "user://save/sav.tres"
const SAVE_BACKUP_PATH: String = "user://save/sav_backup.tres"

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
	var rename_times = 0
	while rename_times < 3:
		var result = _rename_old_save()
		if result:
			break
			
		rename_times += 1
	
	if rename_times == 3:
		return
	
	_save_to_local()
	
func save_to_manager(path: String, res: Resource) -> void:
	save_resource.save_dict[path] = res

func _rename_old_save() -> bool:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var err = DirAccess.rename_absolute(SAVE_FILE_PATH, SAVE_BACKUP_PATH)
		if err != OK:
			GlobalLogger.warning("旧存档重命名失败", "存档")
			return false
	
	return true
	
func _save_to_local() -> bool:
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
	
	var result = ResourceSaver.save(save_resource, SAVE_FILE_PATH)
	if result == OK:
		GlobalLogger.info("存档保存成功", "存档")
		return true
	else:
		if FileAccess.file_exists(SAVE_BACKUP_PATH):
			DirAccess.rename_absolute(SAVE_BACKUP_PATH, SAVE_FILE_PATH)
			
		GlobalLogger.error("存档保存失败！", "存档")
		push_error("存档保存失败！", result)
		return false
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
