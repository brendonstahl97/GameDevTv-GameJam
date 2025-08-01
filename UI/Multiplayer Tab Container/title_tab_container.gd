class_name TitleTabContainer
extends MultiplayerTabContainer

var selected_tab_title: String

func _ready() -> void:
	super()
	selected_tab_title = get_tab_title(current_tab)


func navigate_left() -> void:
	super()
	selected_tab_title = get_tab_title(current_tab)


func navigate_right() -> void:
	super()
	selected_tab_title = get_tab_title(current_tab)
