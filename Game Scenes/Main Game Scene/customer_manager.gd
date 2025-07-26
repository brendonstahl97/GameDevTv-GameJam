extends Node

@onready var environment: GameLevel = $"../Environment"

@export var customer_scene: PackedScene
@export var spawn_interval: float = 5.0
@export var max_spawn_count: int = 3

var time_since_last_spawn = 0.0
var can_begin_spawning: bool = false

func _process(delta: float) -> void:
	if (can_begin_spawning == false):
		return
	
	# Every spawnInterval seconds, spawn a new customer, if the number of customers is less than maxSpawnCount
	# Has enough time passed to spawn a new customer?
	time_since_last_spawn += delta
	if time_since_last_spawn >= spawn_interval:
		# Is there room for a new customer?
		if (get_children().size() < max_spawn_count):
			# Spawn a new customer
			spawn_customer()
			# Reset the timer
			time_since_last_spawn = 0


func set_customer_position(customer: Area3D):
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
			set_customer_position(customer)
			break
	
	customer.visible = true


func spawn_customer() -> void:
	# Create a new customer
	var customer = customer_scene.instantiate()
	
	# Add the customer to the scene
	add_child(customer)
	
	# Set the customer's position to a random point within the spawn area
	set_customer_position(customer)


func _on_game_players_spawned() -> void:
	can_begin_spawning = true
	spawn_customer()
