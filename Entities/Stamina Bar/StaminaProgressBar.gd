extends TextureProgressBar

const KEYFRAME_TIME = 0.3

@export var flash_animation_name: StringName = "flash" ## The name of the flash animation

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	var anim: Animation = animation_player.get_animation(flash_animation_name)
	var track_id: int = anim.find_track(".:tint_progress", Animation.TrackType.TYPE_VALUE)
	var key_id: int = anim.track_find_key(track_id, KEYFRAME_TIME)
	anim.track_set_key_value(track_id, key_id, tint_progress)


func _on__stamina_consumption_failed() -> void:
	if (!animation_player.is_playing()):
		animation_player.play("ConsumptionFailure")


func _on_flash_stamina_bar() -> void:
	animation_player.play(flash_animation_name)
