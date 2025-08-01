class_name DisplayPlayer
extends StaticBody3D

@onready var stands: Node3D = %Stands
@onready var body: MeshInstance3D = %Body

func _update_character_display(player_name: String, player_info: Dictionary) -> void:
	
	if (player_name != self.name):
		return
	
	# show the player display if the player has joined
	if (player_info["is_joined"]):
		show()
	else:
		hide()
	
	# Swap the character model
	var desired_character = load("res://Assets/Characters/" + player_info["PlayerGuy"] + ".gltf").instantiate()
	var new_mesh_instance: MeshInstance3D = desired_character.get_node("CharacterArmature/Skeleton3D/Body")
	body.mesh = new_mesh_instance.mesh
	desired_character.queue_free()
	
	# Set the cart
	for stand: Node3D in stands.get_children():
		if (stand.name != player_info["PlayerCart"]):
			stand.hide()
		else :
			stand.show()
