extends Timer

@export var parry_slow_time_length: float = 1.0 ## How long in seconds time should be slowed for the parry effect
@export var parry_slow_time_amount: float =  0.5 ## Intensity of time slowdown 0 = stop time, 1 = full speed 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global.successful_parry.connect(_on_successful_parry)


func _on_successful_parry(global_position: Vector3):
	print("successful parry")
	Engine.time_scale = parry_slow_time_amount
	start(parry_slow_time_length * parry_slow_time_amount)


func _on_timeout() -> void:
	Engine.time_scale = 1
