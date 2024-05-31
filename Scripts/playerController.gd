class_name Player
extends RigidBody3D

const FOOD_EXPLOSION = preload("res://Scenes/food_explosion.tscn")
const SECRET_CABBAGE_EXPLOSION = preload("res://Scenes/secret_cabbage_explosion.tscn")
const SLAM_IMPACT = preload("res://Scenes/slam_impact.tscn")
const PARRY_EFFECT = preload("res://Scenes/parry_effect.tscn")

@onready var SprintEmitter1: CPUParticles3D = $"Particle Emitters/CPUParticles3D"
@onready var SprintEmitter2: CPUParticles3D = $"Particle Emitters/CPUParticles3D2"
@onready var animation_tree : AnimationTree = $Casual3_Male/AnimationTree
@onready var floor_detection_ray_cast: RayCast3D = $FloorDetectionRayCast
@onready var AudioPlayer: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var scrape_sound_player: AudioStreamPlayer3D = $ScrapeSoundEffect
@onready var parry_timer: Timer = $ParryTimer
@onready var parry_slow_timer: Timer = $ParrySlowTimer

@export var Controls: PlayerControls
@export var StandClass: Stand

@export var StaminaManagerInstance: StaminaManager
@export var ParticleManager: ParticleEmitterManager

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
@export var BumpSoundEffect: AudioStream
@export var CollisionSoundEffects: Array ## Fill with string locations of potential sounds for non-bump collisions

@export_category("Slam")
@export var SlamSpeed = 5000.0 ## The speed that you slam
@export var SlamLaunchForceMultiplier = 1.0 ## A multipler to adjust the force of the launch from the slam
@export var SlamDirectHitForce = 50.0 ## An impulse force amount that is applied when the slam makes a direct hit with another player
@export var SlamImpactShape: Shape3D ## A shape used in the shapeCast calculation to determine the area which players are affected by a slam

@export_category("Stamina")
@export var SprintStaminaDrain = 15.0 ## Stamina lost per second while sprinting
@export var CodeSubmissionStaminaCost = 7.5 ## The stamina cost of each code submission button press
@export var BumpStaminaGainMultiplier = 1.0 ## Used to multiplicatively adjust the amount of stamina gained from bumping another player

@export_category("Parry")
@export var ParryForceMultiplier = 1.0 ## A force multiplier applied to the launch 
@export var ParrySlowTimeAmount =  0.5 ## Intensity of time slowdown 0 = stop time, 1 = full speed
@export var ParrySlowTimeLength = 1.0 ## How long time should be slowed on a successful parry in seconds
@export var ParryEffectOffset = Vector3(0, 1, 0)
@export var ParrySoundEffect: AudioStream

@export_category("Appearance")
@export var PlayerName : String = "Player"
@export var PlayerCartType : String = "Normal"
@export var PlayerColor : Color = Color(.8, .19, 0.01)
@export var PlayerGuy : String = "Man 1"

signal CodeSubmitted
signal StaminaConsumptionFailed
signal SuccessfulParry(Position: Vector3)

var MovementDirection = Vector3.ZERO
var SprintModifier = 1.0

var ShouldSlamNextPhysicsFrame = false
var highestYVelocityDuringSlam = 0

var IsParrying = false
var DidSuccesfullyParry = false
var IsSlamming = false
var IsGrounded: bool:
	get:
		return floor_detection_ray_cast.is_colliding()


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
	_handle_slam(delta)
	_handle_parry()
	
	if (ShouldSlamNextPhysicsFrame):
		SlamCast()

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
	if (Input.is_action_just_pressed(Controls.sprint)):
		if (StaminaManagerInstance.CurrentStamina > 0):
			ParticleManager.start_sprint_particles()
			StaminaManagerInstance.canRegenStamina = false
			if (IsGrounded):
				scrape_sound_player.play()
		else:
			StaminaConsumptionFailed.emit()
		
	elif (Input.is_action_pressed(Controls.sprint)):
		if (StaminaManagerInstance.CurrentStamina > 1):
			StaminaManagerInstance.drainStamina(SprintStaminaDrain * delta)
			if (IsGrounded):
				if (!scrape_sound_player.playing):
					scrape_sound_player.play()
			else:
				if (scrape_sound_player.playing):
					scrape_sound_player.stop()
		else:
			ParticleManager.end_sprint_particles()
			SprintModifier = 1
			StaminaConsumptionFailed.emit()
			if (scrape_sound_player.playing):
				scrape_sound_player.stop()
		
		if (SprintModifier < MaxSprintModifier):
			SprintModifier += SprintIncrementAmount * delta
		
		
	elif (Input.is_action_just_released(Controls.sprint)):
		print("Released Sprint")
		StaminaManagerInstance.canRegenStamina = true
		SprintModifier = 1
		ParticleManager.end_sprint_particles()
		scrape_sound_player.stop()

func _handle_code_input() -> void:
	if (Input.is_action_just_pressed(Controls.code_up)):
		_submit_code("UP")
	elif (Input.is_action_just_pressed(Controls.code_left)):
		_submit_code("LEFT")
	elif (Input.is_action_just_pressed(Controls.code_right)):
		_submit_code("RIGHT")
	elif (Input.is_action_just_pressed(Controls.code_down)):
		_submit_code("DOWN")

func _handle_parry() -> void:
	if (Input.is_action_just_pressed(Controls.parry) && !IsParrying):
		IsParrying = true
		parry_timer.start()
		
func _handle_slam(delta) -> void:
	if(Input.is_action_just_pressed(Controls.slam)):
		if (!IsGrounded):
			IsSlamming = true
	
	if (IsSlamming):
		apply_force(Vector3.DOWN * SlamSpeed * delta)
		if (abs(linear_velocity.y) > highestYVelocityDuringSlam):
			highestYVelocityDuringSlam = abs(linear_velocity.y)

func _submit_code(codeDirection: String) -> void:
	if (StaminaManagerInstance.CurrentStamina < CodeSubmissionStaminaCost):
		StaminaConsumptionFailed.emit()
		return
	CodeSubmitted.emit(codeDirection, Controls.PlayerIndex)
	StaminaManagerInstance.drainStamina(CodeSubmissionStaminaCost)

func update_animation_parameters():
	animation_tree["parameters/idle_to_walk/blend_position"] = linear_velocity.length()
	
## This MUST only be called in physics process, as the physics space is only accessible then
func SlamCast() -> void:
	var spaceState = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = SlamImpactShape
	query.transform = transform
	var castResults = spaceState.intersect_shape(query)
	
	var momentumY = highestYVelocityDuringSlam * mass
	
	var slamImpact = SLAM_IMPACT.instantiate()
	slamImpact.global_position = global_position
	get_window().add_child(slamImpact)
	
	for body in castResults:
		var collider = body.collider
		if (!collider is RigidBody3D || !collider.get_groups().has("Players") || collider == self):
			continue
			
		var bodyDirection = collider.global_position - global_position
		
		if (collider.global_position.y < global_position.y):
			collider.apply_impulse(Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized() * SlamDirectHitForce)
		else:
			collider.apply_impulse(bodyDirection * momentumY * SlamLaunchForceMultiplier)
		
	highestYVelocityDuringSlam = 0
	ShouldSlamNextPhysicsFrame = false
	
func launch(impulseForce: Vector3, callingPlayer: Player, isParryable := true) -> void:
	if (IsParrying && isParryable):
		callingPlayer.launch((-impulseForce + Vector3.DOWN).normalized() * impulseForce.length() * ParryForceMultiplier, self, false)
		
		var parryVisuals = PARRY_EFFECT.instantiate()
		
		parryVisuals.scale = Vector3.ONE * 2
		parryVisuals.position = global_position + ParryEffectOffset + -impulseForce.normalized() * 0.1
		get_window().add_child(parryVisuals)
		
		parryVisuals.look_at(Vector3(callingPlayer.global_position.x, parryVisuals.global_position.y, callingPlayer.global_position.z))
		
		AudioPlayer.stream = ParrySoundEffect
		AudioPlayer.play()
		
		Engine.time_scale = ParrySlowTimeAmount
		parry_slow_timer.start(ParrySlowTimeLength * ParrySlowTimeAmount)
		
		DidSuccesfullyParry = true
		SuccessfulParry.emit(global_position)
		
	else:
		apply_impulse(impulseForce)
		if (isParryable):
			apply_torque_impulse(Vector3.UP * impulseForce.length() * randf_range(-1, 1))
			
			var foodExplosion = SECRET_CABBAGE_EXPLOSION.instantiate() if (randi_range(0, 10) == 0) else FOOD_EXPLOSION.instantiate()
			foodExplosion.position = callingPlayer.global_position
			get_window().add_child(foodExplosion)
			
			AudioPlayer.stream = BumpSoundEffect
			AudioPlayer.play()

func _on_body_entered(body: Node3D) -> void:
	if (IsSlamming):
		IsSlamming = false
		ShouldSlamNextPhysicsFrame = true
		return
	
	if (!body.get_groups().has("Players")):
		return
		
	if (!body is Player):
		return
		
	var momentum = linear_velocity.length() * mass
	
	if (momentum < BumpMomentumThreshold):
		if (!AudioPlayer.playing):
			AudioPlayer.stream = load(CollisionSoundEffects.pick_random())
			AudioPlayer.play()
		return
		
	# TODO Probably normalize this
	var directionToBody = (body.global_position - position).normalized()
	var directionToBodyNoY = Vector3(directionToBody.x, 0, directionToBody.z)
	var bumpTrueness = rad_to_deg(directionToBodyNoY.angle_to(Vector3(linear_velocity.x, 0, linear_velocity.z)))
		
	if (bumpTrueness > BumpDirectionThreshold):
		return
	
	# Call Function on player here
	body.launch(directionToBodyNoY * momentum * BumpMultiplier, self)
	
	StaminaManagerInstance.restoreStamina(momentum * BumpStaminaGainMultiplier)


func _on_parry_slow_timer_timeout() -> void:
	Engine.time_scale = 1

func _on_parry_timer_timeout() -> void:
	if (!DidSuccesfullyParry):
		StaminaManagerInstance.drainStamina(StaminaManagerInstance.MaxStamina)
	
	IsParrying = false
	DidSuccesfullyParry = false
