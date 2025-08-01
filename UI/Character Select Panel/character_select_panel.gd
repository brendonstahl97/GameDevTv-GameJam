class_name CharacterSelectPanel
extends PanelContainer

signal player_choices_updated(player_name: String, player_info: Dictionary)
signal player_status_changed

@onready var stand_type_selector: TitleTabContainer = %StandType
@onready var color_selector: ColorTabContainer = %Color
@onready var guy_selector: TitleTabContainer = %Guy
@onready var join_prompt: Panel = %"Join Prompt"
@onready var ready_indicator: Panel = %"Ready Indicator"
@onready var character_options: VBoxContainer = %"Character Options"
@onready var ready_button: PanelContainer = %Ready
@onready var name_display: LineEdit = %LineEdit

@export var player_name: String = "Player 1" ## Display name of the player in-game
@export var bot_name_modifier: String = "(Bot)" ## string that will be added on to the player name if the player is a bot
@export var assigned_player_control_stack: ControlStack	##
@export var initial_focus: Control
@export var stylebox_override_target: String = "panel"
@export var highlight_stylebox: StyleBox

var current_focus: Control
var is_joined := false
var is_ready := false
var is_bot := false

var player_info: Dictionary:
	get:
		return _get_selected_values()


func initialize(player_control_stack: ControlStack, player_is_bot: bool = false) -> void:
	name_display.text = player_name
	assigned_player_control_stack = player_control_stack
	is_bot = player_is_bot
	
	if (is_bot):
		name_display.text += "(Bot)"
		_join()


func _ready() -> void:
	_focus_element(initial_focus)


func _process(_delta: float) -> void:
	
	if (assigned_player_control_stack == null || assigned_player_control_stack.get_current_control() != self):
		return
	
	if (!is_joined):
		_handle_unjoined_input()
	
	elif (is_joined && !is_ready):
		_handle_joined_input()
	
	elif (is_joined && is_ready):
		_handle_ready_input()


func _handle_unjoined_input() -> void:
	if (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.sprint)):
		_join()
	
	if (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.slam)):
		assigned_player_control_stack.stack.pop_back()
		assigned_player_control_stack = null
		is_bot = false


func _handle_joined_input() -> void:
	if (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.code_down)):
		_focus_down()
	elif (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.code_up)):
		_focus_up()
	
	if (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.slam)):
		_unjoin()
		return
	
	
	if (current_focus is MultiplayerTabContainer):
		
		if (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.code_left)):
			current_focus.navigate_left()
			player_choices_updated.emit(self.name, player_info)
			
		if (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.code_right)):
			current_focus.navigate_right()
			player_choices_updated.emit(self.name, player_info)
			
	elif (current_focus == ready_button):
		
		if (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.sprint)):
			ready_indicator.show()
			is_ready = true
			player_status_changed.emit()


func _handle_ready_input() -> void:
	if (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.slam)):
		ready_indicator.hide()
		is_ready = false
		player_status_changed.emit()


func _get_selected_values() -> Dictionary:
	var player_choices = {
		"PlayerColor" = color_selector.selected_color,
		"Money" = 0,
		"PlayerGuy" = guy_selector.selected_tab_title,
		"PlayerCart" = stand_type_selector.selected_tab_title,
		"is_bot" = is_bot
	}
	
	return player_choices


func _focus_down() -> void:
	_focus_element(current_focus.get_node(current_focus.focus_neighbor_bottom))


func _focus_up() -> void:
	_focus_element(current_focus.get_node(current_focus.focus_neighbor_top))


func _focus_element(element: Control) -> void:
	if (current_focus != null):
		current_focus.remove_theme_stylebox_override(stylebox_override_target)
		
	current_focus = element
	current_focus.add_theme_stylebox_override(stylebox_override_target, highlight_stylebox)


func _join() -> void:
	join_prompt.hide()
	character_options.show()
	is_joined = true
	player_status_changed.emit()


func _unjoin() -> void:
	join_prompt.show()
	character_options.hide()
	is_joined = false
	player_status_changed.emit()
	
	if (is_bot):
		is_bot = false
		assigned_player_control_stack.stack.pop_back()
		assigned_player_control_stack = null
