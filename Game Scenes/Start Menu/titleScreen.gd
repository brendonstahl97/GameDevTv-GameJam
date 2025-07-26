extends Control
func onPlayPressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/character_select.tscn")
	BackgroundMusic.crossfade_to(BackgroundMusic.get_child(1).stream)

func onQuitPressed() -> void:
	get_tree().quit()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	BackgroundMusic.get_child(0).play()
	pass
