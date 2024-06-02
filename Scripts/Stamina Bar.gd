extends Sprite3D

@export var StaminaProgressBar: TextureProgressBar
@export var LerpSpeed = 25

var LastTargetValue

func _process(delta: float) -> void:
	StaminaProgressBar.value = lerp(StaminaProgressBar.value, LastTargetValue, delta * LerpSpeed)
	if (StaminaProgressBar.value > 99.5):
		StaminaProgressBar.value = 100
	elif (StaminaProgressBar.value < 1.5):
		StaminaProgressBar.value = 1

func _on_stamina_manager_stamina_changed(value: float) -> void:
	LastTargetValue = value
