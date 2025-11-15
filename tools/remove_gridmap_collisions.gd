@tool
extends EditorScript


func _run() -> void:
	var scene_root = EditorInterface.get_edited_scene_root()
	for c in scene_root.get_children():
		for child in c.get_children():
			if child is StaticBody3D:
				print("Removing collision from: ", child.name)
				child.queue_free()
