extends Node

@onready var player_name_entry: LineEdit = %PlayerNameEntry

@onready var host_button: Button = %HostButton
@onready var refresh_button: Button  = %RefreshButton
@onready var play_local_host: Button = %PlayLocalHost
@onready var play_local_client: Button = %PlayLocalClient

@onready var game_discovery: GameDiscovery = $GameDiscovery
@onready var game_entries_container: VBoxContainer = %GameEntriesContainer
@onready var error_label : Label = $CanvasLayer/MainMenu/ErrorLabel


var game_name_entry = preload("res://src/UI/lobby_game_name_entry.tscn")

func _ready():
	player_name_entry.text_changed.connect(_on_player_name_entry_text_changed)
	host_button.disabled = true
	refresh_button.disabled = true

	host_button.pressed.connect(func(): game_discovery.register_game(player_name_entry.text))
	refresh_button.pressed.connect(_on_refresh_button_pressed)
	play_local_host.pressed.connect(Networking.host)
	play_local_client.pressed.connect(func(): Networking.join("localhost"))
	Networking.full_game.connect(_on_Networking_full_game)

	game_discovery.game_registered.connect(_on_game_discovery_game_registered)
	game_discovery.games_refreshed.connect(_on_game_discovery_games_refreshed)
	game_discovery.error.connect(func(error: String): error_label.text = error)

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

func _on_Networking_full_game():
	get_tree().change_scene_to_file("res://src/gameplay/game.tscn")
