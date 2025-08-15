extends Control

@onready var play_button: Button = %PlayButton

func onPlayPressed() -> void:
	BackgroundMusic.crossfade_to(BackgroundMusic.get_child(1).stream)
	get_tree().change_scene_to_file("res://Game Scenes/Game Settings/game_settings.tscn")

func onQuitPressed() -> void:
	get_tree().quit()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	play_button.grab_focus()
	BackgroundMusic.get_child(0).play()
	pass
