class_name GroundDetectionComponent
extends RayCast3D

signal grounded_status_changed(status: bool)

var is_grounded: bool = false
var time_since_last_grounded: float = 0.0

	
func _physics_process(delta: float) -> void:
	
	var colliding = is_colliding()

	if (is_grounded != colliding):
		grounded_status_changed.emit(colliding)
	
	if (!colliding):
		time_since_last_grounded += delta
	else:
		time_since_last_grounded = 0.0
	
	is_grounded = colliding
