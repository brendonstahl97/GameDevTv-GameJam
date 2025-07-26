class_name GameLevel
extends Node

@onready var spawn_points: Node = %SpawnPoints
@export var top_left_customer_spawn_limit: Node3D
@export var bottom_right_customer_spawn_limit: Node3D

func get_customer_spawn_point() -> Vector3:
	return Vector3(
		randf_range(top_left_customer_spawn_limit.global_position.x, bottom_right_customer_spawn_limit.global_position.x),
		randf_range(top_left_customer_spawn_limit.global_position.y, bottom_right_customer_spawn_limit.global_position.y),
		randf_range(top_left_customer_spawn_limit.global_position.z, bottom_right_customer_spawn_limit.global_position.z)
	)
