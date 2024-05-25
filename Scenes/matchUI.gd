extends Control
var p1Score = 0
var p2Score = 0
var p3Score = 0
var p4Score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$P1_Panel/ScoreLabel.text = ("[center]$ " + str(p1Score) + "[/center]")
	$P2_Panel/ScoreLabel.text = ("[center]$ " + str(p2Score) + "[/center]")
	$P3_Panel/ScoreLabel.text = ("[center]$ " + str(p3Score) + "[/center]")
	$P4_Panel/ScoreLabel.text = ("[center]$ " + str(p4Score) + "[/center]")
