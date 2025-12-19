class_name PlayerProfileElement
extends Control

@export var player_default: PlayerProfileTab
@export var purchase_failure_animation_name: StringName = "purchase_error"

@onready var tab_container: PlayerProfileTabContainer = %"PlayerProfileTabContainer"
@onready var navigation_arrows: NavigationArrows = %NavigationArrows
@onready var delete_prompt: Control = %DeletePrompt
@onready var animation_player: AnimationPlayer = %AnimationPlayer

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
	_handle_delete_prompt_visibility()
	_pseudo_focus_tab()


func exit_pseudo_focus() -> void:
	navigation_arrows.hide()
	delete_prompt.hide()
	_exit_pseudo_focus_tab()


func get_selected_profile_id() -> int:
	return tab_container.get_current_tab_profile_id()


func get_selected_profile_name() -> String:
	return (tab_container.get_child(tab_container.current_tab) as Label).text


func get_selected_profile() -> Dictionary:
	return (tab_container.get_child(tab_container.current_tab) as PlayerProfileTab).profile


func init_player_default_profile(player_name: String) -> void:
	player_default.text = player_name


func next_tab() -> void:
	_exit_pseudo_focus_tab()
	tab_container.navigate_right()
	_handle_delete_prompt_visibility()
	_pseudo_focus_tab()


func previous_tab() -> void:
	_exit_pseudo_focus_tab()
	tab_container.navigate_left()
	_handle_delete_prompt_visibility()
	_pseudo_focus_tab()


func delete_current_profile() -> void:
	tab_container.delete_current_profile()
	_handle_delete_prompt_visibility()


func _on_profile_creator_begin_create_profile() -> void:
	if (delete_prompt.visible):
		delete_prompt.hide()


func _on_profile_creator_end_create_profile() -> void:
	if (!delete_prompt.visible):
		delete_prompt.show()


func _handle_delete_prompt_visibility() -> void:
	if (get_selected_profile() == { }):
		delete_prompt.hide()
	else:
		if (!delete_prompt.visible):
			delete_prompt.show()


func _on_character_preview_purchase_failure() -> void:
	animation_player.play(purchase_failure_animation_name)


func _pseudo_focus_tab() -> void:
	var current_focus = tab_container.get_child(tab_container.current_tab)

	# Apply styling to new focus element
	if (current_focus.has_theme_stylebox("pseudo_focus")):
		current_focus.add_theme_stylebox_override(
			"normal", #TODO: pass down the argument
			current_focus.get_theme_stylebox("pseudo_focus"),
		)
		print ("Test")


func _exit_pseudo_focus_tab() -> void:
	var current_focus = tab_container.get_child(tab_container.current_tab)

	if (current_focus.has_theme_stylebox_override("normal")):
		current_focus.remove_theme_stylebox_override("normal")
