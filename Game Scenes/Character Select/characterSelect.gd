extends Node3D

@onready var character_select_panels: CharacterSelectPanelManager = %"Character Select Panels"
@onready var all_ready_container: Control = %AllReadyContainer

@export var player_controls: Array[ControlStack]
@export var min_required_players: int = 1

var can_start_game := false

# Called when the node enters the scene tree for the first time.
func _ready():
	## Connect panel signals
	for panel: CharacterSelectPanel in character_select_panels.get_children():
		panel.player_status_changed.connect(_check_player_status)


func _process(_delta):
	_handle_input_assignment()
	_handle_add_bots()
	
	
	if (can_start_game):
		var player_1_control_stack: ControlStack = (character_select_panels.get_child(0) as CharacterSelectPanel).assigned_player_control_stack
		
		if (player_1_control_stack.player_controls != null && Input.is_action_just_pressed(player_1_control_stack.player_controls.begin_game)):
			_start_game(_get_player_choices())

func _handle_add_bots() -> void:
	if (!can_start_game):
		return
	
	for control_stack: ControlStack in player_controls:
		if (Input.is_action_just_pressed(control_stack.player_controls.parry)):
			character_select_panels.initialize_next_panel(control_stack, true)

func _handle_input_assignment() -> void:
	for control_stack: ControlStack in player_controls:
		if (Input.is_action_just_pressed(control_stack.player_controls.sprint)):
			character_select_panels.initialize_next_panel(control_stack)


func _start_game(player_choices_dictionary):
	# Set GLOBAL player info for their choices, usable anywhere.
	global.playerInfo = player_choices_dictionary
	BackgroundMusic.crossfade_to(BackgroundMusic.get_child(2).stream)
	get_tree().change_scene_to_file("res://Game Scenes/Main Game Scene/game.tscn")


# Returns a dictionary of each player's choices,
# give it to gameController when the game starts so we know how to spawn each player.
func _get_player_choices() -> Dictionary:
	var playerChoices = {}
	for p: CharacterSelectPanel in character_select_panels.get_children():
		# If the player hasn't joined, skip them
		if (!p.is_joined):
			continue

		var playerNumber: String = p.name
		var playerNestedInfo = p.player_info

		playerChoices[playerNumber] = playerNestedInfo
	return playerChoices


# Checks if all players that are joined are ready
func _check_player_status():
	var num_players_joined = 0
	var num_players_ready = 0
	
	for p: CharacterSelectPanel in character_select_panels.get_children():
		if (p.is_joined):
			num_players_joined += 1
		
		if (p.is_ready):
			num_players_ready += 1
	
	if(num_players_joined == num_players_ready and num_players_joined >= min_required_players):
		all_ready_container.show()
		can_start_game = true
	else:
		all_ready_container.hide()
		can_start_game = false
