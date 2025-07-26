extends GameMode

@onready var leading_player_label: RichTextLabel = %LeadingPlayerLabel

@export var score_target: int = 2000
@export var score_tied_text: String = "[center]Tied[/center]"

var current_score_leader: String

func start_game() -> void:
	global.money_rewarded.connect(_update_score_leader)
	_update_score_leader()

func _update_score_leader() -> void:
	var calculated_leader = _recalculate_leader()
	
	if (calculated_leader != current_score_leader):
		current_score_leader = calculated_leader
		print(current_score_leader)
		leading_player_label.text = current_score_leader

func _recalculate_leader() -> String:
	var score_leader: String
	var highest_score: int = 0
	var is_tied: bool = false
	
	for player in global.playerInfo.keys():
		if (global.playerInfo[player]["Money"] > highest_score):
			score_leader = player
			highest_score = global.playerInfo[player]["Money"]
			is_tied = false
		elif (global.playerInfo[player]["Money"] == highest_score):
			is_tied = true	
			
	if (highest_score >= score_target):
		game_over.emit()
			
	if (is_tied):
		return score_tied_text
		
	return "[center]Player " + score_leader + "[/center]"
