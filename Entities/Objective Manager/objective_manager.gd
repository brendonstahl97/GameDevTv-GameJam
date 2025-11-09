class_name ObjectiveManager
extends Node

signal objective_changed(current_objective: BaseObjective)
signal all_objectives_completed

@export var objectives: Array[BaseObjective] = []

var current_objective_index: int = 0
var current_objective: BaseObjective = null
var completed_objectives: Array[bool] = []

func _process(delta: float) -> void:
	if (current_objective):
		current_objective.update(delta)

func _ready() -> void:
	completed_objectives.resize(objectives.size())
	for i in range(objectives.size()):
		completed_objectives[i] = false
	
	if (objectives.size() > 0):
		start_objective(0)
	else:
		push_error("No objectives found")


func start_objective(index: int) -> void:
	# cleanup previous objective (if any)
	if (current_objective):
		current_objective.cleanup()
		current_objective.objective_completed.disconnect(_on_objective_completed)
	
	# set the new objective
	current_objective_index = index
	current_objective = objectives[index]
	
	# connect signals
	current_objective.objective_completed.connect(_on_objective_completed)
	
	# initialize new objective
	current_objective.initialize(self)
	
	# signal that the current objective has changed
	objective_changed.emit()


func _on_objective_completed() -> void:
	if (current_objective_index == objectives.size() - 1):
		print("All objectives completed")
		all_objectives_completed.emit()
	else: 
		start_objective(current_objective_index + 1)
