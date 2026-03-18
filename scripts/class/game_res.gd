extends Resource
class_name GameRes


func load_initial():
	push_error("游戏资源%s未实现数据加载初始化函数" % self.name)

func new_game():
	push_error("游戏资源%s未实现新游戏数据初始化函数" % self.name)
