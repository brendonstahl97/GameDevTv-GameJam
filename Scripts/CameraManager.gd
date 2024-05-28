extends Camera3D

var PlayersInGame
@export var xPlayerLimits: Vector2 ## how far positive or negative a player can go in the X direction before they are no longer included in the camera position calculations (x = min, y = max)
@export var yPlayerLimits: Vector2 ## how far positive or negative a player can go in the X direction before they are no longer included in the camera position calculations (x = min, y = max)
@export var zPlayerLimits: Vector2 ## how far positive or negative a player can go in the Z direction before they are no longer included in the camera position calculations (x = min, y = max)
@export var lerpSpeed = 1.0

var StartingPosition: Vector3
var StartingFov: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	StartingPosition = position
	StartingFov = fov
	PlayersInGame = get_tree().get_nodes_in_group("Players")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var positionTotal = Vector3.ZERO
	var maxPos = Vector3.ZERO
	var minPos = Vector3.ZERO
	var numPlayersInCalc = 0
	
	for player in PlayersInGame:
		var playerPos = player.position
		
		if (playerPos.x >= xPlayerLimits.x && playerPos.x <= xPlayerLimits.y && playerPos.z >= zPlayerLimits.x && playerPos.z <= zPlayerLimits.y && playerPos.y >= yPlayerLimits.x && playerPos.y <= yPlayerLimits.y):
			numPlayersInCalc += 1
			positionTotal += playerPos
			
			if (playerPos.x > maxPos.x):
				maxPos.x = playerPos.x
				
			if (playerPos.x < minPos.x):
				minPos.x = playerPos.x
				
			if (playerPos.z > maxPos.z):
				maxPos.z = playerPos.z
				
			if (playerPos.z < minPos.z):
				minPos.z = playerPos.z
				
	if (numPlayersInCalc == 0):
		numPlayersInCalc = 1
			
	var avgPosition = positionTotal/numPlayersInCalc
	var avgPositionNoY = Vector3(avgPosition.x, 0, avgPosition.z)
	var positionRangeNoY = Vector3(maxPos.x, 0, maxPos.y) - Vector3(minPos.x, 0, minPos.y)
	
	var targetPos = Vector3(avgPositionNoY.x, position.y, position.z)
	position = position.lerp(targetPos, delta * lerpSpeed)
	
	var targetFov = StartingFov + positionRangeNoY.length()/2
	fov = lerp(fov, targetFov, delta * lerpSpeed)
	
	var currentTransform = transform
	look_at(avgPosition)
	var lookAtTransform = transform
	transform = currentTransform.interpolate_with(lookAtTransform, delta * lerpSpeed)
	
	
