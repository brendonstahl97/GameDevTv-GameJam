extends LaunchableRigidbody3D

@export var projectile_speed: float = 700 ## The movement speed of the skewer
@export var deflect_launch_force: float = 5 ## the force with witch the skewer will be launched if deflected

@onready var rotation_component: RotationComponent = %RotationComponent
@onready var bumpable_detector: EntityDetectorComponent = %EntityDetectorComponent
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var nearest_bumpable_object: Node3D = null
var has_bumped := false
var has_been_parried := false

func _ready() -> void:
	nearest_bumpable_object = bumpable_detector.get_nearest_entity()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if (nearest_bumpable_object == null || has_been_parried || has_bumped):
		return
	
	var direction = global_position.direction_to(nearest_bumpable_object.global_position).normalized()
	linear_velocity = direction * projectile_speed * delta
	rotation_component.look_in_movement_direction(false)

## Override this method to redirect the skewer
func launch(_impulse_force: Vector3, callling_entity: RigidBody3D, _is_parriable := true) -> void:
	if (has_been_parried):
		return
		
	has_been_parried = true
	var deflect_direction = (Vector3.UP - (global_position.direction_to(callling_entity.global_position))).normalized()
	apply_impulse(deflect_direction * deflect_launch_force)
	apply_torque_impulse(Vector3.BACK * deflect_launch_force)
	
	animation_player.play("deflect")

func _on_bump_component_successful_bump(_restored_stamina_amount: float) -> void:
	if (has_bumped):
		return
	
	has_bumped = true
	animation_player.play("bump")
