class_name PlayerDetectorComponent
extends Node

var players: Array[Node]:
	get:
		return get_tree().get_nodes_in_group("Players")


func get_nearest_player() -> Player:
	var min_distance_to_player: float = -1
	var closest_player: Player 
	
	for player in players:
		if (player is not Player):
			continue
		
		if (player == get_parent()):
			continue
			
		var distance_to_player = (get_parent().global_position - player.global_position).length()
		
		if (min_distance_to_player == -1):
			min_distance_to_player = distance_to_player
			closest_player = player
		else:
			if (distance_to_player < min_distance_to_player):
				min_distance_to_player = distance_to_player
				closest_player = player
	
	return closest_player
