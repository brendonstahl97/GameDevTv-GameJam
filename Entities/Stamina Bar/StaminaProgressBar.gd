extends TextureProgressBar

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on__stamina_consumption_failed() -> void:
	if (!animation_player.is_playing()):
		animation_player.play("ConsumptionFailure")
