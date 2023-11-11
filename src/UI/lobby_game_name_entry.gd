extends HBoxContainer
class_name LobbyGameNameEntry

@onready var game_name_label: Label = $GameNameLabel
@onready var join_button: Button = $Button

var game_info: GameInfo

signal joined_game(game_info: GameInfo)

func _ready():
    join_button.pressed.connect(_on_join_button_pressed)

func _set_game_info(game_info: GameInfo):
    self.game_info = game_info
    game_name_label.text = game_info.name

func _on_join_button_pressed():
    if !game_info: return
    joined_game.emit(game_info)
