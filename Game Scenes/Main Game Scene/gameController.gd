extends Node
# Fire once the players have been created.
signal PlayersSpawned

@onready var environment: GameLevel = $Environment ## This will change based on the loaded level, however it must be changed manually now
@onready var customersNode : Node = %Customers
@onready var match_ui: Control = %MatchUi
@onready var players_node: Node = %Players
@onready var game_mode: GameMode = $"Timer Game Mode" ## This will change based on the loaded game mode, however it must be changed manually now

@export_category("Customer Spawn")
@export var spawnInterval: float = 5.0
@export var maxSpawnCount: int = 3

var timeSinceLastSpawn = 0.0



# STRUCTURE --------------------------------------------------------------------------------------------------
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_mode.game_over.connect(_game_over)
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
		for playerKey in global.playerInfo:
			# Init more player info
			global.playerInfo[playerKey]["Money"] = 0

			var thisPlayersInfo = global.playerInfo[playerKey]
			var playerObject: Player = preload("res://Entities/Player/player.tscn").instantiate()
			playerObject.name = str(int(playerKey)-1)

			var controlsResource = ResourceLoader.load("res://Resources/PlayerControls/Player_" + playerKey + "_Controls.tres")
			playerObject.Controls = controlsResource

			# Set player stand
			playerObject.get_node("Stands/Light").visible = false
			playerObject.get_node("Stands/Medium").visible = false
			playerObject.get_node("Stands/Heavy").visible = false
			playerObject.get_node("Stands/" + thisPlayersInfo["PlayerCart"]).visible = true
			# Delete the other stands
			for stand in playerObject.get_node("Stands").get_children():
				if (stand.name != thisPlayersInfo["PlayerCart"]):
					stand.queue_free()
			var standTypeResource = ResourceLoader.load("res://Resources/Stands/" + thisPlayersInfo["PlayerCart"] + "Stand.tres")
			playerObject.stand_class = standTypeResource

			# Set the guy
			# Spawn a new instance of the character asset, switch the "Body" mesh instance.
			var playerGuy = load("res://Assets/Characters/" + thisPlayersInfo["PlayerGuy"] + ".gltf").instantiate()
			add_child(playerGuy)
			var meshInstance = playerGuy.get_node("CharacterArmature/Skeleton3D/Body")
			var oldMeshInstance = playerObject.get_node("Casual3_Male/CharacterArmature/Skeleton3D/Body")
			print(meshInstance.name)
			meshInstance.reparent(playerObject.get_node("Casual3_Male/CharacterArmature/Skeleton3D"))
			meshInstance.transform = oldMeshInstance.transform
			playerGuy.queue_free()
			oldMeshInstance.queue_free()

			# Set the color
			var progressBar : TextureProgressBar = playerObject.get_node("StaminaManager/SubViewport/TextureProgressBar")
			#var progressBar : TextureProgressBar = playerObject.StaminaManager.SubViewport.TextureProgressBar
			progressBar.set_tint_progress(thisPlayersInfo["PlayerColor"])

			# Place the player
			var spawnPoint = environment.spawn_points.get_children()[player_index]
			if (spawnPoint is Node3D):
				playerObject.global_transform.origin = spawnPoint.global_position
			else: 
				push_error("The selected spawn point: ", spawnPoint.name, "is not a Node3D")
			$Players.add_child(playerObject)
			
			player_index += 1

	PlayersSpawned.emit()

	# Hide player panels which dont have a player
	for i in range(4): 
		var player = get_node_or_null("/root/Game/Players/" + str(i))
		if (player == null):
			get_node("/root/Game/MatchUi").hidePlayerPanel(str(i))

	spawnCustomer()
	
	game_mode.game_over.connect(_game_over)
	game_mode.start_game()
	

func _physics_process(delta: float) -> void:
	# Every spawnInterval seconds, spawn a new customer, if the number of customers is less than maxSpawnCount
	# Has enough time passed to spawn a new customer?
	timeSinceLastSpawn += delta
	if timeSinceLastSpawn >= spawnInterval:
		# Is there room for a new customer?
		if customersNode.get_children().size() < maxSpawnCount:
			# Spawn a new customer
			spawnCustomer()
			# Reset the timer
			timeSinceLastSpawn = 0

func gameCompleted(_winner: Node3D) -> void:
	BackgroundMusic.crossfade_to(BackgroundMusic.get_child(3).stream)
	get_tree().change_scene_to_file("res://Game Scenes/Game Over/endOfGame.tscn")

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


func setCustomerPos(customer: Area3D):
	customer.visible = false
	customer.global_transform.origin = environment.get_customer_spawn_point()
	
	# Is it overlapping anything?
	var scene_tree = get_tree()
	await scene_tree.physics_frame
	await scene_tree.physics_frame
	var overlaps = customer.get_overlapping_bodies() 
	for overlap in overlaps:
		#print(overlap.name)
		if (overlap.is_in_group("Environment")):
			setCustomerPos(customer)
			break
	
	customer.visible = true

func spawnCustomer() -> void:
	# Create a new customer
	var customer = preload("res://Entities/Customer/Customer.tscn").instantiate()
	# Add the customer to the scene
	customersNode.add_child(customer)
	
	# Set the customer's position to a random point within the spawn area
	setCustomerPos(customer)

	# Connect to customer completed event
	customer.CustomerCompleted.connect(_on_customer_completed)


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
	gameCompleted(winner)
