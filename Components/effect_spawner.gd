class_name EffectSpawner
extends Node

@export var effect: PackedScene ## Scene of the effect to spawn

func create_effect(global_position: Vector3) -> Node3D:
	if (get_window() == null):
		return
	
	var effect_instance = effect.instantiate() as VisualEffect
	get_window().add_child(effect_instance)
	effect_instance.global_position = global_position
	effect_instance.play_effect()
	
	return effect_instance
