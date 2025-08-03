extends Control

@export var character_select_screen: PackedScene
@onready var play_button: Button = %PlayButton

func onPlayPressed() -> void:
	BackgroundMusic.crossfade_to(BackgroundMusic.get_child(1).stream)
	get_tree().change_scene_to_packed(character_select_screen)

func onQuitPressed() -> void:
	get_tree().quit()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	play_button.grab_focus()
	BackgroundMusic.get_child(0).play()
	pass
