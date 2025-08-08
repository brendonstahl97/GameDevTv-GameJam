class_name GroundAlignmentComponent
extends RayCast3D

@export var alignment_offset: float = 0.0 ## a vertical offset to be applied to the Y position of alignment

func _ready() -> void:
	enabled = false

func align_to_ground(body: Node3D) -> void:
	enabled = true
	force_raycast_update()
	
	var ground_height = 0
	var ground_point = get_collision_point()
	
	if (ground_point != null):
		ground_height = ground_point.y
	
	body.global_position.y = ground_height + alignment_offset
	
	enabled = false
