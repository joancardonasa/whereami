extends Node

@onready var main_menu := $CanvasLayer/MainMenu
@onready var world := %World

@onready var host_button := %HostButton
@onready var join_button := %JoinButton
@onready var address_entry := %AddressEntry

@onready var spawn_positions: Array = $World/PlayerSpawnPositions.get_children()

var Player_tscn: PackedScene = preload("res://src/player.tscn")

const PORT: int = 9999
var enet_peer = ENetMultiplayerPeer.new()


func _ready():
	if not is_multiplayer_authority(): return
	host_button.pressed.connect(_on_host_button_pressed)
	join_button.pressed.connect(_on_join_button_pressed)

func _on_host_button_pressed():
	main_menu.hide()
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	add_player(multiplayer.get_unique_id())

func add_player(peer_id):
	var player = Player_tscn.instantiate()
	player.name = str(peer_id)
	world.add_child(player)
	player.global_position = spawn_positions[0].global_position

func _on_join_button_pressed():
	main_menu.hide()
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer

