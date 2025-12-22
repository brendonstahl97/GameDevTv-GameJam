class_name CharacterSelectPanel
extends Control

signal player_choices_updated(player_name: String, player_info: Dictionary)
signal ui_navigation
signal player_status_changed
signal bot_requested(control_stack: ControlStack)
signal ready_error

@onready var stand_type_selector: TitleTabContainer = %StandType
@onready var color_selector: ColorTabContainer = %Color
@onready var guy_selector: CostumeTabContainer = %Guy
@onready var join_prompt: Panel = %"Join Prompt"
@onready var ready_indicator: Control = %"Ready Indicator"
@onready var character_options: VBoxContainer = %"Character Options"
@onready var ready_button: Button = %ReadyUp
@onready var name_display: Label = %"Player Name Label"
@onready var bot_difficulty_selector: DifficultyTabContainer = %"Bot Difficulty"
@onready var player_profile_element: PlayerProfileElement = %"Player Profile"
@onready var character_preview: CharacterPreview = %"Character Preview"

## Display name of the player in-game
@export var player_name: String = "Player 1"
## string that will be added on to the player name if the player is a bot
@export var bot_name_modifier: String = "(Bot)"
## control stack assigned to the current player, should be "pop"-ed when unassigning
@export var assigned_player_control_stack: ControlStack
## What selectablle item should be in focus when starting
@export var initial_focus: Control
## name of the stylebox that should be overridden for the highlight formatting
@export var stylebox_override_target: String = "panel"
## the stylebox that should be applied when elements are in focus
@export var highlight_stylebox: StyleBox
## offset to apply to the 3D character preview display player and camera
@export var display_player_offset: float = 10

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
		return player_profile_element.get_selected_profile_name()


var can_ready: bool:
	get:
		if (is_bot):
			return true

		if (player_profile_element.get_selected_profile_id() == -1):
			return player_profile_element.default_profile_costumes.any(_check_for_costume_ownership)

		return player_profile_element.get_selected_profile()["owned_costumes"].any(_check_for_costume_name_ownership)


func _ready() -> void:
	_focus_element(initial_focus)
	player_choices_updated.connect(character_preview.on_character_updated)
	character_preview.initialize(display_player_offset)


func initialize(player_control_stack: ControlStack, player_is_bot: bool = false) -> void:
	assigned_player_control_stack = player_control_stack

	# in case this panel was previously a bot:
	# reset element neighbors
	color_selector.focus_neighbor_bottom = color_selector.get_path_to(ready_button)
	ready_button.focus_neighbor_top = ready_button.get_path_to(color_selector)

	_init_panel(player_is_bot)


func _init_panel(player_is_bot: bool) -> void:
	if (player_is_bot):
		_init_bot_panel()
	else:
		_init_player_panel()


func _init_player_panel() -> void:
	# Hide the bot difficulty selector
	bot_difficulty_selector.hide()

	# Set the neighbors to exclude the bot difficulty selector
	color_selector.focus_neighbor_bottom = color_selector.get_path_to(ready_button)
	ready_button.focus_neighbor_top = ready_button.get_path_to(color_selector)

	# Set the neighbors to include the player profile selector
	character_preview.focus_neighbor_bottom = character_preview.get_path_to(player_profile_element)
	stand_type_selector.focus_neighbor_top = stand_type_selector.get_path_to(player_profile_element)

	player_profile_element.init_player_default_profile(player_name)
	_join()


func _init_bot_panel() -> void:
	# Set the bot flag
	is_bot = true

	# Set the neighbors to include the bot difficulty selector
	color_selector.focus_neighbor_bottom = color_selector.get_path_to(bot_difficulty_selector)
	ready_button.focus_neighbor_top = ready_button.get_path_to(bot_difficulty_selector)

	# Set the neighbors to exclude the player profile selector
	character_preview.focus_neighbor_bottom = character_preview.get_path_to(stand_type_selector)
	stand_type_selector.focus_neighbor_top = stand_type_selector.get_path_to(character_preview)

	# Display the bot difficulty selector
	bot_difficulty_selector.show()

	# Include the bot name modifier
	player_profile_element.init_player_default_profile(player_name + bot_name_modifier)

	_join()


func update(_delta: float) -> void:
	if (
		!is_active
		|| assigned_player_control_stack == null
		|| assigned_player_control_stack.get_current_control() != self
	):
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
		assigned_player_control_stack.pop_control()
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

	# This is a duck typed function call to the current focus element's update function
	# Each focusable element should have its own update function to handle specific input
	if (current_focus != null && current_focus.has_method("update")):
		current_focus.update(assigned_player_control_stack)

	if (InputUtilities.is_anything_just_pressed(assigned_player_control_stack.player_controls)):
		ui_navigation.emit()
		call_deferred("emit_signal", "player_choices_updated", self.name, player_info)


func _handle_ready_input() -> void:
	if (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.slam)):
		ready_indicator.hide()
		is_ready = false
		player_status_changed.emit()
	elif (Input.is_action_just_pressed(assigned_player_control_stack.player_controls.parry)):
		## Request a bot be added by this plaayer's control stack
		bot_requested.emit(assigned_player_control_stack)


func _get_selected_values() -> Dictionary:
	var player_controls = (
		assigned_player_control_stack.player_controls
		if assigned_player_control_stack != null
		else null
	)

	var player_choices = {
		"PlayerColor"= color_selector.selected_color,
		"is_joined"= is_joined,
		"Money"= 0,
		"player_costume"= guy_selector.selected_costume,
		"PlayerCart"= stand_type_selector.selected_tab_title,
		"PlayerControls"= player_controls,
		"PlayerProfileId"= player_profile_element.get_selected_profile_id(),
		"is_bot"= is_bot,
		"bot_difficulty"= bot_difficulty_selector.selected_tab_difficulty
	}

	return player_choices


func _focus_down() -> void:
	_focus_element(current_focus.get_node(current_focus.focus_neighbor_bottom))


func _focus_up() -> void:
	_focus_element(current_focus.get_node(current_focus.focus_neighbor_top))


func _focus_element(element: Control) -> void:
	# Remove the focus styling from the current focus, if any
	if (current_focus != null):
		if (current_focus.has_method("exit_pseudo_focus")):
			current_focus.exit_pseudo_focus()

		if (current_focus.has_theme_stylebox_override(stylebox_override_target)):
			current_focus.remove_theme_stylebox_override(stylebox_override_target)

	# set new focus
	current_focus = element

	assert(
		current_focus.has_theme_stylebox("pseudo_focus")
		|| current_focus.has_method("pseudo_focus"),
		"The current focus does not have a 'pseudo_focus'
		theme stylebox or a 'pseudo_focus()' method and is unable to display as focused",
	)

	# Apply styling to new focus element
	if (current_focus.has_theme_stylebox("pseudo_focus")):
		current_focus.add_theme_stylebox_override(
			stylebox_override_target,
			current_focus.get_theme_stylebox("pseudo_focus"),
		)

	if (current_focus.has_method("pseudo_focus")):
		current_focus.pseudo_focus()


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

	_focus_element(initial_focus)

	assigned_player_control_stack.stack.pop_back()
	assigned_player_control_stack = null

	player_choices_updated.emit(self.name, player_info)

	if (is_bot):
		is_bot = false


func _on_ready_up_pressed() -> void:
	if (!can_ready):
		ready_error.emit()
		return

	ready_indicator.show()
	is_ready = true
	player_status_changed.emit()


func _on_character_preview_purchase_success() -> void:
	player_choices_updated.emit(self.name, player_info)


func _check_for_costume_name_ownership(costume_name: String) -> bool:
	return costume_name == guy_selector.selected_costume.name


func _check_for_costume_ownership(costume: CharacterCostume) -> bool:
	return costume == guy_selector.selected_costume
