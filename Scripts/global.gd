class_name Global
extends Node

func get_sorted_player_info(sorting_function: Callable = SortUtilities.sort_descending) -> Array:
	var sorted_player_info: Array = []
	for player_key in playerInfo:
		var player_info = playerInfo[player_key]
		sorted_player_info.append([player_key, player_info])
	sorted_player_info.sort_custom(sorting_function)

	return sorted_player_info

# GLOBAL playerInfo dictionary of all player's choices!
# Info comes from character select screen.
# "PlayerColor"= color,
# "is_joined"= bool,
# "Money"= int,
# "player_costume"= CharacterCostume,
# "PlayerCart"= stand_type,
# "PlayerControls"= player_controls,
# "PlayerProfileId"= profile_id int,
# "is_bot"= bool,
# "bot_difficulty"= global.bot_difficulty

var playerInfo = null
var selected_map: Map
var selected_game_mode: GameModeResource

enum CodeDirection {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	NONE,
}

enum BotDifficulty {
	EASY,
	MEDIUM,
	HARD,
}
