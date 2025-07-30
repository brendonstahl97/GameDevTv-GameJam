class_name FindClosestCustomerState
extends State

@onready var bot_player: BotPlayer = $"../.."
@onready var customer_detector_component: EntityDetectorComponent = %CustomerDetectorComponent
@onready var bot_player_navigation_component: BotPlayerNavigationComponent = %BotPlayerNavigationComponent
@onready var ground_detection_component: GroundDetectionComponent = %GroundDetectionComponent

var closest_customer: Customer

func physics_update(_delta: float) -> void:
	closest_customer = customer_detector_component.get_nearest_entity()
	
	if (closest_customer == null):
		return
	
	# If we are no longer earthbound, transition to the slam state
	if (!ground_detection_component.is_grounded):
		transitioned.emit(self, "SlamState")
		return 
		
	bot_player_navigation_component.set_movement_target(closest_customer.global_position)
	bot_player.movement_direction = bot_player.global_position.direction_to(bot_player_navigation_component.get_next_path_position())
	
	## If we made it into the customer's range, transition to the code submission state
	if (closest_customer.currentPlayer == bot_player):
		transitioned.emit(self, "CodeSubmissionState")
		return
		
	## If there is another player in the customer's range, transition to the bump state
	if (closest_customer.currentPlayer != null):
		transitioned.emit(self, "BumpPlayerState")
		return

func exit() -> void:
	bot_player.movement_direction = Vector3.ZERO
