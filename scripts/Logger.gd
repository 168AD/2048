extends Node

enum Level {
	DEBUG = 0,
	INFO = 1,
	WARNING = 2,
	ERROR = 3
}

const LOG_FILE_PATH = "user://log.txt"
const BACKUP_LOG_PATH = "user://log_backup.txt"
const MAX_LOG_SIZE = 1024 * 1024

var log_level = Level.INFO
var save_to_file: bool = true

var _file: FileAccess

#region 外部调用
func debug(message: String, category: String = ""):
	_log(Level.DEBUG, message, category)

func info(message: String, category: String = ""):
	_log(Level.INFO, message, category)

func warning(message: String, category: String = ""):
	_log(Level.WARNING, message, category)

func error(message: String, category: String = ""):
	_log(Level.ERROR, message, category)
	
#endregion

func _ready():
	if not save_to_file:
		return
		
	_file = FileAccess.open(LOG_FILE_PATH, FileAccess.READ_WRITE)
	if _file and _file.get_length() < MAX_LOG_SIZE:
		_file.seek_end()
	else:
		var rotated = _rotate_log()
		_file = FileAccess.open(LOG_FILE_PATH, FileAccess.WRITE)
		if rotated:
			_file.store_line("--- 日志轮转于 " + Time.get_datetime_string_from_system() + " ---")
	
	if not _file:
		push_error("无法创建日志文件，错误代码：", FileAccess.get_open_error())
		
func _exit_tree():
	if _file and _file.is_open():
		_file.close()
		
func _log(level: int, message: String, category: String = ""):
	if level < log_level:
		return
	
	var level_str = ["DEBUG", "INFO", "WARNING", "ERROR"][level]
	var timestamp = Time.get_datetime_string_from_system()
	var prefix = "[%s] [%s]" % [timestamp, level_str]
	if category:
		prefix += " [%s]" % category
	
	var full_message = "%s %s" % [prefix, message]
	
	print(full_message)
	
	if _file and _file.is_open():
		_file.store_line(full_message)
		if level == Level.ERROR:
			_file.flush()  # 确保立即写入，便于崩溃后查看

func _rotate_log() -> bool:
	if not _file or not _file.is_open():
		return false
	
	var err
	_file.close()
	if FileAccess.file_exists(BACKUP_LOG_PATH):
		err = DirAccess.remove_absolute(BACKUP_LOG_PATH)
		if err != OK:
			push_error("删除旧日志失败，错误码：" + err)
	
	err = DirAccess.rename_absolute(LOG_FILE_PATH, BACKUP_LOG_PATH)
	if err != OK:
		push_error("重命名旧文件失败，错误码：" + err)
		_file = FileAccess.open(LOG_FILE_PATH, FileAccess.WRITE)
		if _file:
			_file.seek_end()
		return false
		
	return true
