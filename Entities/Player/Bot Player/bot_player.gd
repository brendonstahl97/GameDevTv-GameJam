class_name BotPlayer
extends Player

@onready var player_detector_component: EntityDetectorComponent = %PlayerDetectorComponent
@onready var bot_parry_helper_component: BotParryHelperComponent = %BotParryHelperComponent
@onready var bot_code_submission_helper_component: BotCodeSubmissionHelperComponent = %BotCodeSubmissionHelperComponent
@onready var bot_player_navigation_component: BotPlayerNavigationComponent = %BotPlayerNavigationComponent

var closest_player: Player


func _process(_delta: float) -> void:
	closest_player = player_detector_component.get_nearest_entity()
	
	_update_animation_parameters()
	_update_scrape_sound_play_status()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	movement_component.move(movement_direction)
	rotation_component.look_in_movement_direction()
	_handle_parry_input()


func _handle_parry_input() -> void:
	if (bot_parry_helper_component.check_if_should_parry(closest_player)):
		parry_component.try_begin_parry_window()


## Calls the Duck-typed `apply_difficulty` method on all applicable children
func apply_difficulty(difficulty: global.BotDifficulty) -> void:
	for child in get_children():
		if (child.has_method("apply_difficulty")):
			child.apply_difficulty(difficulty)
