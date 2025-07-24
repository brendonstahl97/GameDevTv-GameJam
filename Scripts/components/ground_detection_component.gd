class_name GroundDetectionComponent
extends RayCast3D

signal grounded_status_changed(status: bool)

var is_grounded: bool = false
	
func _process(_delta: float) -> void:
	
	var colliding = is_colliding()

	if (is_grounded != colliding):
		grounded_status_changed.emit(colliding)
	
	is_grounded = colliding
