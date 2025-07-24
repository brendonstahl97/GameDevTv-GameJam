extends StaticBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var animator: AnimationPlayer = $Casual3_Male/AnimationPlayer

	if (name == "1"):
		animator.play("Victory")
	else:
		animator.play("Death")

	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
