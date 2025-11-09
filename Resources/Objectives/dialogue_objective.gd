class_name DialogObjective
extends BaseObjective

@export var dialogue_category_name: StringName = "intro"

func update(_delta: float) -> void:
	pass

func initialize(_objective_manager: ObjectiveManager) -> void:
	SignalBus.display_dialog.emit(dialogue_category_name)
	SignalBus.dialog_completed.connect(complete)

func cleanup() -> void:
	SignalBus.dialog_completed.disconnect(complete)
