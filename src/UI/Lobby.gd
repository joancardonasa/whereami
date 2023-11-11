extends Control

@onready var host_button : Button = $Panel/MarginContainer/VBoxContainer/VBoxContainer2/HostButton
@onready var join_button : Button = $Panel/MarginContainer/VBoxContainer/VBoxContainer2/JoinButton
@onready var games_list : VBoxContainer = $Panel/MarginContainer/VBoxContainer/VBoxContainer2/GamesList
@onready var game_discovery = $GameDiscovery

var Lobby_GameInstance = preload("res://UI/Lobby_GameInstance.tscn")

func _ready():
	host_button.pressed.connect(_on_HostButton_pressed)
	join_button.pressed.connect(_on_JoinButton_pressed)
	game_discovery.games_refreshed.connect(_on_games_refreshed)

func _on_HostButton_pressed():
	game_discovery.register_game()

func _on_JoinButton_pressed():
	pass

func _on_games_refreshed(games: Array[GameInfo]):
	games_list.clear()
	for game in games:
		var game_info = Lobby_GameInstance.instance()
		game_info.set_info()
		games_list.add_child(game_info)

