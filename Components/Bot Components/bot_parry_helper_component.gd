class_name BotParryHelperComponent
extends Node

@export var parry_distance_threshold: float = 1.6
@export var parry_player_velocity_threshold: float = 5
@export var parry_trigger_direction_threshold: float = 60
@export var parry_cooldown: float = 3

@export_category("Difficulty/Accuracy")
@export_range(0, 100) var parry_failure_chance: float = 25
@export_range(0, 1, 0.05) var parry_timing_variance: float = .5

var can_parry: bool = true

func check_if_should_parry(closest_player: Player) -> bool:
	if (!can_parry):
		return false
	
	if (closest_player == null):
		return false
		
	if (closest_player.linear_velocity.length() < parry_player_velocity_threshold):
		return false
		
	var vector_to_me: Vector3 = get_parent().global_position - closest_player.global_position
	
	var estimated_position_delta_next_frame = closest_player.linear_velocity * .0166
	var estimated_position_next_frame = closest_player.global_position + estimated_position_delta_next_frame
	
	if ((estimated_position_next_frame - get_parent().global_position).length() > parry_distance_threshold + randf_range(-parry_timing_variance, parry_timing_variance)):
		return false
	
	var incoming_player_trueness = closest_player.linear_velocity.normalized().angle_to(vector_to_me)
	if (rad_to_deg(incoming_player_trueness) > parry_trigger_direction_threshold):
		return false
	
	if (randf() <= (parry_failure_chance / 100)):
		print("Parry failure")
		_start_parry_cooldown()
		return false
	
	_start_parry_cooldown()
	return true

func _start_parry_cooldown() -> void:
		can_parry = false
		get_tree().create_timer(parry_cooldown).timeout.connect(func(): can_parry = true)
		
