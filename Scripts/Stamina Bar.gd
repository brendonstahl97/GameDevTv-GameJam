extends Control

@export var target: Node3D
@export var offset_3d: Vector3


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var pos_3d := target.global_position + offset_3d
	var cam := get_viewport().get_camera_3d()
	var pos_2d := cam.unproject_position(pos_3d)
	global_position = pos_2d
	visible = not cam.is_position_behind(pos_3d)
	$ProgressBar.value = target.CurrentStamina

