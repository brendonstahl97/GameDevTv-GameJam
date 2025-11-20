class_name ControlStack
extends Resource

@export var player_controls: PlayerControls

var stack: Array = []

func get_current_control() -> Variant:
	return stack[stack.size() - 1]


func push_control(control: Variant) -> void:
	stack.push_back(control)

func pop_control() -> void:
	if (stack.size() > 0):
		stack.pop_back()