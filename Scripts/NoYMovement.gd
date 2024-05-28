extends RemoteTransform3D

@export var YValue = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	global_position.y = YValue
