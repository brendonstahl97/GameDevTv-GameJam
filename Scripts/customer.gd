# Class for the customers that will be in the game
# GameController will spawn these customers in a random spot on the map.
# Player will need to approach the customer, once they get close enough, the customer will give them a task.
# The task will be a sequence such as up right right down left left up.
# The player will need to complete the sequence in order to get the reward.
# The reward will be money based on what tier of customer they are.
# The customer will then leave the map and the player will need to find another customer to get more money.

extends Area3D

@onready var code_submission_sounds: AudioStreamPlayer3D = $CodeSubmissionSounds

const CODE_SUMBITTED_CORRECT = preload("res://Assets/Audio/CodeSumbittedCorrect.wav")
const CODE_SUMBITTED_INCORRECT = preload("res://Assets/Audio/CodeSumbittedIncorrect.wav")

@export_enum("Serf", "Normie", "Royalty", "King") var customerTier: String = "Serf"

const COIN_EXPLOSION = preload("res://Scenes/coin_explosion.tscn")

# Nested dictionary of each enum tier, inside each tier is task length, and reward
var customerTierDataList = {
	"Serf": {
		"taskLength": 4,
		"reward": 20,
		"rarity": 1, # 40% chance
		"characters": ["Goblin_Male"],
	},
	"Normie": {
		"taskLength": 5,
		"reward": 30,
		"rarity": .6, # 30% chance
		"characters": ["Casual_Female"]
	},
	"Royalty": {
		"taskLength": 6,
		"reward": 50,
		"rarity": .3, # 20% chance
		"characters": ["Knight_Male"]
	},
	"King": {
		"taskLength": 8,
		"reward": 100,
		"rarity": .1, # 10% chance
		"characters": ["Wizard"]
	}
}

# The correct sequence that the player needs to input, generated when the customer is spawned
var correctTaskSequence : Array = []

var currentPlayer : Node3D = null
var currentPlayerSequence : Array = [] 

var completed = false

signal CustomerCompleted


# STRUCTURE -------------------------------------------------------------------------------------------
func generateSequence() -> Array[Global.CodeDirection]:
	var taskLength = customerTierDataList[customerTier]["taskLength"]
	var taskSequence: Array[Global.CodeDirection] = []
	for i in range(taskLength):
		var randomDirection = randi() % 4
		match randomDirection:
			0:
				taskSequence.append(Global.CodeDirection.UP)
			1:
				taskSequence.append(Global.CodeDirection.RIGHT)
			2:
				taskSequence.append(Global.CodeDirection.DOWN)
			3:
				taskSequence.append(Global.CodeDirection.LEFT)

	# Update the UI with the new task sequence
	var arrowsUI: HBoxContainer = $Control/Panel/HBoxContainer
	arrowsUI.get_children()
	for child in arrowsUI.get_children():
		child.queue_free()
	for direction in taskSequence:
		var arrow = get_node("Control/Panel/" + Global.CodeDirection.keys()[direction] + "Arrow").duplicate() 
		arrow.visible = true
		arrowsUI.add_child(arrow)

	return taskSequence

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get a random customer tier based on "rarity".
	var randomTier = randf()
	var keys = customerTierDataList.keys()
	keys.reverse()
	for tier in keys:
		if (randomTier < customerTierDataList[tier]["rarity"]):
			customerTier = tier
			break

	# Spawn the character model
	var desiredCharacter = load("res://Assets/Characters/" + customerTierDataList[customerTier]["characters"][0] + ".gltf").instantiate()
	add_child(desiredCharacter)
	var meshInstance = desiredCharacter.get_node("CharacterArmature/Skeleton3D/Body")
	var oldMeshInstance = get_node("Casual2_Female/CharacterArmature/Skeleton3D/Body")
	meshInstance.reparent(get_node("Casual2_Female/CharacterArmature/Skeleton3D"))
	meshInstance.transform = oldMeshInstance.transform
	desiredCharacter.queue_free()
	oldMeshInstance.queue_free()

	# Generate the task sequence for the customer
	correctTaskSequence = generateSequence()

	for code_submitter: CodeSubmissionComponent in get_tree().get_nodes_in_group("Code_Submitters"):
		print("Found a Code Submitter")
		code_submitter.code_submitted.connect(_on_player_code_submitted)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var screen_pos = get_viewport().get_camera_3d().unproject_position(global_transform.origin)
	var control = $Control

	# Place the control at screen_pos, but have it be offset by the size of the control
	control.position = screen_pos - control.size / 2

	# Move it up by the size of the control, plus a little bit
	control.position.y -= control.size.y + 15


func _on_body_entered(body:Node3D) -> void:
	if (completed):
		return
		
	# If this is a descendant of Players
	if (!body.is_in_group("Players")):
		return
		
	$Control.visible = true

	# If there isn't a player already assigned, assign the customer to the current player
	if currentPlayer == null:
		if (global.playerInfo != null):
			$Decal.set_modulate(global.playerInfo[str(int(str(body.name))+1)]["PlayerColor"])
		currentPlayer = body
		# Print the name of the player that entered the area


func _on_body_exited(_body:Node3D) -> void:
	if (completed):
		return

	currentPlayer = null

	# Find all the players in the area, if there are multiple, grab the closest
	var players = get_overlapping_bodies()
	# Remove all bodies from players which is not in the Players group with a for loop
	for i in range(players.size() - 1, -1, -1):
		if (!players[i].is_in_group("Players")):
			players.remove_at(i)
	
	if players.size() > 0:
		var closestPlayer = players[0]
		for player in players:
			if player.global_transform.origin.distance_to(global_transform.origin) < closestPlayer.global_transform.origin.distance_to(global_transform.origin):
				closestPlayer = player
		currentPlayer = closestPlayer
		if (global.playerInfo != null):
			$Decal.set_modulate(global.playerInfo[str(int(str(currentPlayer.name))+1)]["PlayerColor"])
	else:
		if (currentPlayerSequence.size() == 0):
			$Control.visible = false
		$Decal.set_modulate(Color(.77, .33, .092))

# Connect to the player controller 
func playerDirectionalInput(player: Node3D, direction: Global.CodeDirection) -> void:	
	# Is this the correct direction for the next element in the sequence?
	# Grab the length of the current player sequence, check the length + 1 element in the correct sequence
	var nextCorrectDirection : Global.CodeDirection = correctTaskSequence[currentPlayerSequence.size()]
	if (direction == nextCorrectDirection):
		$Control/Panel/HBoxContainer.get_children()[currentPlayerSequence.size()].set_modulate(Color(0,1,0,1))
		currentPlayerSequence.append(direction)
		# Play correct sound
		code_submission_sounds.stream = CODE_SUMBITTED_CORRECT
		code_submission_sounds.play()
		# If the player has completed the sequence, give them the reward
		if (currentPlayerSequence.size() == correctTaskSequence.size()):
			completed = true			
			# Give the player the reward
			var reward = customerTierDataList[customerTier]["reward"]

			# Emit the signal to the game controller
			# Tells the game controller to reward this player this amount.
			CustomerCompleted.emit(reward, player.name)
			
			var coinExplosion = COIN_EXPLOSION.instantiate()
			coinExplosion.position = global_position
			get_window().add_child(coinExplosion)

			# Remove the customer from the game
			queue_free()
	else:
		# Reset the player sequence
		currentPlayerSequence = []
		# Reset the correct sequence
		correctTaskSequence = generateSequence()
		# Play Incorrect Sound
		code_submission_sounds.stream = CODE_SUMBITTED_INCORRECT
		code_submission_sounds.play()

func _on_player_code_submitted(input: Global.CodeDirection, playerIndex: int) -> void:
	if (completed):
		return

	# Find player of name playerIndex
	var player : Node3D = get_node("/root/Game/Players/" + str(playerIndex))
	if (player == null):
		return

	# Is the current player equal to the player that submitted the code
	if (currentPlayer != player):
		return

	playerDirectionalInput(player, input)
