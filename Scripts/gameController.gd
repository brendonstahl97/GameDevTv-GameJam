extends Node

@export var spawnAreaTopLeftPoint: Vector3 = Vector3(-10, 1, -10)
@export var spawnAreaBottomRightPoint: Vector3 = Vector3(10, 1, 10)
@export var spawnInterval: float = 5.0
@export var maxSpawnCount: int = 3

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
	
	spawnCustomer()

func spawnCustomer() -> void:
	# Create a new customer
	var customer = preload("res://Resources/Customer.tscn").instantiate()
	# Add the customer to the scene
	customersNode.add_child(customer)
	# Set the customer's position to a random point within the spawn area
	customer.global_transform.origin = Vector3(
		randf_range(spawnAreaTopLeftPoint.x, spawnAreaBottomRightPoint.x),
		randf_range(spawnAreaTopLeftPoint.y, spawnAreaBottomRightPoint.y),
		randf_range(spawnAreaTopLeftPoint.z, spawnAreaBottomRightPoint.z)
	)

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
