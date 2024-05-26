class_name StaminaManager
extends  Node

@export var MaxStamina = 100.0 ## Defaut starting stamina
@export var PassiveStamingaRegen = 20.0 ## The amount of stamina that is passively regenerated every second

signal stamina_changed(value: float)
signal stamina_

var canRegenStamina = true;
var CurrentStamina = 100:
	set(value):
		CurrentStamina = clampf(value, 0, MaxStamina)
		stamina_changed.emit(CurrentStamina)
		
func _process(delta: float) -> void:
	_handle_stamina_regen(delta)
		
func drainStamina(amountToDrain: float) -> void:
	CurrentStamina -= amountToDrain

func restoreStamina(amountToRestore: float) -> void:
	CurrentStamina += amountToRestore

func _handle_stamina_regen(delta) -> void:
	if (CurrentStamina < MaxStamina && canRegenStamina):
		CurrentStamina += PassiveStamingaRegen * delta
