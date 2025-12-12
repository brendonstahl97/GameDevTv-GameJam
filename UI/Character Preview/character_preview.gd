class_name CharacterPreview
extends Control

@onready var display_player: DisplayPlayer = %DisplayPlayer
@onready var camera: Camera3D = %Camera3D
@onready var panel_container: PanelContainer = %PanelContainer
@onready var left_arrow: TextureRect = %LeftArrow
@onready var right_arrow: TextureRect = %RightArrow

@export var model_selector: TitleTabContainer ## The character selector this preview is linked to
@export var arrow_highlight_color: Color


func update(assigned_player_control_stack: ControlStack) -> void:
	if (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.code_left)):
		model_selector.navigate_left()
		left_arrow.modulate = arrow_highlight_color
	elif (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.code_right)):
		model_selector.navigate_right()
		right_arrow.modulate = arrow_highlight_color
	
	if (Input.is_action_just_released(assigned_player_control_stack.player_controls.code_left)):
		left_arrow.modulate = Color.WHITE
	elif(Input.is_action_just_released(assigned_player_control_stack.player_controls.code_right)):
		right_arrow.modulate = Color.WHITE


func initialize(height_offset: float = 10) -> void:
	display_player.global_position += Vector3.UP * height_offset
	camera.global_position += Vector3.UP * height_offset


func on_character_updated(_character_name: String, player_info: Dictionary) -> void:
	display_player.update_character_display_direct(player_info)


func pseudo_focus() -> void:
	panel_container.add_theme_stylebox_override("panel", panel_container.get_theme_stylebox("pseudo_focus"))

	left_arrow.show()
	right_arrow.show()


func exit_pseudo_focus() -> void:
	if (panel_container.has_theme_stylebox_override("panel")):
		panel_container.remove_theme_stylebox_override("panel")

	left_arrow.hide()
	right_arrow.hide()
