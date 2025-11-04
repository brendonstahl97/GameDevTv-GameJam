extends Control

@export_file("*json") var scene_text_file: String
@export var text_display_speed: float = 100 ## The speed at which text will be displayed in characters per second

@onready var text_label: Label = %Text
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var chef_hat: Node3D = %Chef_Hat # This should probably be modular?

var scene_text := {}
var selected_text := []
var in_progress := false

func _ready() -> void:
	visible = false
	scene_text = _load_scene_text()
	SignalBus.display_dialog.connect(_on_display_dialog)


func _load_scene_text() -> Dictionary:
	if (FileAccess.file_exists(scene_text_file)):
		var file = FileAccess.open(scene_text_file, FileAccess.READ)
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		return test_json_conv.data
	print("Scene Text File not found: ", scene_text_file)
	return {}


func _show_text() -> void:
	text_label.text = selected_text.pop_front()
	_animate_text()


func _next_line() -> void:
	if (selected_text.size() > 0):
		_show_text()
	else:
		_finish()


func _finish() -> void:
	text_label.text = ""
	visible = false
	in_progress = false
	SignalBus.dialog_completed.emit()


func _on_display_dialog(text_key: StringName) -> void:
	if (in_progress):
		_next_line()
	elif (text_key.is_empty()):
		return
	else:
		visible = true
		selected_text = scene_text[text_key].duplicate()
		in_progress = true
		chef_hat.begin_animation()
		_show_text()


func _animate_text() -> void: 
	var target_animation_length = text_label.text.length() / text_display_speed
	animation_player.play("display_text", -1, 1/target_animation_length)
