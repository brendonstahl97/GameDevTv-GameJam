extends TextureProgressBar

const KEYFRAME_TIME = 0.3

@export var base_flash_animation_name: StringName = "flash" ## The name of the flash animation

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var flash_animation_name: String


func _ready() -> void:
	var anim: Animation = animation_player.get_animation(base_flash_animation_name)
	var library = animation_player.get_animation_library("")

	anim = anim.duplicate()

	var track_id: int = anim.find_track(".:tint_progress", Animation.TrackType.TYPE_VALUE)
	var key_id: int = anim.track_find_key(track_id, KEYFRAME_TIME)
	anim.track_set_key_value(track_id, key_id, tint_progress)

	flash_animation_name = "flash" + get_path().get_concatenated_names().replace(" ", "_").replace("/", "-")
	library.add_animation(flash_animation_name, anim)

func _on__stamina_consumption_failed() -> void:
	if (!animation_player.is_playing()):
		animation_player.play("ConsumptionFailure")


func _on_flash_stamina_bar() -> void:
	if (flash_animation_name != null && !flash_animation_name.is_empty()):
		animation_player.play(flash_animation_name)
