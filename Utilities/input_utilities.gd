class_name InputUtilities
extends Node

static func is_anything_just_pressed(player_controls: PlayerControls) -> bool:
	for property in player_controls.get_property_list():
		var value = player_controls.get(property["name"])

		if (value == null):
			continue

		if (value is not String):
			continue

		if (!InputMap.has_action(value)):
			continue

		if (Input.is_action_just_pressed(value)):
			return true

	return false
