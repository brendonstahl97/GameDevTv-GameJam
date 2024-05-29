extends Node3D
# Info to establish in this scene:
# For each Player:
#	No. of Players
#	Stand Type
#	Character Model
#	Player Color
#	Player Name


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_just_pressed("ui_select")):
		var playerChoicesDictionary = _getPlayerChoices()
		#_switchSceneToGame(playerChoicesDictionary)

func _switchSceneToGame(playerChoicesDictionary):
	# Switch and pass the player choices to the game controller

	pass

# Returns a dictionary of each player's choices,
# give it to gameController when the game starts so we know how to spawn each player.
func _getPlayerChoices():
	var playerChoices = {}
	for p in $CharacterSelectUi.get_children():
		#var playerNumber: int = int(p.get_name())
		#playerNumber -= 1
		var playerNumber = p.name
		var playerNestedInfo = {}

		var navigableItemsPanel = p.get_node("NavigableItems")

		# Get the Player Color
		#var playerColorPanel = navigableItemsPanel.get_node("Color")
		playerNestedInfo["PlayerColor"] = "Purple"

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
				playerNestedInfo["PlayerGuy"] = characterModel.get_name()
				break

		var playerNumberString = str(playerNumber)
		#var playerInfo = {playerNumberString = playerNestedInfo}
		playerChoices[playerNumberString] = playerNestedInfo
	print(playerChoices)
	return playerChoices
