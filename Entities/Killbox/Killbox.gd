class_name Killbox
extends Area3D

@export var spawn_points: Node

func _on_body_exited(body: Player) -> void:
	if (!body is Player):
		return

	if (!body.get_groups().has("Players")):
		return

	Respawn(body)
		
		
func Respawn(body: Player) -> void:
	if (spawn_points == null):
		return
	
	var selectedSpawn = spawn_points.get_children().pick_random()
	
	if (selectedSpawn is Node3D):
		body.global_position = selectedSpawn.global_position
		body.linear_velocity = Vector3.ZERO
	else: 
		Respawn(body)
