class_name ParryComponent
extends Node

signal parry_success(global_position:Vector3)
signal parry_failure
signal parry_sound(sound: AudioStream)

@export_category("Parry")
@export var ParryForceMultiplier = 1.0 ## A force multiplier applied to the launch 
@export var ParrySlowTimeAmount =  0.5 ## Intensity of time slowdown 0 = stop time, 1 = full speed
@export var ParrySlowTimeLength = 1.0 ## How long time should be slowed on a successful parry in seconds
@export var ParryWindowLength = 0.1 ## How long the parry window should be in seconds
@export var ParryEffectOffset = Vector3(0, 1, 0) ## Position offset for spawning the parry visual effect
@export var ParryVisualScaleMultiplier = 2.0 ## A uniform scale multiplier for the parry visual effect
@export var ParryVisualSpawnDistance = 0.1 ## How far in the spawn direction the parry visual effect should spawn
@export var ParrySoundEffect: AudioStream ## Parry Success sound effect
@export var ParryFailSoundEffect: AudioStream ## Parry failure sound effect

const PARRY_EFFECT = preload("res://Scenes/parry_effect.tscn")

var parry_timer: Timer

var is_parrying = false
var did_succesfully_parry = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parry_timer = Timer.new()
	parry_timer.one_shot = true
	parry_timer.autostart = false
	add_child(parry_timer)
	parry_timer.timeout.connect(_on_parry_timer_timeout)


func try_begin_parry_window() -> bool:
	if (is_parrying):
		return false
		
	is_parrying = true
	parry_timer.start(ParryWindowLength)
	return true


func try_parry(impulse_force: Vector3, calling_entity: RigidBody3D) -> bool:
	if (!is_parrying):
		return false
	
	calling_entity.launch((-impulse_force + Vector3.DOWN).normalized() * impulse_force.length() * ParryForceMultiplier, get_parent(), false)
		
	_create_parry_effect(-impulse_force.normalized(), calling_entity.global_position, true)
	
	did_succesfully_parry = true
	parry_success.emit(get_parent().global_position)
	
	return true


func _create_parry_effect(spawnDirection: Vector3, lookAtPosition: Vector3, was_successful: bool = false) -> void:
	var parryVisuals = PARRY_EFFECT.instantiate()
		
	parryVisuals.scale = Vector3.ONE * ParryVisualScaleMultiplier
	parryVisuals.position = get_parent().global_position + ParryEffectOffset + spawnDirection * ParryVisualSpawnDistance
	get_window().add_child(parryVisuals)

	parryVisuals.look_at(Vector3(lookAtPosition.x, parryVisuals.global_position.y, lookAtPosition.z))
	
	var sound_effect = ParryFailSoundEffect
	if (was_successful):
		sound_effect = ParrySoundEffect
		
	parry_sound.emit(sound_effect)
		

func _on_parry_timer_timeout() -> void:
	if (!did_succesfully_parry):
		# TODO Fire Signal To drain Stamina
		var spawnDir = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
		var lookAtPosition = get_parent().global_position.direction_to(spawnDir) * 1
		_create_parry_effect(spawnDir, lookAtPosition)
		parry_failure.emit()
		
	is_parrying = false
	did_succesfully_parry = false
