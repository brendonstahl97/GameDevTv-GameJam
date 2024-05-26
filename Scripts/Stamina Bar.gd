extends Sprite3D

@export var StaminaProgressBar: TextureProgressBar

func _on_stamina_manager_stamina_changed(value: float) -> void:
	StaminaProgressBar.value = value
