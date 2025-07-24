extends Node3D

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

@export var LaunchForce = 500.0

func _on_area_3d_body_entered(body: Player) -> void:
	if (!body is Player):
		return
		
	if (!body.get_groups().has("Players")):
		return
	
	body.linear_velocity.y = 0
	body.apply_impulse(Vector3.UP * LaunchForce)
	audio_stream_player_3d.play()
