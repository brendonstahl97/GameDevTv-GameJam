class_name CharacterSelectScreen
extends SequentialScreen

signal player_choices_updated(player_name: String, player_info: Dictionary)

@onready var character_select_panels: CharacterSelectPanelManager = %"Character Select Panels"
@onready var all_ready_container: Control = %AllReadyContainer

@export var player_controls: Array[ControlStack]
@export var min_required_players: int = 1

var num_joined_players: int = 0
var can_progress_screen := false


func update(delta: float) -> void:
	_handle_input_assignment()
	_handle_screen_progression()

	for panel: CharacterSelectPanel in character_select_panels.get_children():
		panel.update(delta)


func _ready():
	## Connect panel signals
	for panel: CharacterSelectPanel in character_select_panels.get_children():
		panel.player_status_changed.connect(_check_player_status)


func _handle_input_assignment() -> void:
	for control_stack: ControlStack in player_controls:
		if (Input.is_action_just_pressed(control_stack.player_controls.sprint)):
			character_select_panels.initialize_next_panel(control_stack)


func _handle_screen_progression() -> void:
	if (num_joined_players <= 0):
		for control_stack in player_controls:
			if (Input.is_action_just_pressed(control_stack.player_controls.slam)):
				previous_screen.emit()

	if (!can_progress_screen):
		return

	for control_stack in player_controls:
		if (Input.is_action_just_pressed(control_stack.player_controls.begin_game)):
			next_screen.emit()


# Returns a dictionary of each player's choices,
# give it to gameController when the game starts so we know how to spawn each player.
func get_player_choices() -> Dictionary:
	var player_choices = { }
	for p: CharacterSelectPanel in character_select_panels.get_children():
		# If the player hasn't joined, skip them
		if (!p.is_joined):
			continue

		var player_nested_info = p.player_info

		player_choices[p.final_player_name] = player_nested_info
	return player_choices


# Checks if all players that are joined are ready
func _check_player_status():
	var num_players_joined = 0
	var num_players_ready = 0

	for p: CharacterSelectPanel in character_select_panels.get_children():
		if (p.is_joined):
			num_players_joined += 1

		if (p.is_ready):
			num_players_ready += 1

	num_joined_players = num_players_joined

	if (num_players_joined == num_players_ready and num_players_joined >= min_required_players):
		all_ready_container.show()
		can_progress_screen = true
	else:
		all_ready_container.hide()
		can_progress_screen = false


func _on_character_select_panels_player_choices_updated(player_name: String, player_info: Dictionary) -> void:
	player_choices_updated.emit(player_name, player_info)
