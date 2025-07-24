class_name MovementComponent
extends RigidbodyManipulatorComponent

@export_category("Movement Config")
@export var move_speed = 10.0 ## Max walking speed
@export var velocity_power = 1.1 ## Affects the intensity that the velocity is changed
@export var standard_acceleration_multiplier = 1.0 ## Used to change the intensity of acceleration 
@export var decceleration_multiplier = 0.5 ## Used to change the intensity of deceleration
@export var decceleration_threshold = 150 ## The angle difference between your current velocity and your input direction necessary to be considered deceleration. ( Ex: 180 is completely backwards )

var sprint_component: SprintComponent

var target_velocity: Vector3 = Vector3.ZERO
var is_movement_constant: bool = false
var constant_movement_direction: Vector3 = Vector3.ZERO

func _ready() -> void:
	sprint_component = find_child("SprintComponent")
	
	_init_rigidbody()


func _physics_process(_delta: float) -> void:
	if ! is_movement_constant:
		return

	target_rigidbody.apply_central_force(get_movement_force(constant_movement_direction))


func get_movement_force(movement_direction: Vector3) -> Vector3:
	target_velocity = movement_direction * move_speed
	
	if (sprint_component != null):
		target_velocity *= sprint_component.sprint_modifier
	
	var current_velocity = get_current_velocity_no_y(target_rigidbody)

	var velocity_difference = target_velocity - current_velocity

	var acceleration_multiplier = float(0)

	if current_velocity.length() > 0 && rad_to_deg(target_velocity.angle_to(current_velocity)) >= decceleration_threshold:
		acceleration_multiplier = decceleration_multiplier
	else:
		acceleration_multiplier = standard_acceleration_multiplier

	var movement = pow(velocity_difference.length() * acceleration_multiplier, velocity_power) * velocity_difference.normalized()

	var movementFinal = Vector3(movement.x, 0, movement.z)

	return movementFinal


func get_current_velocity_no_y(rigidbody: RigidBody3D) -> Vector3:
	return Vector3(rigidbody.linear_velocity.x, 0, rigidbody.linear_velocity.z)


func move(movement_direction: Vector3) -> void:
	if is_movement_constant:
		is_movement_constant = false

	var movement_force = get_movement_force(movement_direction)
	target_rigidbody.apply_central_force(movement_force)


func begin_constant_movement(movement_direction: Vector3) -> void:
	is_movement_constant = true
	constant_movement_direction = movement_direction
