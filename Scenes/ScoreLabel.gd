extends RichTextLabel
var p1Score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	text = ("$ " + str(p1Score))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = ("[center]$ " + str(p1Score) + "[/center]")
	pass
