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
@onready var bump_component: BumpComponent = %BumpComponent

@export var Controls: PlayerControls
@export var stand_class: Stand

@export var stamina_manager_instance: StaminaManager

@export_category("Stamina")
@export var CodeSubmissionStaminaCost = 7.5 ## The stamina cost of each code submission button press

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
	mass = stand_class.Mass

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
		if (stamina_manager_instance.current_stamina > 0):
			stamina_manager_instance.can_regen_stamina = false
			sprint_component.begin_sprint()
			# TODO move scrape sound effect into sprint component
			if (IsGrounded):
				scrape_sound_player.play()
		else:
			_playStaminaConsumptionFailEffects()
		
	elif (Input.is_action_pressed(Controls.sprint)):
		if (stamina_manager_instance.current_stamina > 1):
			stamina_manager_instance.drainStamina(sprint_component.sprint_stamina_drain * delta)
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
		stamina_manager_instance.can_regen_stamina = true
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
	if (stamina_manager_instance.current_stamina < CodeSubmissionStaminaCost):
		_playStaminaConsumptionFailEffects()
		return
	CodeSubmitted.emit(codeDirection, Controls.PlayerIndex)
	stamina_manager_instance.drainStamina(CodeSubmissionStaminaCost)

func update_animation_parameters():
	animation_tree["parameters/idle_to_walk/blend_position"] = linear_velocity.length()
	
	
# Duck Typed function that should be present on all launchable rigidbody nodes
func launch(impulse_force: Vector3, callling_entity: RigidBody3D, is_parriable := true) -> void:
	if (is_parriable):
		if (parry_component.try_parry(impulse_force, callling_entity)):
			# TODO This should not be handled by the player
			Engine.time_scale = parry_component.ParrySlowTimeAmount
			parry_slow_timer.start(parry_component.ParrySlowTimeLength * parry_component.ParrySlowTimeAmount)
		else:
			apply_impulse(impulse_force)
			apply_torque_impulse(Vector3.UP * impulse_force.length() * randf_range(-1, 1))
			
			var foodExplosion = SECRET_CABBAGE_EXPLOSION.instantiate() if (randi_range(0, 10) == 0) else FOOD_EXPLOSION.instantiate()
			foodExplosion.position = callling_entity.global_position
			get_window().add_child(foodExplosion)
			
			AudioPlayer.stream = bump_component.bump_sound_effect
			AudioPlayer.play()
	else:
		apply_impulse(impulse_force)


func _on_body_entered(body: Node3D) -> void:
	if (slam_component.is_slamming):
		slam_component.end_slam()
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
	stamina_manager_instance.drainStamina(stamina_manager_instance.max_stamina)
