extends Node

@onready var world := %World
@onready var spawn_positions: Array = $World/PlayerSpawnPositions.get_children()

var Player_tscn: PackedScene = preload("res://src/player.tscn")

func _ready():
	spawn_players()

func spawn_players():
	if not multiplayer.is_server():
		return
	for i in range(Networking.players.size()):
		add_player(i, Networking.players[i])

func add_player(i, player_info: PlayerInfo):
	var player = Player_tscn.instantiate()
	player.name = player_info.peer_id
	world.add_child(player)
	player.set_label.rpc(player_info.name)
	player.global_position = spawn_positions[i].global_position
