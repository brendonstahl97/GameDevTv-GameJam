extends RigidBody3D

const FOOD_EXPLOSION = preload("res://Scenes/food_explosion.tscn")
const SECRET_CABBAGE_EXPLOSION = preload("res://Scenes/secret_cabbage_explosion.tscn")

@onready var SprintEmitter1: CPUParticles3D = $"Particle Emitters/CPUParticles3D"
@onready var SprintEmitter2: CPUParticles3D = $"Particle Emitters/CPUParticles3D2"
@onready var animation_tree : AnimationTree = $Casual3_Male/AnimationTree

@export var Controls: PlayerControls
@export var StandClass: Stand

@export var StaminaManager: StaminaManager
@export var ParticleEmitterManager: ParticleEmitterManager

@export_category("Movement")
@export var MoveSpeed = 10.0 ## Max walking speed
@export var VelocityPower = 1.1 ## Affects the intensity that the velocity is changed
@export var StandardAccelerationMultiplier = 1.0 ## Used to change the intensity of acceleration 
@export var DeccelerationMultiplier = 0.5 ## Used to change the intensity of deceleration
@export var DeccelerationThreshold = 150 ## The angle difference between your current velocity and your input direction necessary to be considered deceleration. ( Ex: 180 is completely backwards )

@export_category("Sprint")
@export var MaxSprintModifier = 2.5 ## Affects your maximum speed ( Max speed = MoveSpeed x This Value )
@export var SprintIncrementAmount = 1 ## Affects how quickly you achieve your max sprint speed once you start sprinting

@export_category("Bump")
@export var BumpMomentumThreshold = 5.0 ## The momentum (Mass x Velocity) threshold for a bump to be triggered when you hit another player
@export var BumpDirectionThreshold = 30 ## An angle threshold that determines how accurate a player must be for a bump to trigger ( higher is less accurate )
@export var BumpMultiplier = 3.0 ## Used to multiplicatively adjust the amount of additional force applied to an opponent when a bump is triggered

@export_category("Stamina")
@export var SprintStaminaDrain = 15.0 ## Stamina lost per second while sprinting
@export var CodeSubmissionStaminaCost = 7.5 ## The stamina cost of each code submission button press
@export var BumpStaminaGainMultiplier = 1.0 ## Used to multiplicatively adjust the amount of stamina gained from bumping another player

signal CodeSubmitted

var MovementDirection = Vector3.ZERO
var SprintModifier = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_tree.active = true
	mass = StandClass.Mass

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
	if (StaminaManager.CurrentStamina <= 0):
		# Flash Stamina Bar red
		return 
	
	if (Input.is_action_just_pressed(Controls.sprint)):
		if (StaminaManager.CurrentStamina > 0):
			ParticleEmitterManager.start_sprint_particles()
			StaminaManager.canRegenStamina = false
		
	elif (Input.is_action_pressed(Controls.sprint)):
		if (StaminaManager.CurrentStamina > 1):
			StaminaManager.drainStamina(SprintStaminaDrain * delta)
		else:
			ParticleEmitterManager.end_sprint_particles()
			SprintModifier = 1
		
		if (SprintModifier < MaxSprintModifier):
			SprintModifier += SprintIncrementAmount * delta
		
		
	elif (Input.is_action_just_released(Controls.sprint)):
		StaminaManager.canRegenStamina = true
		SprintModifier = 1
		ParticleEmitterManager.end_sprint_particles()
		
		
func _handle_code_input() -> void:
	if (StaminaManager.CurrentStamina < CodeSubmissionStaminaCost):
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
	StaminaManager.drainStamina(CodeSubmissionStaminaCost)

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
	
	StaminaManager.restoreStamina(momentum * BumpStaminaGainMultiplier)
	
	var foodExplosion = SECRET_CABBAGE_EXPLOSION.instantiate() if (randi_range(0, 10) == 0) else FOOD_EXPLOSION.instantiate()
	foodExplosion.position = body.global_position
	get_window().add_child(foodExplosion)
