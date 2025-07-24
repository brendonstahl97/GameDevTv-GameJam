class_name ParryComponent
extends Node

signal parry_failure
signal parry_sound(sound: AudioStream)

@export_category("Parry")
@export var parry_force_multiplier = 1.0 ## A force multiplier applied to the launch 
@export var parry_window_length = 0.1 ## How long the parry window should be in seconds

@export_category("Visual Effect")
@export var parry_effect_offset = Vector3(0, 1, 0) ## Position offset for spawning the parry visual effect
@export var parry_visual_scale_multiplier = 2.0 ## A uniform scale multiplier for the parry visual effect
@export var parry_visual_spawn_distance = 0.1 ## How far in the spawn direction the parry visual effect should spawn
@export var parry_visual_effect: PackedScene

@export_category("Sound Effects")
@export var parry_sound_effect: AudioStream ## Parry Success sound effect
@export var parry_fail_sound_effect: AudioStream ## Parry failure sound effect

var parry_timer: Timer
var effect_spawner: EffectSpawner

var is_parrying = false
var did_succesfully_parry = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	effect_spawner = EffectSpawner.new()
	effect_spawner.effect = parry_visual_effect
	add_child(effect_spawner)
	
	parry_timer = Timer.new()
	parry_timer.one_shot = true
	parry_timer.autostart = false
	add_child(parry_timer)
	parry_timer.timeout.connect(_on_parry_timer_timeout)


func try_begin_parry_window() -> bool:
	if (is_parrying):
		return false
		
	is_parrying = true
	parry_timer.start(parry_window_length)
	return true


func try_parry(impulse_force: Vector3, calling_entity: RigidBody3D) -> bool:
	if (!is_parrying):
		return false
	
	calling_entity.launch((-impulse_force + Vector3.DOWN).normalized() * impulse_force.length() * parry_force_multiplier, get_parent(), false)
		
	_create_parry_effect(-impulse_force.normalized(), calling_entity.global_position, true)
	
	did_succesfully_parry = true
	global.successful_parry.emit(get_parent().global_position)
	
	return true


func _create_parry_effect(spawnDirection: Vector3, lookAtPosition: Vector3, was_successful: bool = false) -> void:
	var parryVisuals = effect_spawner.create_effect(get_parent().global_position + parry_effect_offset + spawnDirection * parry_visual_spawn_distance)

	parryVisuals.look_at(Vector3(lookAtPosition.x, parryVisuals.global_position.y, lookAtPosition.z))
	parryVisuals.scale = Vector3.ONE * parry_visual_scale_multiplier
	
	var sound_effect = parry_fail_sound_effect
	if (was_successful):
		sound_effect = parry_sound_effect
		
	parry_sound.emit(sound_effect)
		

func _on_parry_timer_timeout() -> void:
	if (!did_succesfully_parry):
		var spawnDir = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
		var lookAtPosition = get_parent().global_position.direction_to(spawnDir) * 1
		_create_parry_effect(spawnDir, lookAtPosition)
		parry_failure.emit()
		
	is_parrying = false
	did_succesfully_parry = false
