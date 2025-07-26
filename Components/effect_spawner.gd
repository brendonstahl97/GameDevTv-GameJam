class_name EffectSpawner
extends Node

@export var effect: PackedScene ## Scene of the effect to spawn

func create_effect(global_position: Vector3) -> Node3D:
	if (get_window() == null):
		return
	
	var effect_instance = effect.instantiate()
	effect_instance.global_position = global_position
	get_window().add_child(effect_instance)
	
	return effect_instance
