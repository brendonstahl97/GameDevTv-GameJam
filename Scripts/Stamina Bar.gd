extends Control

@export var target: RigidBody3D
@export var offset_3d: Vector3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	var pos_3d := target.global_position + offset_3d
	var cam := get_viewport().get_camera_3d()
	var pos_2d := cam.unproject_position(pos_3d)
	global_position = pos_2d
	visible = not cam.is_position_behind(pos_3d)

func _on_stamina_manager_stamina_changed(value: float) -> void:
	$ProgressBar.value = value
