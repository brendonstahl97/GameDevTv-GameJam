class_name MultiEffectSpawner
extends EffectSpawner

@export var possible_effects: Array[PossibleEffect]
var total_weight: int = 0

func  _ready() -> void:
	for effect in possible_effects:
		total_weight += effect.weight

func create_effect(global_position: Vector3) -> Node3D:
	var effect: PackedScene = _select_effect()
	assert(effect != null, "Error when selecting a possible effect")
	var effect_instance = effect.instantiate()
	effect_instance.global_position = global_position
	get_window().add_child(effect_instance)
	
	return effect_instance
	
	
func _select_effect() -> PackedScene:
	var current_max = total_weight
	var value = randi_range(0, current_max)
	
	for effect in possible_effects:
		if (value <= effect.weight):
			return effect.effect
		
		current_max -= effect.weight
		value -= effect.weight

	return null
