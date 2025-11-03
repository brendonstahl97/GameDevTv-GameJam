extends LaunchableRigidbody3D

#@onready var leg: RigidBody3D = %Leg
#@onready var leg_2: RigidBody3D = %Leg2
#
#@export var leg_break_threshold: float = 50.0 ## The impact force required for the turkeys legs to be broken off on hit
#@export var leg_launch_force: float = 50.0
#
#var has_lost_legs := false


func _on_bumpable_component_bumped(bump_force: Vector3, bumping_body: RigidBody3D) -> void:
	launch(bump_force, bumping_body)
	
	#if (has_lost_legs):
		#return
	#
	#if  (bump_force.length() >= leg_break_threshold):
		#leg.reparent(get_parent())
		#leg.apply_impulse(Vector3(randf_range(-1, 1), randf(), 0).normalized() * leg_launch_force)
		#leg_2.reparent(get_parent())
		#leg_2.apply_impulse(Vector3(randf_range(-1, 1), randf(), 0).normalized() * leg_launch_force)
