class_name Player
extends RigidBody3D

const FOOD_EXPLOSION = preload("res://Scenes/food_explosion.tscn")
const SECRET_CABBAGE_EXPLOSION = preload("res://Scenes/secret_cabbage_explosion.tscn")
const PARRY_EFFECT = preload("res://Scenes/parry_effect.tscn")

@onready var animation_tree : AnimationTree = $Casual3_Male/AnimationTree
@onready var floor_detection_ray_cast: RayCast3D = $FloorDetectionRayCast
@onready var AudioPlayer: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var scrape_sound_player: AudioStreamPlayer3D = $ScrapeSoundEffect
@onready var parry_timer: Timer = $ParryTimer
@onready var parry_slow_timer: Timer = $ParrySlowTimer
@onready var stamina_buzz_player: AudioStreamPlayer3D = $StaminaBuzz

@onready var movement_component: MovementComponent = %MovementComponent
@onready var rotation_component: RotationComponent = %RotationComponent
@onready var sprint_component: SprintComponent = %SprintComponent
@onready var parry_component: ParryComponent = %ParryComponent
@onready var slam_component: SlamComponent = %SlamComponent
@onready var bumpable_component: BumpableComponent = %BumpableComponent

@export var Controls: PlayerControls
@export var StandClass: Stand

@export var StaminaManagerInstance: StaminaManager

@export_category("Bump")
@export var BumpMomentumThreshold = 5.0 ## The momentum (Mass x Velocity) threshold for a bump to be triggered when you hit another player
@export var BumpDirectionThreshold = 30 ## An angle threshold that determines how accurate a player must be for a bump to trigger ( higher is less accurate )
@export var BumpMultiplier = 3.0 ## Used to multiplicatively adjust the amount of additional force applied to an opponent when a bump is triggered
@export var BumpSoundEffect: AudioStream
@export var CollisionSoundEffects: Array ## Fill with string locations of potential sounds for non-bump collisions


@export_category("Stamina")
@export var SprintStaminaDrain = 15.0 ## Stamina lost per second while sprinting
@export var CodeSubmissionStaminaCost = 7.5 ## The stamina cost of each code submission button press
@export var BumpStaminaGainMultiplier = 1.0 ## Used to multiplicatively adjust the amount of stamina gained from bumping another player

@export_category("Appearance")
@export var PlayerName : String = "Player"
@export var PlayerCartType : String = "Normal"
@export var PlayerColor : Color = Color(.8, .19, 0.01)
@export var PlayerGuy : String = "Man 1"

signal CodeSubmitted
signal StaminaConsumptionFailed

var movement_direction = Vector3.ZERO

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
	movement_direction = Vector3(Input.get_axis(Controls.move_left, Controls.move_right), 0, Input.get_axis(Controls.move_up, Controls.move_down)).normalized()
	var currentVelocity = Vector3(linear_velocity.x, 0, linear_velocity.z)
	
	_handle_sprint_input(delta)
	movement_component.move(movement_direction)
	rotation_component.look_in_movement_direction()
	_handle_slam(delta)
	_handle_parry_input()


func _handle_sprint_input(delta: float) -> void: 
	if (Input.is_action_just_pressed(Controls.sprint)):
		if (StaminaManagerInstance.CurrentStamina > 0):
			StaminaManagerInstance.canRegenStamina = false
			sprint_component.begin_sprint()
			# TODO move scrape sound effect into sprint component
			if (IsGrounded):
				scrape_sound_player.play()
		else:
			_playStaminaConsumptionFailEffects()
		
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
			sprint_component.end_sprint()
			_playStaminaConsumptionFailEffects()
			if (scrape_sound_player.playing):
				scrape_sound_player.stop()
		
	elif (Input.is_action_just_released(Controls.sprint)):
		print("Released Sprint")
		StaminaManagerInstance.canRegenStamina = true
		sprint_component.end_sprint()
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

func _handle_parry_input() -> void:
	if (Input.is_action_just_pressed(Controls.parry)):
		parry_component.try_begin_parry_window()
		
# TODO Extract slam into component
func _handle_slam(delta) -> void:
	if(Input.is_action_just_pressed(Controls.slam) and !IsGrounded):
		slam_component.begin_slam()
			

func _submit_code(codeDirection: String) -> void:
	if (StaminaManagerInstance.CurrentStamina < CodeSubmissionStaminaCost):
		_playStaminaConsumptionFailEffects()
		return
	CodeSubmitted.emit(codeDirection, Controls.PlayerIndex)
	StaminaManagerInstance.drainStamina(CodeSubmissionStaminaCost)

func update_animation_parameters():
	animation_tree["parameters/idle_to_walk/blend_position"] = linear_velocity.length()
	
	
# TODO Extract launchable into a component
func launch(impulseForce: Vector3, callingPlayer: Player, isParryable := true) -> void:
	if (isParryable and parry_component.try_parry(impulseForce, callingPlayer)):
		
		# TODO This should not be handled by the player
		Engine.time_scale = parry_component.ParrySlowTimeAmount
		parry_slow_timer.start(parry_component.ParrySlowTimeLength * parry_component.ParrySlowTimeAmount)
		
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
	if (slam_component.is_slamming):
		slam_component.end_slam()
		return
	
	if (!body.get_groups().has("Bumpable")):
		return
		
	var target_bumpable_component: BumpableComponent = body.find_child("BumpableComponent")
	if (target_bumpable_component == null):
		return
		
	if (target_bumpable_component.try_bump(self)):
		StaminaManagerInstance.restoreStamina(linear_velocity.length() * mass * BumpStaminaGainMultiplier)
	else:
		if (!AudioPlayer.playing):
			AudioPlayer.stream = load(CollisionSoundEffects.pick_random())
			AudioPlayer.play()
		return
	
func _playStaminaConsumptionFailEffects() -> void:
	StaminaConsumptionFailed.emit()
	if (!stamina_buzz_player.playing):
		stamina_buzz_player.play()

# TODO This should be handled outside of the player
func _on_parry_slow_timer_timeout() -> void:
	Engine.time_scale = 1


func _on_parry_component_parry_sound(sound: AudioStream) -> void:
	AudioPlayer.stream = sound
	AudioPlayer.play()


func _on_parry_component_parry_failure() -> void:
	StaminaManagerInstance.drainStamina(StaminaManagerInstance.MaxStamina)
