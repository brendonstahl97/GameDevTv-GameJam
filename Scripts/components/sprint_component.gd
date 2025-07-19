class_name SprintComponent
extends Node

signal sprint_start
signal sprint_end

@export_category("Sprint")
@export var MaxSprintModifier = 2.5 ## Affects your maximum speed ( Max speed = MoveSpeed x This Value )
@export var SprintIncrementAmount = 1 ## Affects how quickly you achieve your max sprint speed once you start sprinting

var sprint_modifier: float = 1.0
var is_sprinting: bool = false

func begin_sprint() -> void:
	sprint_start.emit()
	is_sprinting = true


func end_sprint() -> void:
	sprint_end.emit()
	is_sprinting = false
	sprint_modifier = 1
	

func _ready() -> void:
	assert(get_parent() is MovementComponent, "Sprint Component must the the child of a Movement Component")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		if (!is_sprinting):
			return
		
		if (sprint_modifier < MaxSprintModifier):
			sprint_modifier += SprintIncrementAmount * delta
