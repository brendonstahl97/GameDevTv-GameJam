class_name Killbox
extends Area3D

@export var spawn_points: Node

func _on_body_exited(body: Object) -> void:
	if (!body is Player):
		return

	if (!body.get_groups().has("Players")):
		return

	_respawn(body)
		
		
func _respawn(body: Player) -> void:
	if (spawn_points == null):
		return
	
	var selected_spawn_point = spawn_points.get_children().pick_random()
	
	if (selected_spawn_point is Node3D):
		body.global_position = selected_spawn_point.global_position
		body.linear_velocity = Vector3.ZERO
	else: 
		_respawn(body)
