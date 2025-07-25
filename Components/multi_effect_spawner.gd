class_name MultiEffectSpawner
extends EffectSpawner

@export var possible_effects_loot_table: LootTable

func create_effect(global_position: Vector3) -> Node3D:
	var effect: PackedScene = possible_effects_loot_table.get_loot()
	assert(effect != null, "Error when selecting a possible effect")
	var effect_instance = effect.instantiate()
	effect_instance.global_position = global_position
	get_window().add_child(effect_instance)
	
	return effect_instance
