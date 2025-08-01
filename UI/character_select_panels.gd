class_name CharacterSelectPanelManager
extends HBoxContainer

signal player_choices_updated(player_name: String, player_info: Dictionary)

func initialize_next_panel(player_control_stack: ControlStack, is_bot: bool = false) -> void:
	var panel_to_initialize: CharacterSelectPanel = null
	
	for panel: CharacterSelectPanel in get_children():
		if (panel.assigned_player_control_stack == player_control_stack && !is_bot):
			return
		
		if (panel.assigned_player_control_stack == null):
			panel_to_initialize = panel
			break
	
	if (panel_to_initialize != null):
		panel_to_initialize.initialize(player_control_stack, is_bot)
		player_control_stack.stack.push_back(panel_to_initialize)


func _on_player_choices_updated(player_name: String, player_info: Dictionary) -> void:
	player_choices_updated.emit(player_name, player_info)
