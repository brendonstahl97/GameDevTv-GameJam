class_name CustomerTaskDisplay
extends Control

@export var display_y_offset: int = 15 ## the number of pixels the task display should be offset above/below the player
@export var correct_color: Color = Color(0,1,0,1) ## The color each arrow will turn when correctly input

@export_category("Code Directions")

var task_sequence_instructions: Array[Node]

# Called when the node enters the scene tree for the first time.
func _process(delta: float) -> void:
	var screen_pos = get_viewport().get_camera_3d().unproject_position(get_parent().global_transform.origin)

	# Place the element at screen_pos, but have it be offset by the size of the control
	position = screen_pos - size / 2

	# Move it up by the size of the element, plus a little bit
	position.y -= size.y + 15


func initialize_task_sequence(task_sequence: Array[Global.CodeDirection]) -> void:
	# Update the UI with the new task sequence
	var arrowsUI: HBoxContainer = %HBoxContainer
	arrowsUI.get_children()
	for child in arrowsUI.get_children():
		child.free()
	for direction in task_sequence:
		var arrow = get_node("%Panel/" + Global.CodeDirection.keys()[direction] + "Arrow").duplicate() 
		arrow.visible = true
		arrowsUI.add_child(arrow)
		
	task_sequence_instructions.clear()
	task_sequence_instructions = arrowsUI.get_children()


func progress_sequence(sequence_index: int) -> void:
	task_sequence_instructions[sequence_index].set_modulate(correct_color)
