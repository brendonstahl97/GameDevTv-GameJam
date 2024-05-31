extends Camera3D

@onready var parry_focus_timer: Timer = $ParryFocusTimer

var PlayersInGame
@export var xPlayerLimits: Vector2 ## how far positive or negative a player can go in the X direction before they are no longer included in the camera position calculations (x = min, y = max)
@export var yPlayerLimits: Vector2 ## how far positive or negative a player can go in the X direction before they are no longer included in the camera position calculations (x = min, y = max)
@export var zPlayerLimits: Vector2 ## how far positive or negative a player can go in the Z direction before they are no longer included in the camera position calculations (x = min, y = max)
@export var lerpSpeed = 1.0
@export var ParryFocusLerpSpeed = 10.0
@export var ParryFocusFov = 30.0

var StartingPosition: Vector3
var StartingFov: float
var IsParryFocused = false
var ParryFocusPosition = Vector3.ZERO

var active = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect to PlayersSpawned event, don't start the camera until the players have been spawned.
	get_node("/root/Game").PlayersSpawned.connect(_setup)
	pass

func _setup() -> void:
	StartingPosition = position
	StartingFov = fov
	PlayersInGame = get_tree().get_nodes_in_group("Players")
	
	for player: Player in PlayersInGame:
		player.SuccessfulParry.connect(_on_successful_parry)
	active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (!active):
		return
	
	var positionTotal = Vector3.ZERO
	var maxPos = Vector3.ZERO
	var minPos = Vector3.ZERO
	var numPlayersInCalc = 0
	
	for player in PlayersInGame:
		if (player == null):
			continue
		
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
	
	var targetFov = StartingFov + positionRangeNoY.length()/2 if (!IsParryFocused) else ParryFocusFov
	var currentLerpSpeed = lerpSpeed if (!IsParryFocused) else ParryFocusLerpSpeed
	
	fov = lerp(fov, targetFov, delta * currentLerpSpeed)
	
	var currentTransform = transform
	look_at(avgPosition if (!IsParryFocused) else ParryFocusPosition)
	var lookAtTransform = transform
	
	transform = currentTransform.interpolate_with(lookAtTransform, delta * currentLerpSpeed)
	
func _on_successful_parry(focusPosition: Vector3) -> void:
	IsParryFocused = true
	ParryFocusPosition = focusPosition
	parry_focus_timer.start()

func _on_parry_focus_timer_timeout() -> void:
	IsParryFocused = false
