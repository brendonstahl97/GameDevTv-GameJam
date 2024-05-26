extends RigidBody3D

const FOOD_EXPLOSION = preload("res://Scenes/food_explosion.tscn")

@onready var SprintEmitter1: CPUParticles3D = $"Particle Emitters/CPUParticles3D"
@onready var SprintEmitter2: CPUParticles3D = $"Particle Emitters/CPUParticles3D2"
@onready var animation_tree : AnimationTree = $Casual3_Male/AnimationTree

@export_category("Movement")
@export var MoveSpeed = 30
@export var VelocityPower = 1.0
@export var StandardAccelerationMultiplier = 1.0
@export var DeccelerationMultiplier = 1.0
@export var Controls: PlayerControls

@export_category("Sprint")
@export var MaxSprintModifier = 3
@export var SprintIncrementAmount = 0.1 # Per Second

@export_category("Bump")
@export var BumpMomentumThreshold = 10 # Momentum
@export var BumpDirectionThreshold = 30 # Degrees
@export var BumpMultiplier = 1

@export_category("Stamina")
@export var MaxStamina = 100.0
@export var SprintStaminaDrain = 15.0 # Per Second
@export var CodeSubmissionStaminaCost = 5.0 # Each Button Press
@export var BumpStaminaGainMultiplier = 1.0
@export var PassiveStamingaRegen = 20.0 # Per Second

signal CodeSubmitted

var MovementDirection = Vector3.ZERO
var SprintModifier = float(1)
var IsSprinting = false
var CurrentStamina = 100.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_tree.active = true

func _process(_delta: float) -> void:
	update_animation_parameters()
	_handle_code_input()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	MovementDirection = Vector3(Input.get_axis(Controls.move_left, Controls.move_right), 0, Input.get_axis(Controls.move_up, Controls.move_down)).normalized()
	var currentVelocity = Vector3(linear_velocity.x, 0, linear_velocity.z)
	
	_handle_sprint(delta)
	_handle_movement(currentVelocity)
	_handle_rotation(currentVelocity)
	_handle_stamina_regen(delta)


func _handle_movement(currentVelocity: Vector3) -> void:
	var targetVelocity = MovementDirection * MoveSpeed * SprintModifier

	var velocityDifference = targetVelocity - currentVelocity
	
	var accelerationMultiplier = float(0)
	
	if (currentVelocity.length() > 0 && rad_to_deg(targetVelocity.angle_to(currentVelocity)) >= 150):
		accelerationMultiplier = DeccelerationMultiplier
	else:
		accelerationMultiplier = StandardAccelerationMultiplier
		
	var movement = pow(velocityDifference.length() * accelerationMultiplier, VelocityPower) * velocityDifference.normalized()
	
	var movementFinal = Vector3(movement.x, 0, movement.z)
	
	apply_central_force(movementFinal)
	
	
func _handle_rotation(currentVelocity: Vector3) -> void:
	if (currentVelocity.length() > 0.3 && MovementDirection.length() >= 0.3):
		look_at_from_position(global_position, global_position + currentVelocity.normalized())
		
func _handle_sprint(delta: float) -> void: 
	if (CurrentStamina <= 0):
		# Flash Stamina Bar red
		return 
	
	if (Input.is_action_just_pressed(Controls.sprint)):
		if (CurrentStamina > 0):
			_start_sprint_particles()
			IsSprinting = true
		
	elif (Input.is_action_pressed(Controls.sprint)):
		if (CurrentStamina > 1):
			CurrentStamina -= SprintStaminaDrain * delta
		else:
			_end_sprint_particles()
			SprintModifier = 1
		
		if (SprintModifier < MaxSprintModifier):
			SprintModifier += SprintIncrementAmount * delta
		
		
	elif (Input.is_action_just_released(Controls.sprint)):
		IsSprinting = false
		SprintModifier = 1
		_end_sprint_particles()
		
		
func _handle_code_input() -> void:
	if (CurrentStamina < CodeSubmissionStaminaCost):
		# Flash Stamina bar red
		return
	
	if (Input.is_action_just_pressed(Controls.code_up)):
		_submit_code("UP")
	elif (Input.is_action_just_pressed(Controls.code_left)):
		_submit_code("LEFT")
	elif (Input.is_action_just_pressed(Controls.code_right)):
		_submit_code("RIGHT")
	elif (Input.is_action_just_pressed(Controls.code_down)):
		_submit_code("DOWN")
		
func _submit_code(codeDirection: String) -> void:
	CodeSubmitted.emit(codeDirection, Controls.PlayerIndex)
	CurrentStamina -= CodeSubmissionStaminaCost
		
func _handle_stamina_regen(delta) -> void:
	if (CurrentStamina < MaxStamina && !IsSprinting):
		CurrentStamina += PassiveStamingaRegen * delta
	
	CurrentStamina = clampf(CurrentStamina , 0, MaxStamina)
	
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

func _on_body_entered(body: Node3D) -> void:
	if (body.get_groups().any(func(group): group != "Players")):
		return
		
	if (!body is RigidBody3D):
		return
		
	var momentum = linear_velocity.length() * mass
	
	if (momentum < BumpMomentumThreshold):
		return
		
	var directionToBody = body.global_position - position
	var directionToBodyNoY = Vector3(directionToBody.x, 0, directionToBody.z)
	var bumpTrueness = rad_to_deg(directionToBodyNoY.angle_to(Vector3(linear_velocity.x, 0, linear_velocity.z)))
		
	if (bumpTrueness > BumpDirectionThreshold):
		return
	
	body.apply_impulse(directionToBody * momentum * BumpMultiplier)
	body.apply_torque_impulse(Vector3.UP * momentum * BumpMultiplier * randf_range(-1, 1))
	linear_velocity = Vector3.ZERO
	
	CurrentStamina += momentum * BumpStaminaGainMultiplier
	
	var foodExplosion = FOOD_EXPLOSION.instantiate()
	foodExplosion.position = body.global_position
	get_window().add_child(foodExplosion)
