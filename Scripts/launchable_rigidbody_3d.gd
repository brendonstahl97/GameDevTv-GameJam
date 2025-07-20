class_name LaunchableRigidbody3D
extends RigidBody3D

# Duck Typed function that should be present on all launchable rigidbody nodes
func launch(impulse_force: Vector3, callling_entity: RigidBody3D, is_parriable := true) -> void:
		apply_impulse(impulse_force)
