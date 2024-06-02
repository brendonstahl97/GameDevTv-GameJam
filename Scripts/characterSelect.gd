extends Node3D
# Info to establish in this scene:
# For each Player:
#	No. of Players
#	Stand Type
#	Character Model
#	Player Color
#	Player Nam  

var charSelectUI = null
var allReadyContainer = null

# Called when the node enters the scene tree for the first time.
func _ready():
	allReadyContainer = $AllReadyContainer
	charSelectUI = $CharSelUI 
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_allReadyDisplay()

	if (Input.is_action_just_pressed("ui_select")):
		print("pushed")
		var minPlayersJoined = false
		for p in charSelectUI.get_children():
			if (p.joined):
				minPlayersJoined = true
		if (!minPlayersJoined):
			return
		
		# If all players who are joined, are ready, switch to the game scene.
		for p in charSelectUI.get_children():
			if (p.joined && !p.readyUp):

				return

		var playerChoicesDictionary = _getPlayerChoices()
		_switchSceneToGame(playerChoicesDictionary)

func _switchSceneToGame(playerChoicesDictionary):
	# Switch and pass the player choices to the game controller
	# This method was not quite as good as I was hoping.
	# var gameScene = preload("res://Scenes/game.tscn").instantiate()
	# get_tree().root.add_child(gameScene)

	# Set GLOBAL player info for their choices, usable anywhere.
	global.playerInfo = playerChoicesDictionary
	BackgroundMusic.crossfade_to(BackgroundMusic.get_child(2).stream)
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	

# Returns a dictionary of each player's choices,
# give it to gameController when the game starts so we know how to spawn each player.
func _getPlayerChoices():
	var playerChoices = {}
	for p in charSelectUI.get_children():
		# If the player hasn't joined, skip them
		if (!p.joined):
			continue

		#var playerNumber: int = int(p.get_name())
		#playerNumber -= 1
		var playerNumber = p.name
		var playerNestedInfo = {}

		var navigableItemsPanel = p.get_node("NavigableItems")

		# Get the Player Color
		var playerColorPanel = navigableItemsPanel.get_node("Color")
		for colorPanel in playerColorPanel.get_children():
			if (colorPanel.visible):
				var colorRect : ColorRect = colorPanel.get_node("ColorRect")
				playerNestedInfo["PlayerColor"] = colorRect.color
				break

		# Cart Type
		var cartTypePanel = navigableItemsPanel.get_node("StandType")
		var choice = "Light"
		if (cartTypePanel.get_node("Heavy").visible):
			choice = "Heavy"
		elif (cartTypePanel.get_node("Medium").visible):
			choice = "Medium"
		playerNestedInfo["PlayerCart"] = choice

		# Character Model
		var characterModelPanel = navigableItemsPanel.get_node("Guy")
		# Loop through and see which one is visible
		for characterModel in characterModelPanel.get_children():
			if (characterModel.visible):
				playerNestedInfo["PlayerGuy"] = str(characterModel.get_name())
				break

		var playerNumberString = str(playerNumber)
		#var playerInfo = {playerNumberString = playerNestedInfo}
		playerChoices[playerNumberString] = playerNestedInfo
	print(playerChoices)
	return playerChoices

# this is more complex than it needs to be
# Checks if all players that are joined are ready by comparing two arrays
func _allReadyDisplay():
	var minPlayersJoined = false
	var joinedPlayers = [0,0,0,0]
	var readyPlayers = [0,0,0,0]
	for p in charSelectUI.get_children():
		if (p.joined):
			minPlayersJoined = true
			joinedPlayers[p.get_index()] = 1
			print("minPlayers Joined")
		else:
			joinedPlayers[p.get_index()] = 0
	
	for p in charSelectUI.get_children():
		if (p.readyUp):
			readyPlayers[p.get_index()] = 1
		else:
			readyPlayers[p.get_index()] = 0
	if(joinedPlayers == readyPlayers and (minPlayersJoined)):
		allReadyContainer.visible = true
	else:
		allReadyContainer.visible = false
