extends Control
var p1Score = 0
var p2Score = 0
var p3Score = 0
var p4Score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("/root/Game").connect("PlayersSpawned", updatePlayerIcons)


func updatePlayerIcons():
	if (!global.playerInfo):
		return

	for playerKey in global.playerInfo:
		var playerPanel = get_node("P" + playerKey + "_Panel")
		playerPanel.get_node("PlayerIcon").set_modulate(global.playerInfo[playerKey].PlayerColor)


func updatePlayerMoney(player : String, newAmount : int):
	if player == "0":
		p1Score = newAmount
	elif player == "1":
		p2Score = newAmount
	elif player == "2":
		p3Score = newAmount
	elif player == "3":
		p4Score = newAmount


func hidePlayerPanel(player: String):
	if player == "0":
		$P1_Panel.hide()
	elif player == "1":
		$P2_Panel.hide()
	elif player == "2":
		$P3_Panel.hide()
	elif player == "3":
		$P4_Panel.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$P1_Panel/ScoreLabel.text = ("[center]$ " + str(p1Score) + "[/center]")
	$P2_Panel/ScoreLabel.text = ("[center]$ " + str(p2Score) + "[/center]")
	$P3_Panel/ScoreLabel.text = ("[center]$ " + str(p3Score) + "[/center]")
	$P4_Panel/ScoreLabel.text = ("[center]$ " + str(p4Score) + "[/center]")
