extends Node

# References to the nodes in our scene
@onready var _anim_player := $TrackSwitcher
@onready var _track_1 := $Start
@onready var _track_2 := $CharSel

# crossfades to a new audio stream
func crossfade_to(audio_stream: AudioStream) -> void:
	# If both tracks are playing, we're calling the function in the middle of a fade.
	# We return early to avoid jumps in the sound.
	if _track_1.playing and _track_2.playing:
		return

	# The `playing` property of the stream players tells us which track is active. 
	# If it's track two, we fade to track one, and vice-versa.
	if(_track_1 == $Start):
		_track_2.stream = audio_stream
		_track_2.play()
		_anim_player.play("StartToCharSel")
		_track_1 = $CharSel
		_track_2 = $Game
	elif(_track_1 == $CharSel):
		_track_2.stream = audio_stream
		_track_2.play()
		_anim_player.play("CharSelToGame")
		_track_1 = $Game
		_track_2 = $Results
	elif(_track_1 == $Game):
		_track_2.stream = audio_stream
		_track_2.play()
		_anim_player.play("GameToResults")
		_track_1 = $Results
		_track_2 = $Start
		


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
