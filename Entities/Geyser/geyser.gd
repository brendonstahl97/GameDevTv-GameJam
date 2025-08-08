extends Area3D

@onready var audio_stream_player_3d: AudioStreamPlayer3D = %AudioStreamPlayer3D
@onready var charging_particles: GPUParticles3D = %chargingParticles
@onready var eruption_particles: GPUParticles3D = %eruptionParticles

@export var launch_force: float = 10
@export var firing_schedule: float = 1.0
@export var schedule_variance: float = 1.0
@export var charge_time: float = 1.0
@export var launch_time: float = 0.5

var is_launching := false


func _ready() -> void:
	get_tree().create_timer(randf_range(0, firing_schedule)).timeout.connect(begin_idle)


func begin_idle() -> void:
	is_launching = false
	charging_particles.emitting = false
	eruption_particles.emitting = false
	get_tree().create_timer(firing_schedule + randf_range(-schedule_variance, schedule_variance)).timeout.connect(begin_charge)


func begin_charge() -> void:
	charging_particles.emitting = true
	get_tree().create_timer(charge_time).timeout.connect(erupt)


func erupt() -> void:
	is_launching = true
	charging_particles.emitting = false
	eruption_particles.emitting = true
	audio_stream_player_3d.play()
	
	for body in get_overlapping_bodies():
		launch(body)
	
	get_tree().create_timer(launch_time).timeout.connect(begin_idle)


func launch(body: Node3D) -> void:
	if (!body is RigidBody3D):
		return
	
	body.linear_velocity.y = 0
	body.apply_impulse(Vector3.UP * launch_force)


func _on_body_entered(body: Node3D) -> void:
	if (!is_launching):
		return
	
	launch(body)
