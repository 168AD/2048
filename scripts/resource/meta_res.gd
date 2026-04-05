extends Resource
class_name MetaRes

@export var slot: int
@export var version: String
@export var time_stamp: String

#视游戏实际情况编写存档摘要内容
@export var score: int
@export var highest: int

func create_meta(save_res: SaveRes):
	version = save_res.version
	time_stamp = save_res.time_stamp
	
	score = 0
	highest = 0
	for res in save_res.save_dict.values():
		GlobalLogger.info("遍历存档文件", "摘要")
		if res is ScoreRes:
			score = res.score
			highest = res.highest
			GlobalLogger.info("生成摘要，分数：%d，最高分%d" % [score, highest])
			break
