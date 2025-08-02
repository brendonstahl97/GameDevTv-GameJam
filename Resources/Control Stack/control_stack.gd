class_name ControlStack
extends Resource

@export var player_controls: PlayerControls

var stack: Array = []

func get_current_control() -> Variant:
	return stack[stack.size() - 1]
