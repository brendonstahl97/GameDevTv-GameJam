class_name FindNearestLauncherState
extends State

@onready var bot_player: BotPlayer = $"../.."
@onready var bot_player_navigation_component: BotPlayerNavigationComponent = %BotPlayerNavigationComponent
@onready var launcher_detector_component: EntityDetectorComponent = %LauncherDetectorComponent
@onready var ground_detection_component: GroundDetectionComponent = %GroundDetectionComponent


func physics_update(_delta: float) -> void:
	var closest_launcher = launcher_detector_component.get_nearest_entity()
	
	if (closest_launcher == null):
		return
	
	# If we are no longer earthbound, transition to the aerial customer state
	if (!ground_detection_component.is_grounded):
		transitioned.emit(self, "AerialCustomerNavigationState")
		return 
		
	bot_player_navigation_component.set_movement_target(closest_launcher.global_position)
	bot_player.movement_direction = bot_player.global_position.direction_to(bot_player_navigation_component.get_next_path_position())


func exit() -> void:
	bot_player.movement_direction = Vector3.ZERO
