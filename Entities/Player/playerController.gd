class_name Player
extends LaunchableRigidbody3D

@onready var animation_tree : AnimationTree = $Casual3_Male/AnimationTree
@onready var AudioPlayer: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var scrape_sound_player: AudioStreamPlayer3D = $ScrapeSoundEffect

@onready var movement_component: MovementComponent = %MovementComponent
@onready var rotation_component: RotationComponent = %RotationComponent
@onready var sprint_component: SprintComponent = %SprintComponent
@onready var parry_component: ParryComponent = %ParryComponent
@onready var slam_component: SlamComponent = %SlamComponent
@onready var bumpable_component: BumpableComponent = %BumpableComponent
@onready var bump_component: BumpComponent = %BumpComponent
@onready var code_submission_component: CodeSubmissionComponent = %CodeSubmissionComponent
@onready var ground_detection_component: GroundDetectionComponent = %GroundDetectionComponent
@onready var stamina_manager: StaminaManager = %StaminaManager
@onready var multi_effect_spawner: MultiEffectSpawner = %MultiEffectSpawner

@export var Controls: PlayerControls
@export var stand_class: Stand

## These are set by the game manager when spawning players
var PlayerName : String = "Player"
var PlayerCartType : String = "Normal"
var PlayerColor : Color = Color(.8, .19, 0.01)
var PlayerGuy : String = "Man 1"

var movement_direction = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_tree.active = true
	mass = stand_class.Mass

func _process(_delta: float) -> void:
	_update_animation_parameters()
	_handle_code_input()
	_update_scrape_sound_play_status()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	_update_movement_direction()
	_handle_sprint_input(delta)
	movement_component.move(movement_direction)
	rotation_component.look_in_movement_direction()
	_handle_slam_input()
	_handle_parry_input()

func _update_movement_direction() -> void:
	movement_direction = Vector3(Input.get_axis(Controls.move_left, Controls.move_right), 0, Input.get_axis(Controls.move_up, Controls.move_down)).normalized()

func _handle_sprint_input(delta: float) -> void: 
	if (Input.is_action_just_pressed(Controls.sprint)):
		_begin_sprint()

	elif (Input.is_action_pressed(Controls.sprint) && sprint_component.is_sprinting):
		if (!stamina_manager.try_drain_stamina(sprint_component.sprint_stamina_drain * delta)):
			_end_sprint()

	elif (Input.is_action_just_released(Controls.sprint)):
		_end_sprint()


func _begin_sprint() -> void:
	if (stamina_manager.current_stamina > 0):
		stamina_manager.can_regen_stamina = false
		sprint_component.begin_sprint()


func _end_sprint() -> void:
	stamina_manager.can_regen_stamina = true
	sprint_component.end_sprint()
	scrape_sound_player.stop()


func _handle_code_input() -> void:
	var code_direction := Global.CodeDirection.NONE
	
	if (Input.is_action_just_pressed(Controls.code_up)):
		code_direction = Global.CodeDirection.UP
	elif (Input.is_action_just_pressed(Controls.code_left)):
		code_direction = Global.CodeDirection.LEFT
	elif (Input.is_action_just_pressed(Controls.code_right)):
		code_direction = Global.CodeDirection.RIGHT
	elif (Input.is_action_just_pressed(Controls.code_down)):
		code_direction = Global.CodeDirection.DOWN
		
	if (code_direction != Global.CodeDirection.NONE):
		if (stamina_manager.try_drain_stamina(code_submission_component.code_submission_stamina_cost)):
			code_submission_component.submit_code(code_direction, Controls.PlayerIndex)


func _handle_parry_input() -> void:
	if (Input.is_action_just_pressed(Controls.parry)):
		parry_component.try_begin_parry_window()


func _handle_slam_input() -> void:
	if(Input.is_action_just_pressed(Controls.slam) and !ground_detection_component.is_grounded):
		slam_component.begin_slam()


func _update_animation_parameters():
	animation_tree["parameters/idle_to_walk/blend_position"] = linear_velocity.length()


func _update_scrape_sound_play_status():
	if (ground_detection_component.is_grounded && sprint_component.is_sprinting):
		if (!scrape_sound_player.playing):
			scrape_sound_player.play()
	else:
		if (scrape_sound_player.playing):
			scrape_sound_player.stop()


# Duck Typed function that should be present on all launchable rigidbody nodes
func launch(impulse_force: Vector3, callling_entity: RigidBody3D, is_parriable := true) -> void:
	if (is_parriable):
		if (!parry_component.try_parry(impulse_force, callling_entity)):
			apply_impulse(impulse_force)
			apply_torque_impulse(Vector3.UP * impulse_force.length() * randf_range(-1, 1))
			
			multi_effect_spawner.create_effect(callling_entity.global_position)
			
			AudioPlayer.stream = bump_component.bump_sound_effect
			AudioPlayer.play()
	else:
		apply_impulse(impulse_force)


func _on_body_entered(_body: Node3D) -> void:
	if (slam_component.is_slamming):
		slam_component.end_slam()
		return


func _on_parry_component_parry_sound(sound: AudioStream) -> void:
	AudioPlayer.stream = sound
	AudioPlayer.play()


func _on_parry_component_parry_failure() -> void:
	stamina_manager.try_drain_stamina(stamina_manager.max_stamina, false)
