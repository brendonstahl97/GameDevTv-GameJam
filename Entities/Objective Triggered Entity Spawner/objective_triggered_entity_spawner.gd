class_name ObjectiveTriggeredEntitySpawner
extends Node3D

@export var objective_manager: ObjectiveManager
@export var entity_scene: PackedScene
@export var Objective_triggers: Array[BaseObjective]

func _ready() -> void:
	objective_manager.objective_changed.connect(_on_objective_changed)


func _on_objective_changed(objective: BaseObjective) -> void:
	if (objective in Objective_triggers):
		_spawn_entity()


func _spawn_entity() -> void:
	if (entity_scene):
		var entity_instance = entity_scene.instantiate() as Node3D
		add_sibling(entity_instance)
		entity_instance.global_position = global_position
		entity_instance.global_rotation = global_rotation
