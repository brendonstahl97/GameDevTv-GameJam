extends Area3D

@export var RespawnPoints: Array

func _on_body_exited(body: Player) -> void:
	if (!body is Player):
		return

	if (!body.get_groups().has("Players")):
		return

	body.global_position = RespawnPoints.pick_random()
	body.linear_velocity = Vector3.ZERO
