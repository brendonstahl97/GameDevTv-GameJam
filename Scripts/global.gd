class_name Global
extends Node

signal successful_parry(global_position: Vector3)
signal customer_completed(reward: int, player_name: String)

# GLOBAL playerInfo dictionary of all player's choices!
# Info comes from character select screen.
# ["1"] = {
# ["PlayerColor"] = Color (0, 0.6196, 0.9333, 1),
# ["PlayerCart"] = String ("Heavy"),
# ["PlayerGuy"] = String ("Guy1"), }
var playerInfo = null

enum CodeDirection {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	NONE
}
