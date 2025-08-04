class_name ScorePanelManager
extends Control

func initialize_score_panels() -> void:
	assert(global.playerInfo != null, "Global player info not initialized")

	var player_index = 0
	for player_key in global.playerInfo:
		var score_panel: ScorePanel = get_child(player_index)
		score_panel.initialize_display(player_key, global.playerInfo[player_key]["PlayerColor"])
		score_panel.update_score(global.playerInfo[player_key]["Money"])
		player_index += 1
	
	_hide_unused_panels()


func update_player_score(player_name : String, new_score : int):
	var panel_to_update = get_panel_for_player(player_name)
	
	if (panel_to_update != null):
		panel_to_update.update_score(new_score)


func _hide_unused_panels():
	for panel: ScorePanel in get_children():
		if (panel.player_name == null || panel.player_name.is_empty()):
			panel.hide()


func get_panel_for_player(player_name: String) -> ScorePanel:
	for child: ScorePanel in get_children():
		if (!child is ScorePanel):
			continue
		
		if (child.player_name == null || child.player_name.is_empty()):
			continue
		
		if (child.player_name == player_name):
			return child as ScorePanel
	
	return null
