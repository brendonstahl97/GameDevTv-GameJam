class_name StaminaManager
extends  Node

@export var max_stamina = 100.0 ## Defaut starting stamina
@export var passive_stamina_regen = 20.0 ## The amount of stamina that is passively regenerated every second

signal stamina_changed(value: float)

var can_regen_stamina = true;
var current_stamina: float:
	set(value):
		current_stamina = clampf(value, 0, max_stamina)
		stamina_changed.emit(current_stamina)

func _ready() -> void:
	current_stamina = max_stamina
	stamina_changed.emit(current_stamina)
	
func _process(delta: float) -> void:
	_handle_stamina_regen(delta)
		
func drainStamina(amountToDrain: float) -> void:
	current_stamina -= amountToDrain

func restoreStamina(amountToRestore: float) -> void:
	current_stamina += amountToRestore

func _handle_stamina_regen(delta) -> void:
	if (current_stamina < max_stamina && can_regen_stamina):
		current_stamina += passive_stamina_regen * delta
