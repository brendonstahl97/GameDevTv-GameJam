extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var possible_anmiations: Array[StringName] = []

func _ready() -> void:
	SignalBus.dialog_completed.connect(func(): animation_player.stop())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func begin_animation() -> void: 
	animation_player.animation_finished.connect(func(_anim_name): animation_player.play(possible_anmiations.pick_random(), .1, randf_range(.7, 1.3)))
	animation_player.play(possible_anmiations.pick_random(), .1, randf_range(.7, 1.3))
