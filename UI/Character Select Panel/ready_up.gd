extends Button


func update(assigned_player_control_stack: ControlStack) -> void:
	if (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.sprint)):
		pressed.emit()


func pseudo_focus() -> void:
	add_theme_stylebox_override("normal", get_theme_stylebox("pseudo_focus"))


func exit_pseudo_focus() -> void:
	if (has_theme_stylebox_override("normal")):
		remove_theme_stylebox_override("normal")