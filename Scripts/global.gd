class_name Global
extends Node

# Should these be global?
signal successful_parry(global_position: Vector3)
signal customer_completed(reward: int, player_name: String)


func remap_range(value, InputA, InputB, OutputA, OutputB):
	return(value - InputA) / (InputB - InputA) * (OutputB - OutputA) + OutputA


func _sort_descending(a, b):
	if a[1]["Money"] > b[1]["Money"]:
		return true
	return false

func get_sorted_player_info(sorting_function: Callable = _sort_descending) -> Array:
	var sorted_player_info : Array = []
	for player_key in playerInfo:
		var player_info = playerInfo[player_key]
		sorted_player_info.append([player_key, player_info])
	sorted_player_info.sort_custom(sorting_function)
	
	return sorted_player_info


# GLOBAL playerInfo dictionary of all player's choices!
# Info comes from character select screen.
# ["1"] = {
# ["PlayerColor"] = Color (0, 0.6196, 0.9333, 1),
# ["PlayerCart"] = String ("Heavy"),
# ["PlayerGuy"] = String ("Guy1"), }
var playerInfo = null
var selected_map: Map
var selected_game_mode: GameModeResource

enum CodeDirection {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	NONE
}

enum BotDifficulty {
	EASY,
	MEDIUM,
	HARD
}
