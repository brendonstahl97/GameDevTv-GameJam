class_name LootTable
extends Resource

@export var possible_items: Array[LootTableItem]
var total_weight: int = 0:
	get: 
		if (total_weight == 0 || total_weight == null):
			for item in possible_items:
				total_weight += item.weight
		
		return total_weight

func get_loot():
	var current_max = total_weight
	var value = randi_range(0, current_max)
	
	print("Loot Table Value: ", value, ", Current Max: ", current_max)
	
	for item in possible_items:
		if (value <= item.weight):
			return item.item
		
		current_max -= item.weight
		value -= item.weight

	return null
