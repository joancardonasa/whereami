extends Node
class_name Network

@export var PORT = 9999
@export var MAX_CLIENTS = 2

var enet_peer = ENetMultiplayerPeer.new()
var players : Array[PlayerInfo] = []

signal full_game

func host():
	enet_peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = enet_peer
	players.append(PlayerInfo.new(
		"Host",
		enet_peer.get_unique_id(),
		true
	))
	multiplayer.peer_connected.connect(_on_peer_connected)

func join(ip: String):
	enet_peer.create_client(ip, PORT)
	multiplayer.multiplayer_peer = enet_peer
	players.append(PlayerInfo.new(
		"Client",
		enet_peer.get_unique_id(),
		false
	))
	multiplayer.peer_connected.connect(_on_peer_connected)

func _on_peer_connected(id):
	players.append(PlayerInfo.new(
		"Client",
		id,
		!multiplayer.is_server()
	))
	if players.size() == MAX_CLIENTS:
		emit_signal("full_game")

