extends TabContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#if(has_focus()&&(Input.is_action_just_pressed("p1_code_left")||Input.is_action_just_pressed("p1_move_left"))):
	#	if(!select_previous_available()):
	#		current_tab = get_tab_count()-1
	#if(has_focus()&&(Input.is_action_just_pressed("p1_code_right")||Input.is_action_just_pressed("p1_move_right"))):
	#	if(!select_next_available()):
	#		current_tab = 0
