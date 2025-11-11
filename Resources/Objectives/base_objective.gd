@abstract class_name BaseObjective
extends Resource

signal objective_completed

@export var objective_name: String = 'New Objective'

var is_completed := false

@abstract func initialize(objective_manager: ObjectiveManager) -> void
@abstract func cleanup() -> void
@abstract func update(delta: float) -> void

func complete() -> void:
	if (is_completed):
		print("Objective ", objective_name, " is already completed")
		return
	
	is_completed = true
	print("Objective ", objective_name, " completed")
	objective_completed.emit()
