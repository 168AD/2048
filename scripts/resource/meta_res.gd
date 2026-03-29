extends Resource
class_name MetaRes

@export var slot: int
@export var version: String
@export var time_stamp: String

#视游戏实际情况编写存档摘要内容
@export var score: int
@export var highest: int

func create_summary(save_res: SaveRes):
	version = save_res.version
	time_stamp = save_res.time_stamp
	for res in save_res.save_dict:
		if res is ScoreRes:
			score = res.score
			highest = res.highest
		
		break
	
