extends Node

@export var display_player_scene: PackedScene

@export_category("Rewards")
@export var reward_interval: float = 0.15 ## the amount of time between each reward
@export var first_place_reward: int = 50 ## Coin reward for first place
@export var second_place_reward: int = 35 ## Coin reward for second place
@export var third_place_reward: int = 25 ## Coin reward for third place
@export var fourth_place_reward: int = 15 ## Coin reward for fourth place
@export var reward_displays: Array = []

@onready var display_player_positions: Node3D = %DisplayPlayerPositions
@onready var score_panels: ScorePanelManager = %HBoxContainer

var time_entered = 0


func rematch_clicked():
	# this check fixed a bug, but I can't remember what
	if (Time.get_unix_time_from_system() <= (time_entered + 2)):
		return
	get_tree().change_scene_to_file("res://Game Scenes/Main Game Scene/game.tscn")
	BackgroundMusic.rematch()


func main_menu_clicked():
	BackgroundMusic.rematch()
	get_tree().change_scene_to_file("res://Game Scenes/Start Menu/Start.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_entered = Time.get_unix_time_from_system()
	%Rematch.grab_focus()

	score_panels.initialize_score_panels()

	var sorted_player_info = global.get_sorted_player_info()

	# Get the player info, and replace each player stuffs with the relevant info.
	for i in range(sorted_player_info.size()):
		var player_name = sorted_player_info[i][0]
		var this_players_info = sorted_player_info[i][1]

		# Move the score panel to the correct position based on their rank
		var player_panel = score_panels.get_panel_for_player(player_name)
		score_panels.move_child(player_panel, i)

		var display_player: DisplayPlayer = display_player_scene.instantiate()
		var target_position: Node3D = display_player_positions.get_child(i)

		target_position.add_child(display_player)
		display_player.global_position = target_position.global_position

		display_player.name = player_name
		display_player.update_character_display(player_name, this_players_info)

		if (i == 0):
			display_player.animation_player.play("Victory")
		else:
			display_player.animation_player.play("Death")

	_give_rewards(
		sorted_player_info,
		[first_place_reward, second_place_reward, third_place_reward, fourth_place_reward],
	)


# TODO check all player's input
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("p1_sprint")):
		var focused_button = get_viewport().gui_get_focus_owner()
		if (focused_button.name == "Rematch"):
			rematch_clicked()
		elif (focused_button.name == "MainMenu"):
			main_menu_clicked()


func _give_rewards(sorted_player_info: Array, rewards: Array[int]) -> void:
	var index: int = 0
	for player_info in sorted_player_info:
		
		# Skip if bot
		if (player_info[1].is_bot):
			return

		# Update the player's profile
		if (player_info[1].PlayerProfileId < 0):
			return

		var profile = ProfileManager.get_profile_by_id(player_info[1].PlayerProfileId)
		profile.coins += rewards[index]
		ProfileManager.update_profile(profile)

		# Display the player reward
		var panel = score_panels.get_panel_for_player(player_info[0])
		await get_tree().create_timer(reward_interval).timeout
		panel.display_reward(rewards[index])

		index += 1
