class_name CodeSubmissionComponent
extends Node

signal code_submitted(code_direction: Global.CodeDirection, player_index: int)

@export var group_name = "Code_Submitters"
@export var code_submission_stamina_cost = 7.5 ## The stamina cost of each code submission button press

func _ready() -> void:
	add_to_group(group_name)
	
func submit_code(code_direction: Global.CodeDirection, player_index: int) -> void:
	code_submitted.emit(code_direction, player_index)
