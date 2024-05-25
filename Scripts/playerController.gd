extends RigidBody3D

@export var MoveSpeed = 300
@export var BaseTurnRadius = 45
@export var VelocityPower = float(1)
@export var StandardAccelerationMultiplier = float(1)
@export var DeccelerationMultiplier = float(1)
@onready var animation_tree : AnimationTree = $Casual3_Male/AnimationTree

var movementDirection = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_tree.active = true


func _process(delta: float) -> void:
	print(linear_velocity.length())
	update_animation_parameters()	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	movementDirection = Vector3(Input.get_axis("move_left", "move_right"), 0, Input.get_axis("move_up", "move_down")).normalized()
	_handle_movement()
	_handle_rotation()


func _handle_movement() -> void:
	var targetVelocity = movementDirection * MoveSpeed
	
	var velocityDifference = targetVelocity - linear_velocity
	
	var accelerationMultiplier = float(0)
	
	if (linear_velocity.length() > 0 && targetVelocity.angle_to(linear_velocity) >= 150):
		accelerationMultiplier = DeccelerationMultiplier
	else:
		accelerationMultiplier = StandardAccelerationMultiplier
		
	var movement = pow(velocityDifference.length() * accelerationMultiplier, VelocityPower) * velocityDifference.normalized()
	
	var movementFinal = Vector3(movement.x, 0, movement.z)
	
	apply_central_force(movementFinal)
	
	
func _handle_rotation() -> void:
	if (linear_velocity.length() > 0.1):
		look_at_from_position(global_position, global_position + linear_velocity.normalized())



func update_animation_parameters():
		animation_tree["parameters/idle_to_walk/blend_position"] = linear_velocity.length()



