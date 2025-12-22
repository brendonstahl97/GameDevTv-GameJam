class_name Player
extends LaunchableRigidbody3D

@onready var animation_tree: AnimationTree = $Casual3_Male/AnimationTree
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
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
@onready var hit_freeze_component: HitFreezeComponent = %HitFreezeComponent

@export var controls: PlayerControls
@export var stand_class: Stand

## These are set by the game manager when spawning players
var player_name: String = "Player"
var player_cart_type: String = "Normal"
var player_color: Color = Color(.8, .19, 0.01)
var player_model: String = "Man 1"

var movement_direction = Vector3.ZERO
var player_controls_enabled := true
var has_flashed_since_airborne: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_tree.active = true
	mass = stand_class.Mass
	_connect_dialog_signals()


func _process(_delta: float) -> void:
	_update_animation_parameters()
	_update_scrape_sound_play_status()
	if (player_controls_enabled):
		_handle_code_input()
	else:
		_handle_dialog_input()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	_update_movement_direction()
	_handle_sprint_input(delta)

	if (player_controls_enabled):
		movement_component.move(movement_direction)
		rotation_component.look_in_movement_direction()
		_handle_slam_input()
		_handle_parry_input()


func _update_movement_direction() -> void:
	movement_direction = Vector3(
		Input.get_axis(controls.move_left, controls.move_right),
		0,
		Input.get_axis(controls.move_up, controls.move_down),
	).normalized()


func _handle_sprint_input(delta: float) -> void:
	# If the sprint button was released, stop sprinting
	if (Input.is_action_just_released(controls.sprint)):
		end_sprint()
		return

	# If not moving and currently sprinting, stop sprinting
	if (linear_velocity.length() <= 0.1 && sprint_component.is_sprinting):
		end_sprint()
		return

	# If we make it here and the sprint button is not pressed, do nothing
	if (!Input.is_action_pressed(controls.sprint)):
		return

	# If the sprint button is pressed and we are not currently sprinting, begin sprinting
	if (!sprint_component.is_sprinting && linear_velocity.length() > 0.1):
		begin_sprint()

	# If we are currently sprinting, try to drain stamina
	if (sprint_component.is_sprinting):
		if (!stamina_manager.try_drain_stamina(sprint_component.sprint_stamina_drain * delta)):
			end_sprint()


func begin_sprint() -> void:
	if (stamina_manager.current_stamina > 0):
		stamina_manager.can_regen_stamina = false
		sprint_component.begin_sprint()


func end_sprint() -> void:
	stamina_manager.can_regen_stamina = true
	sprint_component.end_sprint()
	scrape_sound_player.stop()


func _handle_code_input() -> void:
	var code_direction := Global.CodeDirection.NONE

	if (Input.is_action_just_pressed(controls.code_up)):
		code_direction = Global.CodeDirection.UP
	elif (Input.is_action_just_pressed(controls.code_left)):
		code_direction = Global.CodeDirection.LEFT
	elif (Input.is_action_just_pressed(controls.code_right)):
		code_direction = Global.CodeDirection.RIGHT
	elif (Input.is_action_just_pressed(controls.code_down)):
		code_direction = Global.CodeDirection.DOWN

	if (code_direction != Global.CodeDirection.NONE):
		if (stamina_manager.try_drain_stamina(code_submission_component.code_submission_stamina_cost)):
			code_submission_component.submit_code(code_direction, self)


func _handle_parry_input() -> void:
	if (Input.is_action_just_pressed(controls.parry)):
		if (stamina_manager.current_stamina / stamina_manager.max_stamina > parry_component.parry_stamina_threshold):
			parry_component.try_begin_parry_window()
		else:
			stamina_manager.play_stamina_consumption_fail_effects()


func _handle_dialog_input() -> void:
	if (Input.is_action_just_pressed(controls.sprint)):
		# Must emit with an empty string so that dialog progresses if currently displayed
		SignalBus.display_dialog.emit("")


func _handle_slam_input() -> void:
	if (ground_detection_component.is_grounded):
		if (has_flashed_since_airborne):
			has_flashed_since_airborne = false
			
		return
	
	if (ground_detection_component.time_since_last_grounded < slam_component.slam_allowed_delay):
		return

	if (!has_flashed_since_airborne):
		stamina_manager.flash_stamina_bar.emit()
		has_flashed_since_airborne = true

	if (Input.is_action_just_pressed(controls.slam)):
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


func launch(impulse_force: Vector3, callling_entity: RigidBody3D, is_parriable := true) -> void:
	if (freeze):
		return

	if (is_parriable):
		if (!parry_component.try_parry(impulse_force, callling_entity)):
			hit_freeze_component.hit_freeze()
			hit_freeze_component.freeze_completed.connect(
				_on_hit_freeze_complete.bind(impulse_force, callling_entity, is_parriable),
			)

	else:
		hit_freeze_component.hit_freeze()
		hit_freeze_component.freeze_completed.connect(
			_on_hit_freeze_complete.bind(impulse_force, callling_entity, is_parriable),
		)


func _on_hit_freeze_complete(impulse_force, callling_entity, is_parriable):
	if (callling_entity == self):
		hit_freeze_component.freeze_completed.disconnect(
			_on_hit_freeze_complete.bind(impulse_force, callling_entity, is_parriable),
		)
		return

	bump_component.start_bump_disabled_timer()
	apply_impulse(impulse_force)

	if (!is_parriable):
		hit_freeze_component.freeze_completed.disconnect(
			_on_hit_freeze_complete.bind(impulse_force, callling_entity, is_parriable),
		)
		return

	apply_torque_impulse(Vector3.UP * impulse_force.length() * randf_range(-1, 1))

	multi_effect_spawner.create_effect(global_position)

	audio_player.stream = bump_component.bump_sound_effect
	audio_player.play()
	hit_freeze_component.freeze_completed.disconnect(
		_on_hit_freeze_complete.bind(impulse_force, callling_entity, is_parriable),
	)


func _connect_dialog_signals() -> void:
	SignalBus.display_dialog.connect(func(_text_key: String): player_controls_enabled = false)
	SignalBus.dialog_completed.connect(func(): player_controls_enabled = true)


func _on_body_entered(_body: Node3D) -> void:
	if (slam_component.is_slamming):
		slam_component.end_slam()
		linear_velocity = Vector3.ZERO
		return


func _on_parry_component_parry_sound(sound: AudioStream) -> void:
	audio_player.stream = sound
	audio_player.play()


func _on_parry_component_parry_failure() -> void:
	stamina_manager.try_drain_stamina(stamina_manager.max_stamina, false)


func _on_bump_component_successful_bump(restored_stamina_amount: float) -> void:
	hit_freeze_component.hit_freeze(hit_freeze_component.freeze_time + 0.1, false)
	hit_freeze_component.freeze_completed.connect(func(): stamina_manager.restore_stamina(restored_stamina_amount))
