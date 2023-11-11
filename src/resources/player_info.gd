extends Resource
class_name PlayerInfo

@export var name: String 
@export var peer_id: String
@export var isHost: bool

func _init(player_name: String, player_peer_id: int, player_isHost: bool):
    self.name = player_name
    self.peer_id = str(player_peer_id)
    self.isHost = player_isHost
