extends Node

@onready var player_name_entry: LineEdit = %PlayerNameEntry

@onready var host_button: Button = %HostButton
@onready var refresh_button: Button  = %RefreshButton

@onready var game_discovery: GameDiscovery = $GameDiscovery
@onready var game_entries_container: VBoxContainer = %GameEntriesContainer

var game_name_entry = preload("res://src/UI/lobby_game_name_entry.tscn")

func _ready():
	player_name_entry.text_changed.connect(_on_player_name_entry_text_changed)
	host_button.disabled = true
	refresh_button.disabled = true

	host_button.pressed.connect(game_discovery.register_game)
	refresh_button.pressed.connect(_on_refresh_button_pressed)

	game_discovery.game_registered.connect(_on_game_discovery_game_registered)
	game_discovery.games_refreshed.connect(_on_game_discovery_games_refreshed)

func _on_player_name_entry_text_changed(new_text: String):
	host_button.disabled = !new_text or new_text == ""
	refresh_button.disabled = !new_text or new_text == ""

func _on_refresh_button_pressed():
	game_discovery.obtain_games()

func _on_game_discovery_game_registered():
	pass

func _on_game_discovery_games_refreshed(games: Array[GameInfo]):
	for game in games:
		var game_entry : LobbyGameNameEntry = game_name_entry.instantiate()
		game_entries_container.add_child(game_entry)
		game_entry.joined_game.connect(game_discovery.join_game)
		game_entry.set_game_info(game)
