class_name CustomerCompletionObjective
extends CountObjective


func initialize(_objective_manager: ObjectiveManager) -> void:
	SignalBus.customer_completed.connect(_on_customer_completed)


func cleanup() -> void:
	SignalBus.customer_completed.disconnect(_on_customer_completed)


func update(_delta: float) -> void:
	pass


func _on_customer_completed(_reward: int, _player_name: String):
	_increment_successes()
