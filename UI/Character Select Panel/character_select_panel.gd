class_name CharacterSelectPanel
extends PanelContainer

signal player_choices_updated(player_name: String, player_info: Dictionary)
signal player_status_changed
signal bot_requested(control_stack: ControlStack)

@onready var stand_type_selector: TitleTabContainer = %StandType
@onready var color_selector: ColorTabContainer = %Color
@onready var guy_selector: TitleTabContainer = %Guy
@onready var join_prompt: Panel = %"Join Prompt"
@onready var ready_indicator: Panel = %"Ready Indicator"
@onready var character_options: VBoxContainer = %"Character Options"
@onready var ready_button: PanelContainer = %Ready
@onready var name_display: LineEdit = %LineEdit
@onready var bot_difficulty_selector: DifficultyTabContainer = %"Bot Difficulty"
@onready var player_profile: PlayerProfileElement = %"Player Profile"

@export var player_name: String = "Player 1" ## Display name of the player in-game
@export var bot_name_modifier: String = "(Bot)" ## string that will be added on to the player name if the player is a bot
@export var assigned_player_control_stack: ControlStack	## control stack assigned to the current player, should be "pop"-ed when unassigning
@export var initial_focus: Control ## What selectablle item should be in focus when starting
@export var stylebox_override_target: String = "panel" ## name of the stylebox that should be overridden for the highlight formatting
@export var highlight_stylebox: StyleBox ## the stylebox that should be applied when elements are in focus

var current_focus: Control
var is_active := true
var is_joined := false
var is_ready := false
var is_bot := false

var player_info: Dictionary:
	get:
		return _get_selected_values()

var final_player_name: String:
	get: 
		return name_display.placeholder_text


func initialize(player_control_stack: ControlStack, player_is_bot: bool = false) -> void:
	name_display.placeholder_text = player_name
	assigned_player_control_stack = player_control_stack
	
	# in case this panel was previously a bot:
	# reset element neighbors
	guy_selector.focus_neighbor_bottom = guy_selector.get_path_to(ready_button)
	ready_button.focus_neighbor_top = ready_button.get_path_to(guy_selector)
	
	_init_panel(player_is_bot)



func _init_panel(player_is_bot: bool) -> void:
	if (player_is_bot):
		_init_bot_panel()
	else:
		_init_player_panel()


func _init_player_panel() -> void:
	# Hide the bot difficulty selector
	bot_difficulty_selector.hide()

	# Set the neighbors to include the bot difficulty selector
	guy_selector.focus_neighbor_bottom = guy_selector.get_path_to(player_profile)
	ready_button.focus_neighbor_top = ready_button.get_path_to(player_profile)

	# Display the player profile selector
	player_profile.show()

	name_display.placeholder_text = player_name
	_join()


func _init_bot_panel() -> void:
	# Set the bot flag
	is_bot = true

	# Hide the player profile selector
	player_profile.hide()

	# Set the neighbors to include the bot difficulty selector
	guy_selector.focus_neighbor_bottom = guy_selector.get_path_to(bot_difficulty_selector)
	ready_button.focus_neighbor_top = ready_button.get_path_to(bot_difficulty_selector)
	
	# Display the bot difficulty selector
	bot_difficulty_selector.show()
	
	# Include the bot name modifier 
	name_display.placeholder_text += bot_name_modifier
	_join()


func _ready() -> void:
	_focus_element(initial_focus)


func update(_delta: float) -> void:
	if (!is_active || assigned_player_control_stack == null || assigned_player_control_stack.get_current_control() != self):
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
	elif (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.slam)):
		_unjoin()
		return
	
	if (current_focus == player_profile):
		if (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.code_left)):
			player_profile.previous_tab()
		elif (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.code_right)):
			player_profile.next_tab()
		elif (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.delete)):
			player_profile.delete_current_profile()
		elif (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.begin_game)):
			player_profile.begin_create_profile(assigned_player_control_stack)

	
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
	elif (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.parry)):
		## Request a bot be added by this plaayer's control stack
		bot_requested.emit(assigned_player_control_stack)


func _get_selected_values() -> Dictionary:
	var player_controls = assigned_player_control_stack.player_controls if assigned_player_control_stack != null else null
	
	var player_choices = {
		"PlayerColor" = color_selector.selected_color,
		"is_joined" = is_joined,
		"Money" = 0,
		"PlayerGuy" = guy_selector.selected_tab_title,
		"PlayerCart" = stand_type_selector.selected_tab_title,
		"PlayerControls" = player_controls,
		"is_bot" = is_bot,
		"bot_difficulty" = bot_difficulty_selector.selected_tab_difficulty
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
	player_choices_updated.emit(self.name, player_info)


func _unjoin() -> void:
	join_prompt.show()
	character_options.hide()
	is_joined = false
	
	player_status_changed.emit()
	
	assigned_player_control_stack.stack.pop_back()
	assigned_player_control_stack = null
	
	player_choices_updated.emit(self.name, player_info)
	
	if (is_bot):
		is_bot = false
