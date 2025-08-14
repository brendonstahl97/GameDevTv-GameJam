class_name MapSelection
extends CharSelectScreen

@onready var grid_container: GridContainer = %GridContainer
@onready var start_game_container: Control = %StartGameContainer

@export var input_resources: Array[PlayerControls]
@export var focused_stylebox: StyleBoxFlat
@export var initial_focus: MapElement

var focused_element: MapElement
var is_active := false

var is_map_selected := false


func _ready() -> void:
	_focus_element(initial_focus)


func _process(_delta: float) -> void:
	if (!is_active):
		return
	
	if (is_map_selected):
		for player_input in input_resources:
			if (Input.is_action_just_pressed(player_input.slam)):
				is_map_selected = false
				start_game_container.hide()
			if (Input.is_action_just_pressed(player_input.begin_game)):
				global.selected_map = focused_element.map_resource
				next_screen.emit()
	else:
		for player_input in input_resources:
			if (Input.is_action_just_pressed(player_input.code_left)):
				_focus_element(focused_element.get_node(focused_element.focus_neighbor_left))
			elif (Input.is_action_just_pressed(player_input.code_right)):
				_focus_element(focused_element.get_node(focused_element.focus_neighbor_right))
			elif (Input.is_action_just_pressed(player_input.slam)):
				is_active = false
				previous_screen.emit()
			elif (Input.is_action_just_pressed(player_input.sprint)):
				is_map_selected = true
				start_game_container.show()


func _focus_element(element: MapElement) -> void:
	if (focused_element != null && focused_element.has_theme_stylebox_override("panel")):
		focused_element.remove_theme_stylebox_override("panel")
	
	focused_element = element
	
	focused_element.add_theme_stylebox_override("panel", focused_stylebox)
