class_name GameModeElement
extends PanelContainer

@onready var label: Label = %Name
@onready var description: Label = %Descrption
@onready var animation_player: AnimationPlayer = %AnimationPlayer

@export var game_mode_resource: GameModeResource

func _ready() -> void:
	label.text = game_mode_resource.game_mode_name
	description.text = game_mode_resource.game_mode_description

func _on_focus_entered() -> void:
	animation_player.play("show description")
	
func _on_focus_exited() -> void:
	animation_player.play_backwards("show description")
