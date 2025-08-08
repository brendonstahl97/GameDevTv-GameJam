extends Node
# Fire once the players have been created.
signal PlayersSpawned

@onready var environment: GameLevel = $Environment ## This will change based on the loaded level, however it must be changed manually now
@onready var match_ui: Control = %MatchUi
@onready var players_node: Node = %Players
@onready var game_mode: GameMode = $"Timer Game Mode" ## This will change based on the loaded game mode, however it must be changed manually now
@onready var pause_menu: Control = %PauseMenu

@export var player_scene: PackedScene
@export var bot_scene: PackedScene

# STRUCTURE --------------------------------------------------------------------------------------------------
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global.customer_completed.connect(_on_customer_completed)

	_setup_players()

	# Hide player panels which dont have a player
	match_ui.initialize_score_panels()
	
	game_mode.game_over.connect(_game_over)
	game_mode.start_game()


func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("ui_cancel")):
		pause_menu.open()


func game_completed(_winner: Node3D) -> void:
	BackgroundMusic.crossfade_to(BackgroundMusic.get_child(3).stream)
	get_tree().change_scene_to_file("res://Game Scenes/Game Over/endOfGame.tscn")


func _setup_players() -> void:
	# Spawn in players
	# If there is a playerInfo, assume character select was the last scene, delete the base players
	# and spawn in the selected players.
	# If there is not, assume we're testing the game (run scene button while in game scene) and leave the base players in.
	if (global.playerInfo != null):
		# Remove base players.
		for basePlayer in players_node.get_children():
			basePlayer.free()

		var player_index = 0
		# Spawn in joined players.
		for player_key in global.playerInfo:
			# Init more player info
			var this_players_info = global.playerInfo[player_key]
			this_players_info["Money"] = 0
			
			var scene_to_spawn = player_scene
			
			if (this_players_info["is_bot"]):
				scene_to_spawn = bot_scene
				
			var player_object: Player = scene_to_spawn.instantiate()
			player_object.name = player_key

			player_object.Controls = this_players_info["PlayerControls"]
			
			if (player_object is BotPlayer):
				player_object.apply_difficulty(this_players_info["bot_difficulty"])

			# Set player stand
			player_object.get_node("Stands/Light").visible = false
			player_object.get_node("Stands/Medium").visible = false
			player_object.get_node("Stands/Heavy").visible = false
			player_object.get_node("Stands/" + this_players_info["PlayerCart"]).visible = true
			# Delete the other stands
			for stand in player_object.get_node("Stands").get_children():
				if (stand.name != this_players_info["PlayerCart"]):
					stand.queue_free()
			var stand_type_resource = ResourceLoader.load("res://Resources/Stands/" + this_players_info["PlayerCart"] + "Stand.tres")
			player_object.stand_class = stand_type_resource

			# Set the guy
			# Spawn a new instance of the character asset, switch the "Body" mesh instance.
			var player_guy = load("res://Assets/Characters/" + this_players_info["PlayerGuy"] + ".gltf").instantiate()
			add_child(player_guy)
			var mesh_instance = player_guy.get_node("CharacterArmature/Skeleton3D/Body")
			var old_mesh_instance = player_object.get_node("Casual3_Male/CharacterArmature/Skeleton3D/Body")
			mesh_instance.reparent(player_object.get_node("Casual3_Male/CharacterArmature/Skeleton3D"))
			mesh_instance.transform = old_mesh_instance.transform
			player_guy.queue_free()
			old_mesh_instance.queue_free()

			# Set the color
			var progress_bar : TextureProgressBar = player_object.get_node("StaminaManager/SubViewport/TextureProgressBar")
			progress_bar.set_tint_progress(this_players_info["PlayerColor"])

			# Place the player
			var spawn_point = environment.spawn_points.get_children()[player_index]
			$Players.add_child(player_object)
			if (spawn_point is Node3D):
				player_object.global_transform.origin = spawn_point.global_position
			else: 
				push_error("The selected spawn point: ", spawn_point.name, "is not a Node3D")
			
			player_index += 1

	PlayersSpawned.emit()


# A customer's task was completed, reward the player who did it.
func _on_customer_completed(reward: int, player_name: String) -> void:
	var player : Node3D = get_node("/root/Game/Players/" + player_name)
	if (player != null):
		var money = global.playerInfo[player.name]["Money"]
		if (money == null):
			money = 0
		money += reward
		global.playerInfo[player_name]["Money"] = money
		
		if (match_ui != null && match_ui.has_method("update_player_score")):
			match_ui.update_player_score(player_name, money)


func _game_over() -> void:
	# The winner is whoever has the most money
	var players = get_node("/root/Game/Players").get_children()
	var winner : Node3D = null
	var winnerMoney = 0
	
	for player in players:
		var money = global.playerInfo[player.name]["Money"]
		if (money > winnerMoney):
			winner = player
			winnerMoney = money
			
	game_completed(winner)
