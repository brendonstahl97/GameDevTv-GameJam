class_name StaminaManager
extends  Node

signal stamina_consumption_failed

@onready var stamina_buzz: AudioStreamPlayer3D = $StaminaBuzz

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
	
func try_drain_stamina(amount_to_drain: float, must_have_amount: bool = true) -> bool:
	if (must_have_amount && current_stamina < amount_to_drain):
		_play_stamina_consumption_fail_effects()
		return false
	
	_drain_stamina(amount_to_drain)
	return true

func _drain_stamina(amountToDrain: float) -> void:
	current_stamina -= amountToDrain


func restoreStamina(amountToRestore: float) -> void:
	current_stamina += amountToRestore


func _handle_stamina_regen(delta) -> void:
	if (current_stamina < max_stamina && can_regen_stamina):
		current_stamina += passive_stamina_regen * delta
		

func _play_stamina_consumption_fail_effects() -> void:
	stamina_consumption_failed.emit()
	if (!stamina_buzz.playing):
		stamina_buzz.play()
