class_name VisualEffect
extends Node

@export var animation_name: StringName
@export var animation_player: AnimationPlayer

func play_effect() -> void:
	animation_player.play(animation_name)