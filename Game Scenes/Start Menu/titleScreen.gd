extends Control

@onready var play_button: Button = %PlayButton

@export var game_scene_path: String = "Game Scenes/Game Settings/game_settings.tscn"

@export var tutorial_scene_path: String = "Game Scenes/Tutorial/tutorial.tscn"


func on_play_pressed() -> void:
	_transition(game_scene_path)


func on_quit_pressed() -> void:
	get_tree().quit()


func on_tutorial_pressed() -> void:
	_transition(tutorial_scene_path)


# Use threaded loading with sub threads to preload the game scene
# Might be better to implement a loading screen that 
# conditionally displays if the resource hasn't loaded when we transition to it
# Subthreads can be toggled off by setting the third argument to false. 
# Won't hold up the main thread, but will be slower.
# Loading screen + no subthreads might be the best combo for low-end hardware

func _init() -> void:
		ResourceLoader.load_threaded_request(game_scene_path, "PackedScene", true)
		ResourceLoader.load_threaded_request(tutorial_scene_path, "PackedScene", true)


func _transition(scene_path: String) -> void:
	BackgroundMusic.crossfade_to(BackgroundMusic.get_child(1).stream)
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(scene_path))

	

# Called when the node enters the scene tree for the first time.
func _ready():
	play_button.grab_focus()
	BackgroundMusic.get_child(0).play()
