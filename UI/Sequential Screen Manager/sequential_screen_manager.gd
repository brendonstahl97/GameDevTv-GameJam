class_name SequentialScreenManager
extends Control

signal sequence_complete
signal sequence_exited

@export var transition_curve: Curve
@export var transition_duration: float = 0.5

var current_screen: SequentialScreen
var is_transitioning := false
var start_x_position: float = 0
var target_x_position: float = 0
var time: float = 0
var page: int = 0


func _ready() -> void:
	current_screen = get_child(page)

	# Connect screen transitions
	for child in get_children():
		if (child is SequentialScreen):
			child.next_screen.connect(_transition_next)
			child.previous_screen.connect(_transition_previous)


func _process(delta: float) -> void:
	if (current_screen != null):
		current_screen.update(delta)

	if (!is_transitioning):
		return

	time += delta / transition_duration
	position.x = lerp(start_x_position, target_x_position, transition_curve.sample(time))

	if (time >= 1):
		time = 0
		is_transitioning = false


func _transition_next() -> void:
	if (is_transitioning):
		return

	if (page == get_child_count() - 1):
		sequence_complete.emit()
		return

	is_transitioning = true
	start_x_position = target_x_position
	target_x_position -= get_viewport_rect().size.x
	page += 1
	current_screen = get_child(page)


func _transition_previous() -> void:
	if (is_transitioning):
		return

	if (page == 0):
		sequence_exited.emit()
		return

	is_transitioning = true
	start_x_position = target_x_position
	target_x_position += get_viewport_rect().size.x
	page -= 1
	current_screen = get_child(page)
