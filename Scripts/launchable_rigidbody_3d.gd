class_name LaunchableRigidbody3D
extends RigidBody3D


func launch(impulse_force: Vector3, _callling_entity: RigidBody3D, _is_parriable := true) -> void:
		apply_impulse(impulse_force)
