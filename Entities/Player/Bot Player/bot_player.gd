class_name BotPlayer
extends Player

@onready var player_detector_component: PlayerDetectorComponent = %PlayerDetectorComponent
@onready var bot_parry_component: BotParryComponent = %BotParryComponent

var closest_player: Player

func _process(_delta: float) -> void:
	closest_player = player_detector_component.get_nearest_player()
	_update_animation_parameters()
	_handle_code_input()
	_update_scrape_sound_play_status()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	_update_movement_direction()
	_handle_sprint_input(delta)
	movement_component.move(movement_direction)
	rotation_component.look_in_movement_direction()
	_handle_slam_input()
	_handle_parry_input()


## TODO change this override to use the AI provided direction
func _update_movement_direction() -> void:
	pass
	#movement_direction = Vector3(Input.get_axis(Controls.move_left, Controls.move_right), 0, Input.get_axis(Controls.move_up, Controls.move_down)).normalized()


## TODO change this override to use AI provided sprint control
func _handle_sprint_input(delta: float) -> void: 
	pass
	#if (Input.is_action_just_pressed(Controls.sprint)):
		#_begin_sprint()

	#elif (Input.is_action_pressed(Controls.sprint) && sprint_component.is_sprinting):
		#if (!stamina_manager.try_drain_stamina(sprint_component.sprint_stamina_drain * delta)):
			#_end_sprint()

	#elif (Input.is_action_just_released(Controls.sprint)):
		#_end_sprint()


## TODO change this override to use AI provided code input
func _handle_code_input() -> void:
	var code_direction := Global.CodeDirection.NONE
	
	#if (Input.is_action_just_pressed(Controls.code_up)):
		#code_direction = Global.CodeDirection.UP
	#elif (Input.is_action_just_pressed(Controls.code_left)):
		#code_direction = Global.CodeDirection.LEFT
	#elif (Input.is_action_just_pressed(Controls.code_right)):
		#code_direction = Global.CodeDirection.RIGHT
	#elif (Input.is_action_just_pressed(Controls.code_down)):
		#code_direction = Global.CodeDirection.DOWN
		
	if (code_direction != Global.CodeDirection.NONE):
		if (stamina_manager.try_drain_stamina(code_submission_component.code_submission_stamina_cost)):
			code_submission_component.submit_code(code_direction, Controls.PlayerIndex)


func _handle_parry_input() -> void:
	if (bot_parry_component.check_if_should_parry(closest_player)):
		parry_component.try_begin_parry_window()


## TODO change this override to use AI provided 
func _handle_slam_input() -> void:
	pass
	#if(Input.is_action_just_pressed(Controls.slam) and !ground_detection_component.is_grounded):
		#slam_component.begin_slam()
