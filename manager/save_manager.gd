extends Node2D
class_name SaveManager

# signal slot_changes

@export var save_resource: SaveRes
@export var saves_meta: AllSlotsRes
@export var version: String = "0.1"
@export var slot: int = 1

const SAVE_PATH: String = "user://sav%d.tres"
const BACK_PATH: String = "user://sav%d_bak.tres"
const TEMP_PATH: String = "user://sav%d_tmp.tres"
const META: String = "user://meta%s.tres"

#func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed("ui_accept"):
		#save_data()

func _ready() -> void:
	load_meta()
	load_data(slot)

func _exit_tree() -> void:
	save_data()

#region 存档
func save_data() -> void:
	# 1.保存当前数据
	var data_dict = save_resource.save_dict
	for node in get_tree().get_nodes_in_group("Persist"):
		if not node.has_method("save_res"):
			GlobalLogger.warning("节点 %s 误入Persist组" % node.name, "存档")
			continue
			
		var data = node.save_res()
		if data:
			data_dict[node.get_path()] = data
		else:
			GlobalLogger.warning("节点 %s 返回空存档数据" % node.name, "存档")
	
	save_resource.time_stamp = Time.get_date_string_from_system()
	save_resource.version = version

	# 2.保存存档
	var result = save_files(save_resource, SAVE_PATH % slot, BACK_PATH % slot, TEMP_PATH % slot)
	if not result:
		return
	
	# 3.生成存档摘要
	saves_meta.update_slot(slot, save_resource)
	
	# 4.保存存档摘要
	if not save_files(saves_meta, META % "", META % "_bak", META % "_tmp"):
		GlobalLogger.warning("摘要文件保存失败，但存档保存成功", "存档")

func save_files(res: Resource, save_path: String, backup_path: String, temp_path: String) -> bool:
	# 1.新建临时存档
	#var temp_path = path % ".temp"
	GlobalLogger.debug("临时存档路径" + temp_path, "存档")
	var temp_err = ResourceSaver.save(res, temp_path)
	if temp_err == OK:
		GlobalLogger.debug("临时存档保存成功", "存档")
	else:
		GlobalLogger.error("临时存档保存失败！错误码： %d" % temp_err , "存档")
		push_error("临时存档保存失败，存档中止！", temp_err)
		return false

	# 2.删除旧备份存档
	#var backup_path = path % ".bak"
	GlobalLogger.debug("临时旧备份路径" + backup_path, "存档")
	if FileAccess.file_exists(backup_path):
		var del_err = DirAccess.remove_absolute(backup_path)
		if del_err == OK:
			GlobalLogger.debug("删除旧备份成功", "存档")
		else:
			GlobalLogger.warning("删除旧备份失败，错误码：%d" % del_err, "存档")
	
	# 3.重命名旧存档
	#var save_path = path % ""
	GlobalLogger.debug("存档路径" + save_path, "存档")
	if FileAccess.file_exists(save_path):
		var rename_err = DirAccess.rename_absolute(save_path, backup_path)
		if rename_err == OK:
			GlobalLogger.debug("重命名旧存档为备份存档成功", "存档")
		else:
			GlobalLogger.warning("重命名旧存档为备份存档失败，存档取消！错误码 %d" % rename_err, "存档")
			return false

	# 4.重命名临时存档
	var result = DirAccess.rename_absolute(temp_path, save_path)
	if result == OK:
		GlobalLogger.debug("临时存档重命名成功", "存档")
		GlobalLogger.info("存档成功", "存档")
		return true
	else:
		GlobalLogger.error("临时存档重命名失败，存档可能丢失，错误码： %d" % result, "存档")
		if not FileAccess.file_exists(backup_path):
			GlobalLogger.error("备份存档丢失，无法恢复！", "存档")
			push_error("备份存档丢失，无法恢复！")

		var err = DirAccess.rename_absolute(backup_path, save_path)
		if err != OK:
			GlobalLogger.error("恢复备份失败，存档可能丢失！", "存档")
			push_error("恢复备份存档失败")
		else:
			GlobalLogger.info("已从备份恢复存档", "存档")
			if FileAccess.file_exists(temp_path):
				DirAccess.remove_absolute(temp_path)
			
		return false
	
func save_to_manager(path: String, res: Resource) -> void:
	save_resource.save_dict[path] = res
		
#endregion

#region 读档
func load_meta() -> void:
	var meta_path = META % ""
	if ResourceLoader.exists(meta_path):
		var saved_saves_meta = ResourceLoader.load(meta_path) as AllSlotsRes
		if saved_saves_meta:
			saves_meta = saved_saves_meta
			GlobalLogger.info("存档摘要读取成功", "存档")
			return
		
	saves_meta = AllSlotsRes.new()
	GlobalLogger.info("新建存档摘要", "存档")

func load_data(slot_id: int) -> void:
	slot = slot_id
	var save_path = SAVE_PATH % slot
	if ResourceLoader.exists(save_path):
		var saved_data = ResourceLoader.load(save_path) as SaveRes
		if saved_data:
			save_resource = _version_migrate(saved_data)
			GlobalLogger.info("读取存档成功", "存档")
			return
	
	save_resource = SaveRes.new()
	GlobalLogger.info("新建存档文件", "存档")

func get_from_manager(path: String) -> Resource:
	if save_resource.save_dict.has(path):
		return save_resource.save_dict[path]
	else:
		GlobalLogger.warning("未查询到" + path + "请求的数据", "存档")
		return null

func get_slot_meta(slot_id: int) -> MetaRes:
	return saves_meta.get_slot_meta(slot_id)
	
#endregion

func _version_migrate(resource: SaveRes) -> SaveRes:
	var ver = resource.version
	if ver != version:
		match ver:
			"0.0":
				resource.save_dict.erase("/root/GameManager/Score")
				resource.save_dict.erase("/root/GameManager/BoardManager")
				resource.save_dict.erase("/root/Score")
				resource.version = "0.1"
				resource = _version_migrate(resource)
				
			"0.1":
				if resource.has_meta("time_tamp"):
					resource.time_stamp = resource.time_tamp
				
	return resource
	
