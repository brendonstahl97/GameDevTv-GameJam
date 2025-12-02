class_name SlamComponent
extends RigidbodyManipulatorComponent

signal successful_slam

@export_category("Slam")
@export var slam_speed = 5000.0 ## The speed that you slam
@export var slam_launch_force_multiplier = 1.0 ## A multipler to adjust the force of the launch from the slam
@export var slam_direct_hit_force = 50.0 ## An impulse force amount that is applied when the slam makes a direct hit with another player
@export var slam_impact_shape: Shape3D ## A shape used in the shapeCast calculation to determine the area which players are affected by a slam
@export var slam_allowed_delay: float = 1.0 ## The amount of time a player must wait after leaving the ground before being allowed to slam

@export var slam_effect: PackedScene

var effect_spawner: EffectSpawner

var is_slamming = false
var should_slam_next_physics_frame = false
var highest_y_velocity_during_slam = 0


func begin_slam() -> void:
	is_slamming = true
	
func end_slam() -> void:
	is_slamming = false
	should_slam_next_physics_frame = true
	return


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_rigidbody()
	
	effect_spawner = EffectSpawner.new()
	effect_spawner.effect = slam_effect
	add_child(effect_spawner)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if (is_slamming):
		target_rigidbody.apply_force(Vector3.DOWN * slam_speed * delta)
		if (abs(target_rigidbody.linear_velocity.y) > highest_y_velocity_during_slam):
			highest_y_velocity_during_slam = abs(target_rigidbody.linear_velocity.y)
			
	if (should_slam_next_physics_frame):
		_slam_cast()
		successful_slam.emit()


# TODO Refactor this component into a ShapeCast3D Node
## This MUST only be called in physics process, as the physics space is only accessible then
func _slam_cast() -> void:
	var spaceState = target_rigidbody.get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = slam_impact_shape
	query.transform = target_rigidbody.transform
	var castResults = spaceState.intersect_shape(query)
	
	var momentumY = highest_y_velocity_during_slam * target_rigidbody.mass
	
	effect_spawner.create_effect(target_rigidbody.global_position)
	
	for body in castResults:
		var collider = body.collider
		if (!collider is RigidBody3D || !collider.get_groups().has("Players") || collider == self):
			continue
			
		var bodyDirection = collider.global_position - target_rigidbody.global_position
		
		if (collider.global_position.y < target_rigidbody.global_position.y):
			collider.apply_impulse(Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized() * slam_direct_hit_force)
		else:
			collider.apply_impulse(bodyDirection * momentumY * slam_launch_force_multiplier)
		
	highest_y_velocity_during_slam = 0
	should_slam_next_physics_frame = false
