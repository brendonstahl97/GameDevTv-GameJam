class_name BumpComponent
extends Area3D

signal successful_bump(restored_stamina_amount: float)

@export_category("Bump")
@export var bump_sound_effect: AudioStream
@export var collision_sound_effects: Array[AudioStream] ## Fill with potential sounds for non-bump collisions
@export var bump_stamina_gain_multiplier = 1.0 ## Used to multiplicatively adjust the amount of stamina gained from bumping another player

@export_category("Disable")
@export var base_disable_duration: float = 0.5 ## The base amount of time in seconds to disable the bump for

var collision_audio_player: AudioStreamPlayer3D
var bump_disabled := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_audio_player = AudioStreamPlayer3D.new()
	add_child(collision_audio_player)
	collision_audio_player.global_position = global_position

func _on_body_entered(body: Node3D):
	if (!body.get_groups().has("Bumpable")):
		return
	
	if (bump_disabled):
		return
		
	var target_bumpable_component: BumpableComponent = body.find_child("BumpableComponent")
	if (target_bumpable_component == null):
		return
		
	if (target_bumpable_component.try_bump(get_parent())):
		var restored_stamina_amount = get_parent().linear_velocity.length() * get_parent().mass * bump_stamina_gain_multiplier
		collision_audio_player.stream = bump_sound_effect
		collision_audio_player.play()
		successful_bump.emit(restored_stamina_amount)
	else:
		if (!collision_audio_player.playing):
			collision_audio_player.stream = collision_sound_effects.pick_random()
			collision_audio_player.play()
		return


func start_bump_disabled_timer(duration: float = base_disable_duration) -> void:
	if (bump_disabled):
		return

	bump_disabled = true
	get_tree().create_timer(duration).timeout.connect((
		func(): 
			bump_disabled = false
			))
