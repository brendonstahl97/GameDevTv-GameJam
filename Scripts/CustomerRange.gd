extends Decal

@export var BreatheSpeedMultiplier = 1.0
@export var BreatheAmount = 1.0

var time = 0.0
var radius: float

func _ready() -> void:
	radius = size.x
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	var newRadius = radius + sin(time * BreatheSpeedMultiplier) * BreatheAmount
	size = Vector3(newRadius, size.y, newRadius)
