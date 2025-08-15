extends Control

@onready var resume: Button = %Resume

func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("ui_accept")):
		var focused_element = get_viewport().gui_get_focus_owner();
		if (focused_element is Button):
			focused_element.pressed.emit()


func open() -> void:
	get_tree().paused = true
	show()
	resume.grab_focus()


func close() -> void:
	hide()
	get_tree().paused = false


func _on_main_menu_pressed() -> void:
	global.playerInfo = null
	for child in BackgroundMusic.get_children():
		if (child is AudioStreamPlayer):
			child.stop()
	
	BackgroundMusic.get_child(0).volume_db = -12
	BackgroundMusic.get_child(0).play()
	close()
	get_tree().change_scene_to_file("res://Game Scenes/Start Menu/Start.tscn")


func _on_resume_pressed() -> void:
	close()
