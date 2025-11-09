class_name NavigationObjective
extends BaseObjective

@export var navigator_node_path: NodePath ## Nodepath to the entity that must navigate to the target
@export var target_node_path: NodePath ## Nodepath to the target object
@export var distance_threshold: float ## The minimum distance from the target that will trigger the objective complete

var navigator: Node3D
var target_position: Vector3

func initialize(objective_manager: ObjectiveManager) -> void:
	navigator = objective_manager.get_node(navigator_node_path) as Node3D
	
	var target = objective_manager.get_node(target_node_path) as Node3D
	target_position = target.global_position

func cleanup() -> void:
	pass

func update(_delta: float) -> void:
	if (navigator.global_position.distance_to(target_position) <= distance_threshold):
		complete()
