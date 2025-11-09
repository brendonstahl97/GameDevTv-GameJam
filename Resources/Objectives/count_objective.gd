@abstract class_name CountObjective
extends BaseObjective

@export var num_required_events: int = 1 ## The number of times the event must be completed successfully 

var num_successful_events: int = 0

func _increment_successes() -> void: 
	num_successful_events += 1
	if (num_successful_events >= num_required_events):
		complete()
