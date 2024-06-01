extends Control
func onPlayPressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/character_select.tscn")

func onQuitPressed() -> void:
	get_tree().quit()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
