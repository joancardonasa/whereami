extends HBoxContainer
class_name LobbyGameNameEntry

@onready var game_name_label: Label = $GameNameLabel
@onready var join_button: Button = $Button

var game_info: GameInfo

signal joined_game(game_info: GameInfo)

func _ready():
	join_button.pressed.connect(_on_join_button_pressed)

func set_game_info(info: GameInfo):
	game_info = info
	game_name_label.text = info.name

func _on_join_button_pressed():
	if !game_info: return
	joined_game.emit(game_info)
