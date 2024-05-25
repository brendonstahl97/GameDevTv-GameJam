extends RigidBody3D

@onready var SprintEmitter1: CPUParticles3D = $"Particle Emitters/CPUParticles3D"
@onready var SprintEmitter2: CPUParticles3D = $"Particle Emitters/CPUParticles3D2"

@export var MoveSpeed = 30
@export var VelocityPower = float(1)
@export var StandardAccelerationMultiplier = float(1)
@export var DeccelerationMultiplier = float(1)
@onready var animation_tree : AnimationTree = $Casual3_Male/AnimationTree

@export var MaxSprintModifier = 3
@export var SprintIncrementAmount = float(0.1)

var MovementDirection = Vector3.ZERO
var SprintModifier = float(1)
var IsSprinting = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_tree.active = true


func _process(delta: float) -> void:
	print(linear_velocity.length())
	update_animation_parameters()	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	MovementDirection = Vector3(Input.get_axis("move_left", "move_right"), 0, Input.get_axis("move_up", "move_down")).normalized()
	
	_handle_sprint(delta)
	_handle_movement()
	_handle_rotation()


func _handle_movement() -> void:
	var targetVelocity = MovementDirection * MoveSpeed * SprintModifier
	
	var velocityDifference = targetVelocity - linear_velocity
	
	var accelerationMultiplier = float(0)
	
	if (linear_velocity.length() > 0 && rad_to_deg(targetVelocity.angle_to(linear_velocity)) >= 150):
		accelerationMultiplier = DeccelerationMultiplier
	else:
		accelerationMultiplier = StandardAccelerationMultiplier
		
	var movement = pow(velocityDifference.length() * accelerationMultiplier, VelocityPower) * velocityDifference.normalized()
	
	var movementFinal = Vector3(movement.x, 0, movement.z)
	
	apply_central_force(movementFinal)
	
	
func _handle_rotation() -> void:
	if (linear_velocity.length() > 0.1):
		look_at_from_position(global_position, global_position + linear_velocity.normalized())
		
func _handle_sprint(delta: float) -> void: 
	if (Input.is_action_just_pressed("Sprint")):
		_start_sprint_particles()
		
	elif (Input.is_action_pressed("Sprint") && SprintModifier < MaxSprintModifier):
		SprintModifier += SprintIncrementAmount * delta
		
	elif (Input.is_action_just_released("Sprint")):
		SprintModifier = 1
		_end_sprint_particles()
		
func _start_sprint_particles() -> void:
	SprintEmitter1.restart()
	SprintEmitter1.emitting = true
	SprintEmitter2.restart()
	SprintEmitter2.emitting = true
	
func _end_sprint_particles() -> void:
	SprintEmitter1.emitting = false
	SprintEmitter2.emitting = false



func update_animation_parameters():
		animation_tree["parameters/idle_to_walk/blend_position"] = linear_velocity.length()



