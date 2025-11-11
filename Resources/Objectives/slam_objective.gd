class_name SlamObjective
extends CountObjective

@export var target_player_nodepath: NodePath

var target_player_slam_component: SlamComponent

func initialize(objective_manager: ObjectiveManager) -> void:
	target_player_slam_component = objective_manager.get_node(target_player_nodepath).get_node("SlamComponent") as SlamComponent
	target_player_slam_component.successful_slam.connect(_on_successful_slam)


func cleanup() -> void:
	target_player_slam_component.successful_slam.disconnect(_on_successful_slam)


func update(_delta: float) -> void:
	pass


func _on_successful_slam() -> void:
	_increment_successes()
