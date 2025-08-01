@abstract class_name MultiplayerTabContainer
extends TabContainer

var num_tabs: int = 0

func _ready() -> void:
	num_tabs = get_tab_count()


func navigate_left() -> void:
	if (current_tab == 0):
		current_tab = num_tabs - 1
	else:
		current_tab -= 1


func navigate_right() -> void:
	if (current_tab == num_tabs - 1):
		current_tab = 0
	else:
		current_tab += 1
