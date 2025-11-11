class_name ContinuousObjectiveTriggeredEntitySpawner
extends ObjectiveTriggeredEntitySpawner

@export var spawn_interval: float = 5.0

var is_spawning: bool = false
var time_since_last_spawn: float = 0.0


func _ready() -> void:
	super._ready()
	objective_manager.objective_completed.connect(_on_objective_completed)


func _process(delta: float) -> void:
	if is_spawning:
		time_since_last_spawn += delta
		if time_since_last_spawn >= spawn_interval:
			_spawn_entity()
			time_since_last_spawn = 0.0


func _on_objective_changed(objective: BaseObjective) -> void:
	if (objective in Objective_triggers and not is_spawning):
		is_spawning = true
		time_since_last_spawn = 0.0
		_spawn_entity()


func _on_objective_completed(objective: BaseObjective) -> void:
	if (objective in Objective_triggers && is_spawning):
		is_spawning = false