extends Node
class_name Network

@export var PORT = 9999
@export var MAX_CLIENTS = 2

var enet_peer = ENetMultiplayerPeer.new()
var players : Array[int] = []

signal full_game

func host():
	enet_peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = enet_peer
	players.append(enet_peer.get_unique_id())
	multiplayer.peer_connected.connect(_on_peer_connected)

func join(ip: String):
	enet_peer.create_client(ip, PORT)
	players.append(enet_peer.get_unique_id())
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(_on_peer_connected)

func _on_peer_connected(id):
	players.append(id) 
	if players.size() == MAX_CLIENTS:
		emit_signal("full_game")

