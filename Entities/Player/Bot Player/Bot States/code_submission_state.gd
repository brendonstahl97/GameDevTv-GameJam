class_name CodeSubmissionState
extends State

@export var stamina_empty_wait_time: float = 1 ## amount of time the bot should wait in seconds after attempting to submit a code without enough stamina

@onready var bot_player: BotPlayer = $"../.."
@onready var code_submission_component: CodeSubmissionComponent = %CodeSubmissionComponent
@onready var bot_code_submission_helper_component: BotCodeSubmissionHelperComponent = %BotCodeSubmissionHelperComponent
@onready var stamina_manager: StaminaManager = %StaminaManager
@onready var ground_detection_component: GroundDetectionComponent = %GroundDetectionComponent

var is_recharging_stamina = false

func update(_delta: float) -> void:
	if (is_recharging_stamina == true):
		return
	
	var code_direction := bot_code_submission_helper_component.select_code_input()	
	
	if (code_direction != Global.CodeDirection.NONE):
		if (stamina_manager.try_drain_stamina(code_submission_component.code_submission_stamina_cost)):
			code_submission_component.submit_code(code_direction, bot_player)
		else:
			is_recharging_stamina = true
			get_tree().create_timer(stamina_empty_wait_time).timeout.connect(func(): is_recharging_stamina = false)
	
	# If we are no longer in the customer's range, transition to the the find closest customer state
	if (!bot_code_submission_helper_component.customer_in_range):
		transitioned.emit(self, "FindClosestCustomerState")
		return

func physics_update(_delta: float) -> void:
	# If we are no longer earthbound, transition to the slam state
	if (!ground_detection_component.is_grounded):
		transitioned.emit(self, "SlamState")
		return
