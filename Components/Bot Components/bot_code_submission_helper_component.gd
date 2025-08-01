class_name BotCodeSubmissionHelperComponent
extends Area3D

@export_category("Difficulty Hard")
@export var code_submission_base_cooldown_hard: float = 0.5 ## base amount of time the bot is required to wait between code submissions on hard difficulty
@export var code_submission_cooldown_variability_hard: float = 0.1 ## how much the cooldown time can vary in both directions on hard difficulty
@export_range(0,100) var incorrect_submission_chance_hard: int = 10 ## percentage chance that the bot will submit an incorrect code on hard difficulty

@export_category("Difficulty Medium")
@export var code_submission_base_cooldown_medium: float = 0.5 ## base amount of time the bot is required to wait between code submissions on medium difficulty
@export var code_submission_cooldown_variability_medium: float = 0.1 ## how much the cooldown time can vary in both directions on medium difficulty
@export_range(0,100) var incorrect_submission_chance_medium: int = 10 ## percentage chance that the bot will submit an incorrect code on medium difficulty

@export_category("Difficulty Easy")
@export var code_submission_base_cooldown_easy: float = 0.5 ## base amount of time the bot is required to wait between code submissions on easy difficulty
@export var code_submission_cooldown_variability_easy: float = 0.1 ## how much the cooldown time can vary in both directions on easy difficulty
@export_range(0,100) var incorrect_submission_chance_easy: int = 10 ## percentage chance that the bot will submit an incorrect code on easy difficulty

var customer_in_range: Customer = null
var can_submit_code := true

var code_submission_base_cooldown: float = code_submission_base_cooldown_medium
var code_submission_cooldown_variability: float = code_submission_cooldown_variability_medium
var incorrect_submission_chance: float = incorrect_submission_chance_medium

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func apply_difficulty(difficulty: global.BotDifficulty) -> void:
	match difficulty:
		global.BotDifficulty.EASY:
			code_submission_base_cooldown = code_submission_base_cooldown_easy
			code_submission_cooldown_variability = code_submission_cooldown_variability_easy
			incorrect_submission_chance = incorrect_submission_chance_easy
		global.BotDifficulty.MEDIUM:
			code_submission_base_cooldown = code_submission_base_cooldown_medium
			code_submission_cooldown_variability = code_submission_cooldown_variability_medium
			incorrect_submission_chance = incorrect_submission_chance_medium
		global.BotDifficulty.HARD:
			code_submission_base_cooldown = code_submission_base_cooldown_hard
			code_submission_cooldown_variability = code_submission_cooldown_variability_hard
			incorrect_submission_chance = incorrect_submission_chance_hard


func select_code_input() -> global.CodeDirection:
	if (!can_submit_code):
		return global.CodeDirection.NONE
	
	if (customer_in_range == null):
		return global.CodeDirection.NONE
	
	var correct_direction = customer_in_range.get_next_correct_input()
	
	if (randf() < (incorrect_submission_chance / 100.0)):
		return _get_random_incorrect_direction(correct_direction)
	
	can_submit_code = false
	get_tree().create_timer(code_submission_base_cooldown + randf_range(-code_submission_cooldown_variability, code_submission_cooldown_variability)).timeout.connect(_allow_submission)
	
	return correct_direction


func _get_random_incorrect_direction(correct_direction: global.CodeDirection) -> global.CodeDirection:
	var possible_directions := [global.CodeDirection.UP, global.CodeDirection.DOWN, global.CodeDirection.LEFT, global.CodeDirection.RIGHT]
	possible_directions.erase(correct_direction)
	var random_direction: global.CodeDirection = possible_directions.pick_random()
		
	return random_direction


func _on_area_entered(area: Area3D) -> void:
	if (area is Customer):
		customer_in_range = area as Customer


func _on_area_exited(area: Area3D) -> void:
	if (area is Customer):
		customer_in_range = null


func _allow_submission() -> void:
	can_submit_code = true	
