class_name RigidbodyManipulatorComponent
extends Node

var target_rigidbody: RigidBody3D:
	get:
		assert(target_rigidbody != null, "Attempted to get a null target_rigidbody in a Rigidbody Manipulator Component")
		return target_rigidbody

func _init_rigidbody() -> void:
	var parent: RigidBody3D = get_parent()
	assert(parent != null, "Rigidbody Manipulator Component node must be the child of a Rigidbody3D node. Node Type: ")
	target_rigidbody = parent
