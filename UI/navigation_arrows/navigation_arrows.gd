class_name NavigationArrows
extends Control

@export var arrow_highlight_color: Color = "#89bbf2"

@onready var left_arrow: TextureRect = %LeftArrow
@onready var right_arrow: TextureRect = %RightArrow

func update(control_stack: ControlStack) -> void:

	if (Input.is_action_pressed(control_stack.player_controls.code_left)):
		left_arrow.modulate = arrow_highlight_color
	elif (Input.is_action_pressed(control_stack.player_controls.code_right)):
		right_arrow.modulate = arrow_highlight_color
	
	if (Input.is_action_just_released(control_stack.player_controls.code_left)):
		left_arrow.modulate = Color.WHITE
	elif(Input.is_action_just_released(control_stack.player_controls.code_right)):
		right_arrow.modulate = Color.WHITE
