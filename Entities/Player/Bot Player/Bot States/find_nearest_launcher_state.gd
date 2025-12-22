class_name FindNearestLauncherState
extends State

@onready var bot_player: BotPlayer = $"../.."
@onready var bot_player_navigation_component: BotPlayerNavigationComponent = %BotPlayerNavigationComponent
@onready var launcher_detector_component: EntityDetectorComponent = %LauncherDetectorComponent
@onready var ground_detection_component: GroundDetectionComponent = %GroundDetectionComponent

## Time in seconds the bot must be airborne before transitioning to aerial customer navigation state
@export var not_grounded_transition_threshold: float = 0.5


func physics_update(_delta: float) -> void:
	var closest_launcher = launcher_detector_component.get_nearest_entity()

	if (closest_launcher == null):
		return

	# If we are no longer earthbound, transition to the aerial customer state
	if (
		!ground_detection_component.is_grounded
		&& ground_detection_component.time_since_last_grounded >= not_grounded_transition_threshold
	):
		transitioned.emit(self, "AerialCustomerNavigationState")
		return

	bot_player_navigation_component.set_movement_target(closest_launcher.global_position)

	if (bot_player_navigation_component.is_target_reachable()):
		bot_player.movement_direction = bot_player.global_position.direction_to(
			bot_player_navigation_component.get_next_path_position(),
		)
		return

	if (closest_launcher.global_position.y < bot_player.global_position.y):
		var raw_direction = bot_player.global_position.direction_to(
			closest_launcher.global_position,
		)
		bot_player.movement_direction = Vector3(raw_direction.x, 0, raw_direction.z).normalized()

	if (closest_launcher.global_position.y > bot_player.global_position.y):
		var target: Node3D = launcher_detector_component.get_nearest_navigable_entity(bot_player_navigation_component)

		bot_player_navigation_component.set_movement_target(target.global_position)

		bot_player.movement_direction = bot_player.global_position.direction_to(
			bot_player_navigation_component.get_next_path_position(),
		)


func exit() -> void:
	bot_player.movement_direction = Vector3.ZERO
