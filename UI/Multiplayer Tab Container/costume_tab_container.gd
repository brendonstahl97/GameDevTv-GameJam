class_name CostumeTabContainer
extends MultiplayerTabContainer

var selected_costume: CharacterCostume:
	get:
		return _get_costume()


func _ready() -> void:
	super()


func navigate_left() -> void:
	super()


func navigate_right() -> void:
	super()


func _get_costume() -> CharacterCostume:
	var tab = get_child(current_tab) as CostumeTab
	return tab.costume_resource
