extends Node

@export var spawnAreaTopLeftPoint: Vector3 = Vector3(-10, 1, -10)
@export var spawnAreaBottomRightPoint: Vector3 = Vector3(10, 1, 10)
@export var spawnInterval: float = 5.0
@export var maxSpawnCount: int = 3
@export_enum("Goal", "Time") var gameMode: String = "Goal"
@export var moneyGoal: int = 2_000
@export var timeLimit: float = 120.0

var gameTimeLeft = timeLimit

var timeSinceLastSpawn = 0.0

var customersNode : Node = null


# STRUCTURE --------------------------------------------------------------------------------------------------
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	customersNode = get_node("/root/Game/Customers")
	if (customersNode == null):
		customersNode = Node.new()
		customersNode.name = "Customers"
		get_node("/root/Game").add_child(customersNode)

	$MatchUi.call("updateGoal", moneyGoal)
	
	spawnCustomer()

func gameCompleted(winner: Node3D) -> void:
	print("Game completed", winner)

# A customer's task was completed, reward the player who did it.
func _on_customer_completed(reward: int, playerIndex: String) -> void:
	var player : Node3D = get_node("/root/Game/Players/" + playerIndex)
	if (player != null):
		var money = player.get_meta("Money")
		if (money == null):
			money = 0
		money += reward
		player.set_meta("Money", money)
		print("Player rewarded: " + str(reward))
		print("Player money: " + str(money))
		
		var matchUI = get_node("/root/Game/MatchUi")
		if (matchUI != null):
			matchUI.call("updatePlayerMoney", playerIndex, money)

		# If the game mode is "Goal" and the player has reached the money goal, end the game
		if (gameMode == "Goal" and money >= moneyGoal):
			gameCompleted(player)
			# get_node("/root/Game").call_deferred("endGame", playerIndex)

		# player.call_deferred("addMoney", reward)
		# customersNode.remove_child(customer)
		# customer.queue_free()

func spawnCustomer() -> void:
	# Create a new customer
	var customer = preload("res://Scenes/Customer.tscn").instantiate()
	# Add the customer to the scene
	customersNode.add_child(customer)
	# Set the customer's position to a random point within the spawn area
	customer.global_transform.origin = Vector3(
		randf_range(spawnAreaTopLeftPoint.x, spawnAreaBottomRightPoint.x),
		randf_range(spawnAreaTopLeftPoint.y, spawnAreaBottomRightPoint.y),
		randf_range(spawnAreaTopLeftPoint.z, spawnAreaBottomRightPoint.z)
	)

	# Connect to customer completed event
	customer.CustomerCompleted.connect(_on_customer_completed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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

	if (gameMode == "Time"):
		gameTimeLeft -= delta
		$MatchUi.call("updateTime", gameTimeLeft)
		if (gameTimeLeft <= 0):
			# Time is over,
			# The winner is whoever has the most money
			var players = get_node("/root/Game/Players").get_children()
			var winner : Node3D = null
			var winnerMoney = 0
			for player in players:
				var money = player.get_meta("Money", 0)
				if (money > winnerMoney):
					winner = player
					winnerMoney = money
			gameCompleted(winner)
