extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	pass
	#for child in get_children():
		#print(child)
	
func _input(event):
	print(name)
	for child:Control in get_children():
		if(child.name == "LineEdit"):
			continue
		if(child.has_focus()&&(Input.is_action_just_pressed("p" + name + "_code_left")||Input.is_action_just_pressed("p" + name + "_move_left"))):
			if(!child.select_previous_available()):
				child.current_tab = child.get_tab_count()-1
		if(child.has_focus()&&(Input.is_action_just_pressed("p" + name + "_code_right")||Input.is_action_just_pressed("p" + name + "_move_right"))):
			if(!child.select_next_available()):
				child.current_tab = 0
		if(child.has_focus()):
			var new_stylebox = child.get_theme_stylebox("panel").duplicate()
			new_stylebox.border_color = Color8(204,204,204,255)
			new_stylebox.border_width_top = 5
			new_stylebox.border_width_bottom = 5
			new_stylebox.border_width_left = 5
			new_stylebox.border_width_right = 5
			child.add_theme_stylebox_override("panel", new_stylebox)
		else:
			child.remove_theme_stylebox_override("panel")
