extends Resource
class_name GameInfo

@export var name: String = "Game Name"
@export var ip: String = "127.0.0.1"

func _init(game_name: String, game_ip: String):
    self.name = game_name
    self.ip = game_ip
