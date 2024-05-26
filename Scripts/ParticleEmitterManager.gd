class_name ParticleEmitterManager
extends Node3D

@onready var SprintParticles1: CPUParticles3D = $CPUParticles3D
@onready var SprintParticles2: CPUParticles3D = $CPUParticles3D2

func start_sprint_particles() -> void:
	SprintParticles1.restart()
	SprintParticles1.emitting = true
	SprintParticles2.restart()
	SprintParticles2.emitting = true
	
func end_sprint_particles() -> void:
	SprintParticles1.emitting = false
	SprintParticles2.emitting = false
