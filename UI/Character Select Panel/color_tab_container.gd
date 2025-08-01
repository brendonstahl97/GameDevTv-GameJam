class_name ColorTabContainer
extends MultiplayerTabContainer

var selected_color: Color

func _ready() -> void:
	super()
	selected_color = _get_current_tab_color()


func navigate_left() -> void:
	super()
	selected_color = _get_current_tab_color()


func navigate_right() -> void:
	super()
	selected_color = _get_current_tab_color()


func _get_current_tab_color() -> Color:
	var tab = get_current_tab_control().get_child(0) as ColorRect
	return tab.color
