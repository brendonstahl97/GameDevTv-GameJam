# Class for the customers that will be in the game
# GameController will spawn these customers in a random spot on the map.
# Player will need to approach the customer, once they get close enough, the customer will give them a task.
# The task will be a sequence such as up right right down left left up.
# The player will need to complete the sequence in order to get the reward.
# The reward will be money based on what tier of customer they are.
# The customer will then leave the map and the player will need to find another customer to get more money.

extends Area3D

@export_enum("Serf", "Normie", "Royalty", "King") var customerTier: String = "Serf"

const COIN_EXPLOSION = preload("res://Scenes/coin_explosion.tscn")

# Nested dictionary of each enum tier, inside each tier is task length, and reward
var customerTierDataList = {
	"Serf": {
		"taskLength": 4,
		"reward": 20,
		"rarity": 1 # 40% chance
	},
	"Normie": {
		"taskLength": 5,
		"reward": 30,
		"rarity": .6 # 30% chance
	},
	"Royalty": {
		"taskLength": 6,
		"reward": 50,
		"rarity": .3 # 20% chance
	},
	"King": {
		"taskLength": 8,
		"reward": 100,
		"rarity": .1 # 10% chance
	}
}

# The correct sequence that the player needs to input, generated when the customer is spawned
var correctTaskSequence : Array = []

var currentPlayer : Node3D = null
var currentPlayerSequence : Array = [] 

var completed = false

signal CustomerCompleted


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

	# Update the UI with the new task sequence
	var arrowsUI: HBoxContainer = $Control/Panel/HBoxContainer
	arrowsUI.get_children()
	for child in arrowsUI.get_children():
		child.queue_free()
	for direction in taskSequence:
		var arrow = get_node("Control/Panel/" + direction + "Arrow").duplicate() 
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
		print(tier, randomTier, customerTierDataList[tier]["rarity"])
		if (randomTier < customerTierDataList[tier]["rarity"]):
			customerTier = tier
			break
	print("Customer Tier: " + customerTier, "Rarity: " + str(randomTier))

	# Generate the task sequence for the customer
	correctTaskSequence = generateSequence()

	for player in get_node("/root/Game/Players").get_children():
		player.CodeSubmitted.connect(_on_player_code_submitted)

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

	# If there isn't a player already assigned, assign the customer to the current player
	if currentPlayer == null:
		$Decal.set_modulate(body.PlayerColor)
		currentPlayer = body
		# Print the name of the player that entered the area

	print(body.name + " entered")


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
		$Decal.set_modulate(Color(0, 1, .2))
		print("New player assigned: " + currentPlayer.name)
	else:
		$Decal.set_modulate(Color(.77, .33, .092))
		print("No players in area")

# Connect to the player controller 
func playerDirectionalInput(player: Node3D, direction: String) -> void:
	print(player.name +  ", Input: " + direction)
	
	# Is this the correct direction for the next element in the sequence?
	# Grab the length of the current player sequence, check the length + 1 element in the correct sequence
	var nextCorrectDirection : String = correctTaskSequence[currentPlayerSequence.size()]
	if (direction == nextCorrectDirection):
		$Control/Panel/HBoxContainer.get_children()[currentPlayerSequence.size()].set_modulate(Color(0,1,0,1))
		currentPlayerSequence.append(direction)
		print("Correct")
		# If the player has completed the sequence, give them the reward
		if (currentPlayerSequence.size() == correctTaskSequence.size()):
			completed = true
			print("Player completed the sequence")
			
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
		print("Incorrect")
		# Reset the player sequence
		currentPlayerSequence = []
		# Reset the correct sequence
		correctTaskSequence = generateSequence()
		print(correctTaskSequence)

func _on_player_code_submitted(input: String, playerIndex: int) -> void:
	print("Code: ", input, "Player: ", playerIndex + 1)
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
