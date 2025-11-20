class_name CharacterSelector
extends TabContainer

var starting_position: Vector2


func _ready() -> void:
	starting_position = position


func next() -> void:
	current_tab = (current_tab + 1) % get_tab_count()


func previous() -> void:
	current_tab = (current_tab - 1 + get_tab_count()) % get_tab_count()


func reset() -> void:
	current_tab = 0


func get_character() -> String:
	var current_label = get_current_tab_control() as Label
	return current_label.text
