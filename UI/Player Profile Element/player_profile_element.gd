class_name PlayerProfileElement
extends Control

@export var player_default: PlayerProfileTab

@onready var tab_container: PlayerProfileTabContainer = %"PlayerProfileTabContainer"
@onready var navigation_arrows: NavigationArrows = %NavigationArrows
@onready var delete_prompt: Control = %DeletePrompt

var is_creating_profile: bool = false


func update(assigned_player_control_stack: ControlStack) -> void:
	if (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.code_left)):
		previous_tab()
	elif (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.code_right)):
		next_tab()
	elif (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.delete)):
		delete_current_profile()

	navigation_arrows.update(assigned_player_control_stack)

	if (tab_container.get_current_tab_control().has_method("update")):
		tab_container.get_current_tab_control().update(assigned_player_control_stack)


func pseudo_focus() -> void:
	navigation_arrows.show()
	delete_prompt.show()


func exit_pseudo_focus() -> void:
	navigation_arrows.hide()
	delete_prompt.hide()


func get_selected_profile_id() -> int:
	return tab_container.get_current_tab_profile_id()


func get_selected_profile_name() -> String:
	return (tab_container.get_child(tab_container.current_tab) as Label).text


func init_player_default_profile(player_name: String) -> void:
	player_default.text = player_name


func next_tab() -> void:
	tab_container.navigate_right()


func previous_tab() -> void:
	tab_container.navigate_left()


func delete_current_profile() -> void:
	tab_container.delete_current_profile()


func _on_profile_creator_begin_create_profile() -> void:
	if (delete_prompt.visible):
		delete_prompt.hide()


func _on_profile_creator_end_create_profile() -> void:
	if (!delete_prompt.visible):
		delete_prompt.show()
