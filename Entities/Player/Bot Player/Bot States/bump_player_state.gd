class_name BumpPlayerState
extends State

@onready var bot_player: BotPlayer = $"../.."

@onready var customer_detector_component: EntityDetectorComponent = %CustomerDetectorComponent
@onready var bot_player_navigation_component: BotPlayerNavigationComponent = %BotPlayerNavigationComponent
@onready var sprint_component: SprintComponent = %SprintComponent
@onready var stamina_manager: StaminaManager = %StaminaManager
@onready var ground_detection_component: GroundDetectionComponent = %GroundDetectionComponent
@onready var bump_component: BumpComponent = %BumpComponent

var target_player: Player
var target_customer: Customer

func enter() -> void:
	target_player = null
	
	target_customer = customer_detector_component.get_nearest_entity()
	target_player = target_customer.currentPlayer
	
	# if there is not a customer, or there is not a player on the closest customer, transition to the find closest customer state
	if (target_customer == null || target_player == null):
		transitioned.emit(self, "FindClosestCustomerState")
		return

func update(delta: float) -> void:
	
	# If we made it into the customer's range,
	# (In case we overshoot it during the bump attempt)
	# or if the target player left the customer's range,
	# or if the customer was completed,
	# transition to the find closest customer state
	if (target_customer == null || target_customer.currentPlayer == bot_player || target_customer.currentPlayer == null):
		transitioned.emit(self, "FindClosestCustomerState")
		return
	
	# if we are no longer earthbound, transition to the slam state
	if (!ground_detection_component.is_grounded):
		transitioned.emit(self, "SlamState")
		return
	
	if (sprint_component.is_sprinting):
		if (!stamina_manager.try_drain_stamina(sprint_component.sprint_stamina_drain * delta)):
			bot_player._end_sprint()
	else:
		bot_player._begin_sprint()

func physics_update(_delta: float) -> void:
	bot_player_navigation_component.set_movement_target(target_player.global_position)
	bot_player.movement_direction = bot_player.global_position.direction_to(bot_player_navigation_component.get_next_path_position())


func exit() -> void:
	bot_player._end_sprint()
	bot_player.movement_direction = Vector3.ZERO
