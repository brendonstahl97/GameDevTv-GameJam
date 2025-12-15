class_name NavigationArrows
extends Control

@export var arrow_highlight_color: Color = "#89bbf2"
@export var vertical: bool = false

@onready var left_arrow: TextureRect = %LeftArrow
@onready var right_arrow: TextureRect = %RightArrow

var next_input: String
var previous_input: String

func update(control_stack: ControlStack) -> void:
	if (!vertical):
		previous_input = control_stack.player_controls.code_left
		next_input = control_stack.player_controls.code_right
	else:
		previous_input = control_stack.player_controls.code_down
		next_input = control_stack.player_controls.code_up


	if (Input.is_action_pressed(previous_input)):
		left_arrow.modulate = arrow_highlight_color
	elif (Input.is_action_pressed(next_input)):
		right_arrow.modulate = arrow_highlight_color
	
	if (Input.is_action_just_released(previous_input)):
		left_arrow.modulate = Color.WHITE
	elif(Input.is_action_just_released(next_input)):
		right_arrow.modulate = Color.WHITE