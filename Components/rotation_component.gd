class_name RotationComponent
extends RigidbodyManipulatorComponent

func _ready() -> void:
	_init_rigidbody()
	

func look_in_movement_direction(ignore_y: bool = true) -> void:
	var current_velocity = target_rigidbody.linear_velocity if not ignore_y else Vector3(target_rigidbody.linear_velocity.x, 0, target_rigidbody.linear_velocity.z)

	if (current_velocity.length() > 0.3):
		target_rigidbody.look_at_from_position(target_rigidbody.global_position, target_rigidbody.global_position + current_velocity.normalized())
