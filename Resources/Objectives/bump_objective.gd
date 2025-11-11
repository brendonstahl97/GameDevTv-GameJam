class_name BumpObjective
extends CountObjective

@export var target_player_nodepath: NodePath ## The player in the scene that should be watched for a successful bump

var target_player_bump_component: BumpComponent

func initialize(objective_manager: ObjectiveManager) -> void:
	target_player_bump_component = objective_manager.get_node(target_player_nodepath).get_node("BumpComponent") as BumpComponent
	target_player_bump_component.successful_bump.connect(_on_successful_bump)


func cleanup() -> void:
	target_player_bump_component.successful_bump.disconnect(_on_successful_bump)


func update(_delta: float) -> void:
	pass


func _on_successful_bump(_restored_stamina_amount: float): 
	_increment_successes()
