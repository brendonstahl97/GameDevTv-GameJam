extends Camera3D

var Players
@export var xPlayerLimits: Vector2 ## how far positive or negative a player can go in the X direction before they are no longer included in the camera position calculations (x = min, y = max)
@export var lerpSpeed = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Players = get_tree().get_nodes_in_group("Players")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var xTotal = 0
	for player in Players:
		var playerPosX = player.position.x
		if (playerPosX >= xPlayerLimits.x && playerPosX <= xPlayerLimits.y):
			xTotal += playerPosX
	var avgX = xTotal/Players.size()
	
	position = position.lerp(Vector3(avgX, position.y, position.z), delta * lerpSpeed)
