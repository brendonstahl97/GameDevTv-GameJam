extends Node
# Fire once the players have been created.
signal PlayersSpawned

@onready var environment: GameLevel = $Environment ## This will change based on the loaded level, however it must be changed manually now
@onready var match_ui: Control = %MatchUi
@onready var players_node: Node = %Players
@onready var game_mode: GameMode = $"Timer Game Mode" ## This will change based on the loaded game mode, however it must be changed manually now

# STRUCTURE --------------------------------------------------------------------------------------------------
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global.customer_completed.connect(_on_customer_completed)
	game_mode.game_over.connect(_game_over)

	_setup_players()

	# Hide player panels which dont have a player
	for i in range(4): 
		var player = get_node_or_null("/root/Game/Players/" + str(i))
		if (player == null):
			get_node("/root/Game/MatchUi").hidePlayerPanel(str(i))
	
	game_mode.game_over.connect(_game_over)
	game_mode.start_game()


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
			
			var player_object: Player = preload("res://Entities/Player/player.tscn").instantiate()
			player_object.name = str(int(player_key)-1)

			var controls_resource = ResourceLoader.load("res://Resources/PlayerControls/Player_" + player_key + "_Controls.tres")
			player_object.Controls = controls_resource

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
			print(mesh_instance.name)
			mesh_instance.reparent(player_object.get_node("Casual3_Male/CharacterArmature/Skeleton3D"))
			mesh_instance.transform = old_mesh_instance.transform
			player_guy.queue_free()
			old_mesh_instance.queue_free()

			# Set the color
			var progress_bar : TextureProgressBar = player_object.get_node("StaminaManager/SubViewport/TextureProgressBar")
			progress_bar.set_tint_progress(this_players_info["PlayerColor"])

			# Place the player
			var spawn_point = environment.spawn_points.get_children()[player_index]
			if (spawn_point is Node3D):
				player_object.global_transform.origin = spawn_point.global_position
			else: 
				push_error("The selected spawn point: ", spawn_point.name, "is not a Node3D")
			$Players.add_child(player_object)
			
			player_index += 1

	PlayersSpawned.emit()


# A customer's task was completed, reward the player who did it.
func _on_customer_completed(reward: int, playerIndex: String) -> void:
	var player : Node3D = get_node("/root/Game/Players/" + playerIndex)
	if (player != null):
		var money = global.playerInfo[str(int(str(player.name))+1)]["Money"]
		if (money == null):
			money = 0
		money += reward
		global.playerInfo[str(int(str(player.name))+1)]["Money"] = money
		
		var matchUI = get_node("/root/Game/MatchUi")
		if (matchUI != null):
			matchUI.call("updatePlayerMoney", playerIndex, money)


func _game_over() -> void:
	# The winner is whoever has the most money
	var players = get_node("/root/Game/Players").get_children()
	var winner : Node3D = null
	var winnerMoney = 0
	
	for player in players:
		var money = global.playerInfo[str(int(str(player.name))+1)]["Money"]
		if (money > winnerMoney):
			winner = player
			winnerMoney = money
			
	game_completed(winner)
