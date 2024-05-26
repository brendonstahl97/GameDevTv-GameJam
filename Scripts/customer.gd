# Class for the customers that will be in the game
# GameController will spawn these customers in a random spot on the map.
# Player will need to approach the customer, once they get close enough, the customer will give them a task.
# The task will be a sequence such as up right right down left left up.
# The player will need to complete the sequence in order to get the reward.
# The reward will be money based on what tier of customer they are.
# The customer will then leave the map and the player will need to find another customer to get more money.

extends Area3D

@export_enum("Serf", "Normie", "Royalty", "King") var customerTier: String = "Serf"

# Nested dictionary of each enum tier, inside each tier is task length, and reward
var customerTierDataList = {
	"Serf": {
		"taskLength": 4,
		"reward": 20
	},
	"Normie": {
		"taskLength": 5,
		"reward": 30
	},
	"Royalty": {
		"taskLength": 6,
		"reward": 50
	},
	"King": {
		"taskLength": 8,
		"reward": 100
	}
}

# The correct sequence that the player needs to input, generated when the customer is spawned
var correctTaskSequence : Array = []

var currentPlayer : Node3D = null
var currentPlayerSequence : Array = [] 

var completed = false


# STRUCTURE -------------------------------------------------------------------------------------------
func generateSequence() -> Array:
	var taskLength = customerTierDataList[customerTier]["taskLength"]
	var taskSequence = []
	for i in range(taskLength):
		var randomDirection = randi() % 4
		match randomDirection:
			0:
				taskSequence.append("UP")
			1:
				taskSequence.append("RIGHT")
			2:
				taskSequence.append("DOWN")
			3:
				taskSequence.append("LEFT")
	return taskSequence

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Generate the task sequence for the customer
	correctTaskSequence = generateSequence()
	print(correctTaskSequence)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body:Node3D) -> void:
	# If there isn't a player already assigned, assign the customer to the current player
	if currentPlayer == null:
		currentPlayer = body
		# Print the name of the player that entered the area

	print(body.name + " entered")


func _on_body_exited(body:Node3D) -> void:
	currentPlayer = null

	# Find all the players in the area, if there are multiple, grab the closest
	var players = get_overlapping_bodies()
	if players.size() > 0:
		var closestPlayer = players[0]
		for player in players:
			if player.global_transform.origin.distance_to(global_transform.origin) < closestPlayer.global_transform.origin.distance_to(global_transform.origin):
				closestPlayer = player
		currentPlayer = closestPlayer
		print("New player assigned: " + currentPlayer.name)
	else:
		print("No players in area")

# Connect to the player controller 
func playerDirectionalInput(player: Node3D, direction: String) -> void:
	print(player.name +  ", Input: " + direction)
	
	# Is this the correct direction for the next element in the sequence?
	# Grab the length of the current player sequence, check the length + 1 element in the correct sequence
	var nextCorrectDirection : String = correctTaskSequence[currentPlayerSequence.size()]
	if (direction == nextCorrectDirection):
		currentPlayerSequence.append(direction)
		print("Correct")
		# If the player has completed the sequence, give them the reward
		if (currentPlayerSequence.size() == correctTaskSequence.size()):
			completed = true
			print("Player completed the sequence")
			# Give the player the reward
			var reward = customerTierDataList[customerTier]["reward"]
			print("Player rewarded: " + str(reward))
	else:
		print("Incorrect")
		# Reset the player sequence
		currentPlayerSequence = []
		# Reset the correct sequence
		correctTaskSequence = generateSequence()
		print(correctTaskSequence)


func _on_player_code_submitted(input: String, playerIndex: int) -> void:
	if (completed):
		return

	# Find player of name playerIndex
	var player : Node3D = get_node("/root/Game/Players/" + str(playerIndex))
	if (player == null):
		print("No player found with index: " + str(playerIndex))
		return

	# Is the current player equal to the player that submitted the code
	if (currentPlayer != player):
		#print("Player does not have the customer in their area")
		return

	playerDirectionalInput(player, input)