class_name ScorePanel
extends Control

@export var reward_animation_name: StringName = "display_reward"

@onready var player_name_label: RichTextLabel = %PlayerName
@onready var score_label: RichTextLabel = %ScoreLabel
@onready var player_icon: Panel = %PlayerIcon
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var reward_label: Label = $rewardLabel

var player_name: String
var player_color: Color
var current_score: int


func update_score(new_score: int) -> void:
	current_score = new_score
	score_label.text = "$" + str(current_score)


func initialize_display(display_name: String, color: Color) -> void:
	player_name = display_name
	player_name_label.text = player_name
	
	player_color = color
	player_icon.modulate = player_color


func display_reward(value: int) -> void:
	reward_label.text = "+$" + str(value)
	animation_player.play(reward_animation_name)
