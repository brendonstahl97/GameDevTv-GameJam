class_name NoYMovementRemoteTransformComponent
extends RemoteTransform3D

@onready var position_ray_cast: RayCast3D = %RayCast3D

@export var height_offset = 0.1 ## An offset to be applied to the y position of the remote transform after being aligned with the ground

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	var ground_point: Vector3 = position_ray_cast.get_collision_point()
	
	if (ground_point != null):
		print("found ground point: ", ground_point)
		global_position.y = ground_point.y + height_offset
