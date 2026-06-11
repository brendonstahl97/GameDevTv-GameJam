class_name CharacterPreview
extends Control

signal purchase_failure
signal purchase_success

@onready var display_player: DisplayPlayer = %DisplayPlayer
@onready var camera: Camera3D = %Camera3D
@onready var panel_container: PanelContainer = %PanelContainer
@onready var left_arrow: TextureRect = %LeftArrow
@onready var right_arrow: TextureRect = %RightArrow
@onready var costume_locked_display: Control = %CostumeLocked
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var price_label: Label = %PriceLabel

@export var model_selector: CostumeTabContainer ## The character selector this preview is linked to
@export var arrow_highlight_color: Color ## The color that the navigation arrows should highlight when pressed
@export var player_profile_element: PlayerProfileElement ## the accompanying player profile element
@export_category("Animations")
@export var unlock_animation_name: StringName = "unlock" ## the name of the animation to play when a costume is unlocked
## the name of the animation to play when there is an error with the selected costume
@export var costume_error_animation_name: StringName = "invalid_costume_selected"

var is_current_costume_locked := false
var current_player_info: Dictionary = { }


func update(assigned_player_control_stack: ControlStack) -> void:
	if (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.code_left)):
		model_selector.navigate_left()
		left_arrow.modulate = arrow_highlight_color

	elif (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.code_right)):
		model_selector.navigate_right()
		right_arrow.modulate = arrow_highlight_color

	elif (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.sprint)):
		_attempt_purchase()

	if (Input.is_action_just_released(assigned_player_control_stack.player_controls.code_left)):
		left_arrow.modulate = Color.WHITE

	elif (Input.is_action_just_released(assigned_player_control_stack.player_controls.code_right)):
		right_arrow.modulate = Color.WHITE


func initialize(height_offset: float = 10) -> void:
	display_player.global_position += Vector3.UP * height_offset
	camera.global_position += Vector3.UP * height_offset


func on_character_updated(_character_name: String, player_info: Dictionary) -> void:
	display_player.update_character_display_direct(player_info)
	current_player_info = player_info

	_update_costume_unlock_status()


func pseudo_focus() -> void:
	panel_container.add_theme_stylebox_override("panel", panel_container.get_theme_stylebox("pseudo_focus"))
	price_label.text = "$" + str((current_player_info["player_costume"] as CharacterCostume).purchase_price)
	left_arrow.show()
	right_arrow.show()


func exit_pseudo_focus() -> void:
	if (panel_container.has_theme_stylebox_override("panel")):
		panel_container.remove_theme_stylebox_override("panel")

	left_arrow.hide()
	right_arrow.hide()


func _attempt_purchase() -> bool:
	if (!is_current_costume_locked):
		return false

	if (player_profile_element.get_selected_profile_id() < 0):
		return false

	var current_profile = player_profile_element.get_selected_profile()

	if (
		current_profile["coins"]
		< (current_player_info["player_costume"] as CharacterCostume).purchase_price
	):
		purchase_failure.emit()
		return false

	current_profile["coins"] -= (current_player_info["player_costume"] as CharacterCostume).purchase_price
	(current_profile["owned_costumes"] as Array).append(current_player_info["player_costume"].name)

	ProfileManager.update_profile(current_profile)

	animation_player.play(unlock_animation_name)
	purchase_success.emit()
	return true


func _update_costume_unlock_status() -> void:
	price_label.text = "$" + str((current_player_info["player_costume"] as CharacterCostume).purchase_price)
	costume_locked_display.show()

	if (player_profile_element == null):
		return

	var current_profile = player_profile_element.get_selected_profile()
	var current_id = player_profile_element.get_selected_profile_id()

	if (current_profile == null || current_id == -2):
		_handle_unlocked_costume()
		return

	# If the default profile owns the selected costume
	if (current_id == -1):
		if (player_profile_element.default_profile_costumes.any(
				func(costume): return costume == model_selector.selected_costume
			)
		):
			_handle_unlocked_costume()

		else:
			_handle_locked_costume()

		return

	# If the current profile owns the selected costume, or the profile creator is selected
	print(current_profile["id"])
	print(model_selector.selected_costume.purchase_price)
	if (
		(current_profile["owned_costumes"] as Array[String]).any(
			func(costume): return costume == model_selector.selected_costume.name
		)
	):
		_handle_unlocked_costume()

	else:
		_handle_locked_costume()


func _handle_unlocked_costume() -> void:
	if (!animation_player.is_playing()):
		costume_locked_display.hide()

		is_current_costume_locked = false


func _handle_locked_costume() -> void:
	if (!animation_player.is_playing()):
		animation_player.play("RESET")
	else:
		await animation_player.animation_finished
		animation_player.play("RESET")

		costume_locked_display.show()
		is_current_costume_locked = true


func _on_character_select_panel_ready_error() -> void:
	animation_player.play(costume_error_animation_name)
