class_name CharacterPreview
extends Control

@onready var display_player: DisplayPlayer = %DisplayPlayer
@onready var camera: Camera3D = %Camera3D


func initialize(height_offset: float = 10) -> void:
	display_player.global_position += Vector3.UP * height_offset
	camera.global_position += Vector3.UP * height_offset


func _on_character_updated(_character_name: String, player_info: Dictionary) -> void:
	display_player.update_character_display_direct(player_info)
