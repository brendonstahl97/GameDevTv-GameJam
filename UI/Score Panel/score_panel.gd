class_name ScorePanel
extends Panel

@onready var player_name_label: RichTextLabel = %PlayerName
@onready var score_label: RichTextLabel = %ScoreLabel
@onready var player_icon: Panel = %PlayerIcon

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
