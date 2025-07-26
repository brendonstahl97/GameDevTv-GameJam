# Class for the customers that will be in the game
# GameController will spawn these customers in a random spot on the map.
# Player will need to approach the customer, once they get close enough, the customer will give them a task.
# The task will be a sequence such as up right right down left left up.
# The player will need to complete the sequence in order to get the reward.
# The reward will be money based on what tier of customer they are.
# The customer will then leave the map and the player will need to find another customer to get more money.

extends Area3D

signal CustomerCompleted
signal customer_type_assigned(customer_type: CustomerType)

@onready var code_submission_sounds: AudioStreamPlayer3D = %CodeSubmissionSounds
@onready var coin_effect_spawner: EffectSpawner = %CoinEffectSpawner
@onready var customer_task_display: CustomerTaskDisplay = %"Customer Task Display"

@export var code_submitted_correct_sound: AudioStream
@export var code_submitted_incorrect_sound: AudioStream
@export var customer_type_loot_table: LootTable
@export var customer_type: CustomerType
@export_enum("Serf", "Normie", "Royalty", "King") var customerTier: String = "Serf"

# The correct sequence that the player needs to input, generated when the customer is spawned
var correctTaskSequence : Array = []

var currentPlayer : Node3D = null
var currentPlayerSequence : Array = []

var completed = false


# STRUCTURE -------------------------------------------------------------------------------------------
func generateSequence() -> Array[Global.CodeDirection]:
	var taskLength = customer_type.task_length
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
	customer_task_display.initialize_task_sequence(taskSequence)

	return taskSequence

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get a random customer tier based on "rarity".
	customer_type = customer_type_loot_table.get_loot()
	customer_type_assigned.emit(customer_type)

	# Spawn the character model
	var desiredCharacter = customer_type.character_model.instantiate()
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
		code_submitter.code_submitted.connect(_on_player_code_submitted)


func _on_body_entered(body:Node3D) -> void:
	if (completed):
		return
		
	# If this is a descendant of Players
	if (!body.is_in_group("Players")):
		return
		
	customer_task_display.visible = true

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
			customer_task_display.visible = false
		$Decal.set_modulate(Color(.77, .33, .092))


# Connect to the player controller 
func playerDirectionalInput(player: Node3D, direction: Global.CodeDirection) -> void:	
	# Is this the correct direction for the next element in the sequence?
	# Grab the length of the current player sequence, check the length + 1 element in the correct sequence
	var nextCorrectDirection : Global.CodeDirection = correctTaskSequence[currentPlayerSequence.size()]
	if (direction == nextCorrectDirection):
		customer_task_display.progress_sequence(currentPlayerSequence.size())
		currentPlayerSequence.append(direction)
		# Play correct sound
		code_submission_sounds.stream = code_submitted_correct_sound
		code_submission_sounds.play()
		# If the player has completed the sequence, give them the reward
		if (currentPlayerSequence.size() == correctTaskSequence.size()):
			completed = true			
			# Give the player the reward
			var reward = customer_type.reward

			# Emit the signal to the game controller
			# Tells the game controller to reward this player this amount.
			CustomerCompleted.emit(reward, player.name)
			global.money_rewarded.emit()
			
			coin_effect_spawner.create_effect(global_position)

			# Remove the customer from the game
			queue_free()
	else:
		# Reset the player sequence
		currentPlayerSequence = []
		# Reset the correct sequence
		correctTaskSequence = generateSequence()
		# Play Incorrect Sound
		code_submission_sounds.stream = code_submitted_incorrect_sound
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
