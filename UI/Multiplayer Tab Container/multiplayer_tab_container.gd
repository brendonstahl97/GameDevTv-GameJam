@abstract class_name MultiplayerTabContainer
extends TabContainer

var num_tabs: int = 0


func _ready() -> void:
	num_tabs = get_children().size()


func update(assigned_player_control_stack: ControlStack) -> void:
	if (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.code_left)):
		navigate_left()
		
	if (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.code_right)):
		navigate_right()


func navigate_left() -> void:
	if (current_tab == 0):
		current_tab = num_tabs - 1
	else:
		current_tab -= 1


func navigate_right() -> void:
	if (current_tab == num_tabs - 1):
		current_tab = 0
	else:
		current_tab += 1
