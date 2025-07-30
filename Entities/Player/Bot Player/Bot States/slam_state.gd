class_name SlamState
extends State

@export var slam_trigger_distance_threshold: float = 2.0

@onready var bot_player: BotPlayer = $"../.."
@onready var player_detector_component: EntityDetectorComponent = %PlayerDetectorComponent
@onready var bot_player_navigation_component: BotPlayerNavigationComponent = %BotPlayerNavigationComponent
@onready var ground_detection_component: GroundDetectionComponent = %GroundDetectionComponent
@onready var slam_component: SlamComponent = %SlamComponent

var closest_player: Player

func update(_delta: float) -> void:
	if (ground_detection_component.is_grounded):
		transitioned.emit(self, "FindClosestCustomerState")
		return
	
	closest_player = player_detector_component.get_nearest_entity()
	
	if (closest_player == null):
		bot_player.movement_direction = Vector3.ZERO
		slam_component.begin_slam()
	else:
		bot_player.movement_direction = bot_player.global_position.direction_to(closest_player.global_position)
	
		var distance_to_player_no_y: float = Vector3(closest_player.global_position.x, 0, closest_player.global_position.z).distance_to(Vector3(bot_player.global_position.x, 0, bot_player.global_position.z)) 
		if (distance_to_player_no_y <= slam_trigger_distance_threshold):
			slam_component.begin_slam()


func exit() -> void:
	bot_player.movement_direction = Vector3.ZERO
