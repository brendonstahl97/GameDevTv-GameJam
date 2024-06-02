extends Node


func sort_descending(a, b):
	if a[0] > b[0]:
		return true
	return false
	
func rematchClicked():
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	BackgroundMusic.crossfade_to(BackgroundMusic.get_child(2).stream)
	
	
func mainMenuClicked():
	global.playerInfo = null
	BackgroundMusic.get_child(3).stop()
	get_tree().change_scene_to_file("res://Scenes/Start.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("Control/HBoxContainer2/Rematch").pressed.connect(rematchClicked)
	get_node("Control/HBoxContainer2/MainMenu").pressed.connect(mainMenuClicked)
	
	if (global.playerInfo == null):
		global.playerInfo = {
			"1" = {
				"PlayerColor" = Color(.5, .5, .5),
				"Money" = 500,
				"PlayerGuy" = "Chef_Male",
				"PlayerCart" = "Medium"
			},
			"2" = {
				"PlayerColor" = Color(.5, .5, .5),
				"Money" = 300,
				"PlayerGuy" = "Casual3_Male",
				"PlayerCart" = "Light"
			},
			"3" = {
				"PlayerColor" = Color(.5, .5, .5),
				"Money" = 800,
				"PlayerGuy" = "Casual3_Male",
				"PlayerCart" = "Heavy"
			},
			"4" = {
				"PlayerColor" = Color(.5, .5, .5),
				"Money" = 5000,
				"PlayerGuy" = "Casual3_Male",
				"PlayerCart" = "Light"
			},
		}

	# Sort players by money
	var sortedPlayerInfo : Array = []
	for playerKey in global.playerInfo:
		var thisPlayersInfo = global.playerInfo[playerKey]
		sortedPlayerInfo.append([thisPlayersInfo["Money"], playerKey])
	sortedPlayerInfo.sort_custom(sort_descending)

	print(sortedPlayerInfo)

	# Get the player info, and replace each player stuffs with the relevant info.
	for n in range(sortedPlayerInfo.size()):
		var placeNumber = n + 1
		var playerKey = sortedPlayerInfo[n][1]
		var playerMoney = sortedPlayerInfo[n][0]

		print(placeNumber, " ", playerKey, " ", playerMoney)

		var thisPlayersInfo = global.playerInfo[playerKey]
		var playerPanel = get_node("/root/EndOfGame/Control/HBoxContainer/" + str(placeNumber))
		var playerObject = get_node("/root/EndOfGame/" + str(placeNumber))

		# Set the UI (color, name and score)
		playerPanel.get_node("PlayerIcon").set_modulate(thisPlayersInfo["PlayerColor"])
		playerPanel.get_node("PlayerName").set_text("Player " + playerKey)
		playerPanel.get_node("ScoreLabel").set_text("[center]$" + str(playerMoney) + "[/center]")

		# Set the guy
		# Spawn a new instance of the character asset, switch the "Body" mesh instance.
		var playerGuy = load("res://Assets/Characters/" + thisPlayersInfo["PlayerGuy"] + ".gltf").instantiate()
		add_child(playerGuy)
		var meshInstance = playerGuy.get_node("CharacterArmature/Skeleton3D/Body")
		var oldMeshInstance = playerObject.get_node("Casual3_Male/CharacterArmature/Skeleton3D/Body")
		print(meshInstance.name)
		meshInstance.reparent(playerObject.get_node("Casual3_Male/CharacterArmature/Skeleton3D"))
		meshInstance.transform = oldMeshInstance.transform
		playerGuy.queue_free()
		oldMeshInstance.queue_free()

		# Set the cart
		playerObject.get_node("Stands/Light").visible = false
		playerObject.get_node("Stands/Medium").visible = false
		playerObject.get_node("Stands/Heavy").visible = false
		playerObject.get_node("Stands/" + thisPlayersInfo["PlayerCart"]).visible = true
		# Delete the other stands
		for stand in playerObject.get_node("Stands").get_children():
			if (stand.name != thisPlayersInfo["PlayerCart"]):
				stand.queue_free()


	# Remove the un-used player stuffs
	var playersMissing = 4 - sortedPlayerInfo.size()
	for n in range(playersMissing):
		var placeNumber = 4 - n
		print(placeNumber, " is missing")
		var playerPanel = get_node("/root/EndOfGame/Control/HBoxContainer/" + str(placeNumber))
		var playerObject = get_node("/root/EndOfGame/" + str(placeNumber))
		playerPanel.visible = false
		playerObject.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
