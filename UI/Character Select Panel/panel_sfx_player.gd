extends AudioStreamPlayer3D

@export var successful_purchase_sfx: AudioStream
@export var error_sfx: AudioStream

func _play_error_sfx() -> void:
	stream = error_sfx
	play()


func _play_purchase_sfx() -> void:
	stream = successful_purchase_sfx
	play()
