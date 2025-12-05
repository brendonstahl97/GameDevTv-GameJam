class_name GameModeSelection
extends SequentialScreen

@onready var grid_container: GridContainer = %GridContainer
@onready var start_game_container: Control = %StartGameContainer

@export var input_resources: Array[PlayerControls]
@export var focused_stylebox: StyleBox
@export var initial_focus: GameModeElement

var focused_element: GameModeElement
#var is_active := false

var is_game_mode_selected := false


func _ready() -> void:
	_focus_element(initial_focus)

#func _process(_delta: float) -> void:
	#update(_delta)


func _focus_element(element: GameModeElement) -> void:
	if (focused_element != null && focused_element.has_theme_stylebox_override("panel")):
		focused_element.remove_theme_stylebox_override("panel")
		focused_element.focus_exited.emit()
	
	focused_element = element
	focused_element.focus_entered.emit()
	focused_element.add_theme_stylebox_override("panel", focused_stylebox)


func update(_delta: float) -> void:
	#if (!is_active):
		#return
	
	if (is_game_mode_selected):
		for player_input in input_resources:
			if (Input.is_action_just_pressed(player_input.slam)):
				is_game_mode_selected = false
				start_game_container.hide()
			if (Input.is_action_just_pressed(player_input.begin_game)):
				global.selected_game_mode = focused_element.game_mode_resource
				next_screen.emit()
	else:
		for player_input in input_resources:
			if (Input.is_action_just_pressed(player_input.code_down)):
				_focus_element(focused_element.get_node(focused_element.focus_neighbor_bottom))
			elif (Input.is_action_just_pressed(player_input.code_up)):
				_focus_element(focused_element.get_node(focused_element.focus_neighbor_top))
			elif (Input.is_action_just_pressed(player_input.slam)):
				#is_active = false
				previous_screen.emit()
			elif (Input.is_action_just_pressed(player_input.sprint)):
				is_game_mode_selected = true
				start_game_container.show()
