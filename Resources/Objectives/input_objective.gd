class_name InputObjective
extends BaseObjective

@export var input_action: StringName ## The specific input action from the player controls resource to watch
@export var input_duration_requirement: float = -1 ## The legth of time the input must be activated (-1 is no duration)

var current_press_duration: float = 0.0

func update(delta: float) -> void:
	if (Input.is_action_pressed(input_action)):
		if (input_duration_requirement == -1):
			complete()
		else:
			current_press_duration += delta
			if (current_press_duration >= input_duration_requirement):
				complete()
	elif (Input.is_action_just_released(input_action)):
		current_press_duration = 0.0

func initialize(_objective_manager: ObjectiveManager) -> void:
	pass

func cleanup() -> void:
	pass
