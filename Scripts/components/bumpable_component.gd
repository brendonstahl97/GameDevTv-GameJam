class_name BumpableComponent
extends RigidbodyManipulatorComponent

signal bumped(bump_force: Vector3, bumping_body: RigidBody3D)

@export_category("Bump")
@export var bumpable_group_name = "Bumpable"
@export var bump_momentum_threshold = 5.0 ## The momentum (Mass x Velocity) threshold for a bump to be triggered when you hit another player
@export var bump_direction_threshold = 60 ## An angle threshold that determines how accurate a player must be for a bump to trigger ( higher is less accurate )
@export var bump_multiplier = 3.0 ## Used to multiplicatively adjust the amount of additional force applied to an opponent when a bump is triggered

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_rigidbody()
	get_parent().add_to_group(bumpable_group_name)
	pass # Replace with function body.


func try_bump(bumping_body: RigidBody3D) -> bool:
	var momentum =  bumping_body.linear_velocity.length() * bumping_body.mass
	
	if (momentum < bump_momentum_threshold):
		return false
		
	var direction_to_body = (target_rigidbody.global_position - bumping_body.global_position).normalized()
	var direction_to_body_no_y = Vector3(direction_to_body.x, 0, direction_to_body.z)
	var bump_trueness = rad_to_deg(direction_to_body_no_y.angle_to(Vector3(bumping_body.linear_velocity.x, 0, bumping_body.linear_velocity.z)))
	
	if (bump_trueness > bump_direction_threshold):
		return false
		
	bumped.emit(direction_to_body_no_y * momentum * bump_multiplier, bumping_body)
	return true
