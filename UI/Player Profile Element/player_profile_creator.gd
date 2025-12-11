class_name PlayerProfileCreator
extends PlayerProfileTab

@export var default_text: String = "Create Profile"
@export var max_name_length: int = 10 ## The maximum profile name length in characters
@export var error_animation_name: StringName = "Error"

var current_player_control_stack: ControlStack
var possible_characters: Array[String] = [
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G",
	"H",
	"I",
	"J",
	"K",
	"L",
	"M",
	"N",
	"O",
	"P",
	"Q",
	"R",
	"S",
	"T",
	"U",
	"V",
	"W",
	"X",
	"Y",
	"Z",
	" ",
]

var current_character_index := -1

var flash_characters: Array[String] = [" ", "_"]
var current_flash_index = 0

var current_base_text = ""

var is_active := false

@onready var flash_timer: Timer = %Timer
@onready var animation_player: AnimationPlayer = %AnimationPlayer


# Initialize our flash character timer signal
func _ready():
	flash_timer.timeout.connect(_iterate_flash_character)


# determine if the controlling player has selected this element
func update(player_control_stack: ControlStack) -> void:
	if (!is_active):
		if (Input.is_action_just_pressed(player_control_stack.player_controls.sprint)):
			is_active = true
			player_control_stack.push_control(self)
			current_player_control_stack = player_control_stack


func _process(_delta: float) -> void:
	# We should only process if this element is the the target control in the player's control stack
	if (
		!is_active
		|| current_player_control_stack == null
		|| current_player_control_stack.get_current_control() != self
	):
		return

	_display_sample_character()

	if (Input.is_action_just_pressed(current_player_control_stack.player_controls.code_up)):
		_increment_character()

	elif (Input.is_action_just_pressed(current_player_control_stack.player_controls.code_down)):
		_decrement_character()

	elif (Input.is_action_just_pressed(current_player_control_stack.player_controls.code_left)):
		_previous_character()

	elif (Input.is_action_just_pressed(current_player_control_stack.player_controls.code_right)):
		_next_character()

	elif (Input.is_action_just_pressed(current_player_control_stack.player_controls.parry)):
		if (text.length() <= 0):
			return

		if (current_character_index != -1 && current_base_text.length() <= max_name_length):
			text += possible_characters[current_character_index]

		var new_id = ProfileManager.create_profile(text)
		if (new_id == -1):
			animation_player.play(error_animation_name)

	elif (Input.is_action_just_pressed(current_player_control_stack.player_controls.slam)):
		is_active = false
		current_player_control_stack.pop_control()
		current_player_control_stack = null
		text = default_text


func _next_character() -> void:
	if (current_character_index != -1 && current_base_text.length() <= max_name_length):
		current_base_text += possible_characters[current_character_index]
		current_character_index = -1


func _previous_character() -> void:
	current_character_index = -1

	if (current_base_text.length() >= 0):
		current_base_text = current_base_text.substr(0, current_base_text.length() - 1)


func _increment_character() -> void:
	if (current_character_index == -1):
		current_character_index = 1

	current_character_index = (current_character_index + possible_characters.size() + 1) % possible_characters.size()


func _decrement_character() -> void:
	if (current_character_index == -1):
		current_character_index = 1

	current_character_index = (current_character_index + possible_characters.size() - 1) % possible_characters.size()


func _display_sample_character() -> void:
	if (current_character_index == -1):
		text = current_base_text + flash_characters[current_flash_index]
	else:
		text = current_base_text + possible_characters[current_character_index]


func _iterate_flash_character() -> void:
	var new_index = (current_flash_index + flash_characters.size() + 1) % flash_characters.size()
	current_flash_index = new_index
