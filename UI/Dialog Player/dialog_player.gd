class_name DialogPlayer
extends Control

@export_file("*json") var scene_dialogue_file: String
@export var text_display_speed: float = 50 ## The speed at which text will be displayed in characters per second
@export var dialogue_sound_effects: Array[AudioStream]
@export var sound_occurance_rate: int = 3 ## how often will a sound play in number of characters (Ex: by default, a sound will play every 2 characters displayed

@onready var text_label: Label = %Text
@onready var chef_hat: Node3D = %Chef_Hat # This should probably be modular?
@onready var timer: Timer = %Timer
@onready var audio_player: AudioStreamPlayer3D = %AudioStreamPlayer3D

var scene_dialogue := {}
var current_topic := []
var current_line := ""
var in_progress := false
var num_characters = 0

func _ready() -> void:
	visible = false
	scene_dialogue = _load_scene_dialogue()
	timer.timeout.connect(_animate_text)
	SignalBus.display_dialog.connect(_on_display_dialog)


func _load_scene_dialogue() -> Dictionary:
	if (FileAccess.file_exists(scene_dialogue_file)):
		var file = FileAccess.open(scene_dialogue_file, FileAccess.READ)
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		return test_json_conv.data
	print("Scene Text File not found: ", scene_dialogue_file)
	return {}


func _show_text() -> void:
	current_line = current_topic.pop_front()
	timer.start(1/text_display_speed)


func _next_line() -> void:
	if (current_topic.size() > 0):
		_show_text()
	else:
		_finish()


func _finish() -> void:
	text_label.text = ""
	visible = false
	in_progress = false
	audio_player.stop()
	timer.stop()
	SignalBus.dialog_completed.emit()


func _on_display_dialog(text_key: StringName) -> void:
	text_label.text = ""
	if (in_progress):
		_next_line()
	elif (text_key.is_empty()):
		return
	else:
		visible = true
		current_topic = scene_dialogue[text_key].duplicate()
		in_progress = true
		chef_hat.begin_animation()
		_show_text()


func _animate_text() -> void: 
	if (current_line.length() <= 0):
		timer.stop()
		return
	
	var new_character = current_line.left(1)
	text_label.text += new_character
	current_line = current_line.erase(0)
	timer.start(1/text_display_speed)
	num_characters += 1
	if (num_characters % sound_occurance_rate == 0):
		_play_dialogue_audio(new_character)


func _play_dialogue_audio(character: String) -> void:
	# Use the ascii value to determine if the character is a letter or not
	var ascii_value = character.to_ascii_buffer()[0]
	
	# If it is not a letter, do not play a sound
	if (ascii_value - 65 < 0):
		return
		
	audio_player.stream = dialogue_sound_effects.pick_random()
	audio_player.play()
