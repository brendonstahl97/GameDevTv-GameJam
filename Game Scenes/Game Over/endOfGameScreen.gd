extends Node

@export var display_player_scene: PackedScene

@onready var display_player_positions: Node3D = %DisplayPlayerPositions
@onready var score_panels: ScorePanelManager = %HBoxContainer

var timeEntered = 0

func rematchClicked():
	# this check fixed a bug, but I can't remember what
	if (Time.get_unix_time_from_system() <= (timeEntered + 2)):
		return
	get_tree().change_scene_to_file("res://Game Scenes/Main Game Scene/game.tscn")
	BackgroundMusic.rematch()


func mainMenuClicked():
	BackgroundMusic.rematch()
	get_tree().change_scene_to_file("res://Game Scenes/Start Menu/Start.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timeEntered = Time.get_unix_time_from_system()
	%Rematch.grab_focus()
	
	score_panels.initialize_score_panels()

	var sorted_player_info = global.get_sorted_player_info()

	# Get the player info, and replace each player stuffs with the relevant info.
	for i in range(sorted_player_info.size()):
		var player_name = sorted_player_info[i][0]
		var thisPlayersInfo = sorted_player_info[i][1]
		
		# Move the score panel to the correct position based on their rank
		var player_panel = score_panels.get_panel_for_player(player_name)
		score_panels.move_child(player_panel, i)
		
		var display_player: DisplayPlayer = display_player_scene.instantiate()
		var target_position: Node3D = display_player_positions.get_child(i)
		
		target_position.add_child(display_player)
		display_player.global_position = target_position.global_position
		
		display_player.name = player_name
		display_player.update_character_display(player_name, thisPlayersInfo)
		
		if (i == 0):
			display_player.animation_player.play("Victory")
		else:
			display_player.animation_player.play("Death")


# TODO check all player's input
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("p1_sprint")):
		var focused_button = get_viewport().gui_get_focus_owner()
		if (focused_button.name == "Rematch"):
			rematchClicked()
		elif (focused_button.name == "MainMenu"):
			mainMenuClicked()
