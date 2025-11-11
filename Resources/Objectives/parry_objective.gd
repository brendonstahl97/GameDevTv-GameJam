class_name ParryObjective
extends CountObjective

@export var target_player_nodepath: NodePath

var target_player_parry_component: ParryComponent

func initialize(objective_manager: ObjectiveManager) -> void:
	target_player_parry_component = objective_manager.get_node(target_player_nodepath).get_node("ParryComponent") as ParryComponent
	target_player_parry_component.parry_success.connect(_on_successful_parry)


func cleanup() -> void:
	target_player_parry_component.parry_success.disconnect(_on_successful_parry)


func update(_delta: float) -> void:
	pass


func _on_successful_parry() -> void:
	_increment_successes()
