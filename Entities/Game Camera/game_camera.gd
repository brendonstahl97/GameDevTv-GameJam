extends Camera3D

@onready var parry_focus_timer: Timer = $ParryFocusTimer
@onready var audio_position_ray_cast: RayCast3D = $AudioPositionRayCast
@onready var audio_listener_3d: AudioListener3D = $AudioListener3D

# TODO: Make these variable so that they can work for any map
## how far positive or negative a player can go in the X direction before 
## they are no longer included in the camera position calculations (x = min, y = max)
@export var x_player_limits: Vector2
## how far positive or negative a player can go in the X direction 
##before they are no longer included in the camera position calculations (x = min, y = max)
@export var y_player_limits: Vector2
## how far positive or negative a player can go in the Z direction 
## before they are no longer included in the camera position calculations (x = min, y = max)
@export var z_player_limits: Vector2
@export var lerp_speed = 1.0 ## how quickly the camera will catch-up the the target focus position
@export_category("Parry Effect")
@export var parry_focus_lerp_speed = 10.0 ## how quickly the camera will zoom in to the parry location
@export var parry_focus_fov = 30.0 ## the FOV angle the camera will zoom in to during a parry effect

var players_in_game
var starting_position: Vector3
var starting_fov: float
var is_parry_focused = false
var parry_focus_position = Vector3.ZERO
var killbox: Killbox

var active = false



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect to PlayersSpawned event, don't start the camera until the players have been spawned.
	var game_node = get_node_or_null("/root/Game")
	if (game_node != null):
		game_node.PlayersSpawned.connect(setup)


func setup() -> void:
	starting_position = position
	starting_fov = fov
	players_in_game = get_tree().get_nodes_in_group("Players")
	SignalBus.successful_parry.connect(_on_successful_parry)
	killbox = get_parent().environment.killbox
	active = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (!active):
		return

	var position_total = Vector3.ZERO
	var max_pos = Vector3.ZERO
	var min_pos = Vector3.ZERO
	var num_players_in_calculation = 0

	var potential_bodies = killbox.get_overlapping_bodies()

	for player in players_in_game:
		if (player == null):
			continue

		var player_position = player.position

		# if (
		# 	player_position.x >= x_player_limits.x
		# 	&& player_position.x <= x_player_limits.y
		# 	&& player_position.z >= z_player_limits.x
		# 	&& player_position.z <= z_player_limits.y
		# 	&& player_position.y >= y_player_limits.x
		# 	&& player_position.y <= y_player_limits.y
		# ):
		if (
			potential_bodies.has(player)
		):
			num_players_in_calculation += 1
			position_total += player_position

			if (player_position.x > max_pos.x):
				max_pos.x = player_position.x

			if (player_position.x < min_pos.x):
				min_pos.x = player_position.x

			if (player_position.z > max_pos.z):
				max_pos.z = player_position.z

			if (player_position.z < min_pos.z):
				min_pos.z = player_position.z

	if (num_players_in_calculation == 0):
		num_players_in_calculation = 1

	var avg_position = position_total / num_players_in_calculation
	var avg_position_no_y = Vector3(avg_position.x, 0, avg_position.z)
	var position_range_no_y = Vector3(max_pos.x, 0, max_pos.y) - Vector3(min_pos.x, 0, min_pos.y)

	var target_position = Vector3(avg_position_no_y.x, starting_position.y + avg_position.y, position.z)
	position = position.lerp(target_position, delta * lerp_speed)

	var target_fov = starting_fov + position_range_no_y.length() / 2 if (!is_parry_focused) else parry_focus_fov
	var current_lerp_speed = lerp_speed if (!is_parry_focused) else parry_focus_lerp_speed

	fov = lerp(fov, target_fov, delta * current_lerp_speed)

	var current_transform = transform
	look_at(avg_position if (!is_parry_focused) else parry_focus_position)
	var look_at_transform = transform

	transform = current_transform.interpolate_with(look_at_transform, delta * current_lerp_speed)


func _on_successful_parry(focus_position: Vector3) -> void:
	is_parry_focused = true
	parry_focus_position = focus_position
	parry_focus_timer.start()


func _on_parry_focus_timer_timeout() -> void:
	is_parry_focused = false


func _position_audio_listener() -> void:
	if (audio_position_ray_cast.is_colliding()):
		var collision_point = audio_position_ray_cast.get_collision_point()
		audio_listener_3d.global_position = collision_point
		return
	
	