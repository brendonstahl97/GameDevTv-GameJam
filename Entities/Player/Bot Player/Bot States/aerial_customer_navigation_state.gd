class_name AerialCustomerNavigationState
extends State

@onready var bot_player: BotPlayer = $"../.."
@onready var ground_detection_component: GroundDetectionComponent = %GroundDetectionComponent
@onready var bot_player_navigation_component: BotPlayerNavigationComponent = %BotPlayerNavigationComponent
@onready var customer_detector_component: EntityDetectorComponent = %CustomerDetectorComponent
@onready var slam_component: SlamComponent = %SlamComponent

## How close to the customer the bot needs to be to initiate a slam
@export var slam_trigger_distance_threshold: float = 1.0

var closest_customer: Customer


func physics_update(_delta: float) -> void:
	if (ground_detection_component.is_grounded):
		transitioned.emit(self, "FindClosestCustomerState")
		return

	closest_customer = customer_detector_component.get_nearest_entity()

	if (closest_customer == null):
		bot_player.movement_direction = Vector3.ZERO
		slam_component.begin_slam()
	else:
		bot_player.movement_direction = bot_player.global_position.direction_to(closest_customer.global_position)

		var distance_to_player_no_y: float = Vector3(
			closest_customer.global_position.x,
			0,
			closest_customer.global_position.z,
		).distance_to(
			Vector3(
				bot_player.global_position.x,
				0,
				bot_player.global_position.z,
			),
		)
		if (distance_to_player_no_y <= slam_trigger_distance_threshold):
			slam_component.begin_slam()


func exit() -> void:
	bot_player.movement_direction = Vector3.ZERO
