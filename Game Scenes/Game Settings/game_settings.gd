extends Node3D
@onready var character_select: CharacterSelectScreen = %"Character Select"

@export var main_game_scene: PackedScene
@export var main_menu_scene: PackedScene

func _ready() -> void:
	print("in Game settings scene")

func _start_game(player_choices_dictionary):
	# Set GLOBAL player info for their choices, usable anywhere.
	global.playerInfo = player_choices_dictionary
	BackgroundMusic.crossfade_to(BackgroundMusic.get_child(2).stream)
	get_tree().change_scene_to_packed(main_game_scene)


func start_game() -> void:
	_start_game(character_select.get_player_choices())


func return_to_menu() -> void:
	get_tree().change_scene_to_packed(main_menu_scene)
