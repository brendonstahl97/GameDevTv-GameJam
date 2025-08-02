class_name EntityDetectorComponent
extends Node

@export var entity_group_name: String

var entities: Array[Node]:
	get:
		return get_tree().get_nodes_in_group(entity_group_name)


func get_nearest_entity() -> Node3D:
	var min_distance_to_entity: float = -1
	var closest_entity: Node3D 
	
	for entity in entities:
		if (entity is not Node3D):
			continue
		
		if (entity == get_parent()):
			continue
			
		var distance_to_entity = (get_parent().global_position - entity.global_position).length()
		
		if (min_distance_to_entity == -1):
			min_distance_to_entity = distance_to_entity
			closest_entity = entity
		else:
			if (distance_to_entity < min_distance_to_entity):
				min_distance_to_entity = distance_to_entity
				closest_entity = entity
	
	return closest_entity
