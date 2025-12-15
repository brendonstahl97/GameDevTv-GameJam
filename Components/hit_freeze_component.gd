class_name HitFreezeComponent
extends RigidbodyManipulatorComponent

signal freeze_completed()

@export var freeze_time: float = 0.1 ## The default duration of the hit freeze effect

@export_category("Hit Flash")
@export var hit_flash_enabled := false ## Should the hit flash effect be enabled on freeze?
@export var hit_flash_material: Material ## The material to apply for the hit flash effect
@export var target_meshes: Array[MeshInstance3D] ## The meshes to apply the material to for the hit effect


func _ready() -> void:
	_init_rigidbody()


func hit_freeze(duration: float = freeze_time, should_hit_flash := true):
	target_rigidbody.linear_velocity = Vector3.ZERO
	target_rigidbody.freeze = true;

	if (hit_flash_enabled && should_hit_flash):
		_apply_hit_flash()

	get_tree().create_timer(duration).timeout.connect(_on_freeze_complete)


func _on_freeze_complete() -> void:
	target_rigidbody.freeze = false
	target_rigidbody.linear_velocity = Vector3.ZERO

	if (hit_flash_enabled):
		_remove_hit_flash()

	freeze_completed.emit()


func _apply_hit_flash() -> void:
	for mesh in target_meshes:
		if (mesh != null):
			mesh.material_overlay = hit_flash_material


func _remove_hit_flash() -> void: 
	for mesh in target_meshes:
		if (mesh != null):
			mesh.material_overlay = null