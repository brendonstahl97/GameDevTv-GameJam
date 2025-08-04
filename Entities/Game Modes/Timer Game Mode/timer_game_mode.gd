extends GameMode

@onready var timer: Timer = %Timer
@onready var label: RichTextLabel = %Label

@export var game_time_length: float = 120 ## Length of the game in seconds

func _process(_delta: float) -> void:
	label.text = _format_time(timer.time_left)


func start_game() -> void:
	timer.start(game_time_length)


func _format_time(gameTimeLeft: float) -> String:
	var seconds = max(int(gameTimeLeft)%60, 0)
	var minutes = max((int(gameTimeLeft)/60)%60, 0)
	var formattedString = "%02d:%02d" % [minutes, seconds]
	return ("[center]" + formattedString + "[/center]")


func _assign_player_rankings() -> void:
	var sorted_player_info = global.get_sorted_player_info()
	
	for player_index in range(sorted_player_info.size()):
		var player_info = sorted_player_info[player_index]
		global.playerInfo[player_info[0]]["PlayerRank"] = player_index + 1


func _on_timer_timeout() -> void:
	_assign_player_rankings()
	game_over.emit()
