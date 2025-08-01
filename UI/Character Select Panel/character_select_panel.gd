extends PanelContainer

signal character_choices_updated(player_info: Dictionary)

@onready var stand_type_selector: TitleTabContainer = %StandType
@onready var color_selector: ColorTabContainer = %Color
@onready var guy_selector: TitleTabContainer = %Guy
@onready var join_prompt: Panel = %"Join Prompt"
@onready var ready_indicator: Panel = %"Ready Indicator"
@onready var character_options: VBoxContainer = %"Character Options"
@onready var ready_button: PanelContainer = %Ready

@export var assigned_player_controls: PlayerControls
@export var initial_focus: Control
@export var stylebox_override_target: String = "panel"
@export var highlight_stylebox: StyleBox

var current_focus: Control
var is_joined := false
var is_ready := false
var is_bot := false

var player_info: Dictionary = {
	"PlayerColor" = Color(.5, .5, .5),
	"Money" = 0,
	"PlayerGuy" = "Chef_Male",
	"PlayerCart" = "Medium",
	"is_bot" = false
}:
	get:
		return get_selected_values()


func initialize(player_controls: PlayerControls, player_is_bot: bool = false) -> void:
	assigned_player_controls = player_controls
	is_bot = player_is_bot


func _ready() -> void:
	_focus_element(initial_focus)


func _process(_delta: float) -> void:
	
	if (!is_joined):
		_handle_unjoined_input()
	
	elif (is_joined && !is_ready):
		_handle_joined_input()
	
	elif (is_joined && is_ready):
		_handle_ready_input()


func _handle_ready_input() -> void:
	if (Input.is_action_just_pressed(assigned_player_controls.slam)):
		ready_indicator.hide()
		is_ready = false


func _handle_joined_input() -> void:
	if (Input.is_action_just_pressed(assigned_player_controls.code_down)):
		_focus_down()
	elif (Input.is_action_just_pressed(assigned_player_controls.code_up)):
		_focus_up()
	
	
	if (current_focus is MultiplayerTabContainer):
		
		if (Input.is_action_just_pressed(assigned_player_controls.code_left)):
			current_focus.navigate_left()
			character_choices_updated.emit(player_info)
			
		if (Input.is_action_just_pressed(assigned_player_controls.code_right)):
			current_focus.navigate_right()
			character_choices_updated.emit(player_info)
			
	elif (current_focus == ready_button):
		if (Input.is_action_just_pressed(assigned_player_controls.sprint)):
			ready_indicator.show()
			is_ready = true
	


func _handle_unjoined_input() -> void:
	if (Input.is_action_just_pressed(assigned_player_controls.sprint)):
		join_prompt.hide()
		character_options.show()
		is_joined = true

func get_selected_values() -> Dictionary:
	player_info["PlayerCart"] = stand_type_selector.selected_tab_title
	player_info["PlayerGuy"] = guy_selector.selected_tab_title
	player_info["PlayerColor"] = color_selector.selected_color
	player_info["is_bot"] = is_bot
	
	return player_info


func _focus_down() -> void:
	_focus_element(current_focus.get_node(current_focus.focus_neighbor_bottom))


func _focus_up() -> void:
	_focus_element(current_focus.get_node(current_focus.focus_neighbor_top))


func _focus_element(element: Control) -> void:
	if (current_focus != null):
		current_focus.remove_theme_stylebox_override(stylebox_override_target)
		
	current_focus = element
	current_focus.add_theme_stylebox_override(stylebox_override_target, highlight_stylebox)
