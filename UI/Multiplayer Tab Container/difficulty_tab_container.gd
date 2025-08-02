class_name DifficultyTabContainer
extends MultiplayerTabContainer

var selected_tab_difficulty: global.BotDifficulty

func _ready() -> void:
	super()
	selected_tab_difficulty = _get_current_tab_difficulty()


func navigate_left() -> void:
	super()
	selected_tab_difficulty = _get_current_tab_difficulty()


func navigate_right() -> void:
	super()
	selected_tab_difficulty = _get_current_tab_difficulty()


func _get_current_tab_difficulty() -> global.BotDifficulty:
	var tab = get_current_tab_control() as DifficultyTab
	return tab.difficulty
