extends Panel
var selected
var joined = false
var currentIndex = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	selected = get_children()[4].name ## initialize focus on the press a to join box
	get_children()[0].placeholder_text = "Player" + name ## set current player box to current player number
	#make all ui elements invisible except the joiner box 
	for child:Control in get_children():
		if(child.name != "Joiner"):
			child.visible = false


func _process(delta):
	pass

func _input(event):
	print(currentIndex)	
	# when the a button is pressed make everything visible and make joiner box invisible
	if( Input.is_action_just_pressed("p" + name + "_sprint") && !joined ):
		joined = true
		get_children()[4].visible = false
		get_children()[0].visible = true
		get_children()[1].visible = true
		get_children()[2].visible = true
		get_children()[3].visible = true
		selected = get_children()[1].name ## switch focus to first user input element 
		currentIndex = 1 ## I don't know how else to keep this number (current index in the getChildren array)
	
	# creates up and down ui movement and bind to first and last array indexes
	var boxRange = get_child_count() - 2
	if( joined && Input.is_action_just_pressed("p" + name + "_code_down")):
		currentIndex = (currentIndex + boxRange) % boxRange
		currentIndex+=1
		selected = get_children()[currentIndex].name
	if( joined && Input.is_action_just_pressed("p" + name + "_code_up")):
		currentIndex = (currentIndex + boxRange + 1) % boxRange
		currentIndex+=1
		selected = get_children()[currentIndex].name
		

	
	for child:Control in get_children():
		if( child.name.match("LineEdit") ):
			continue
		if( (child.name.match(selected) ) && (Input.is_action_just_pressed("p" + name + "_code_left") || Input.is_action_just_pressed("p" + name + "_move_left") ) ):
			if(!child.select_previous_available()):
				child.current_tab = child.get_tab_count()-1
		if( (child.name.match(selected) ) && (Input.is_action_just_pressed("p" + name + "_code_right") || Input.is_action_just_pressed("p" + name + "_move_right") ) ):
			if( !child.select_next_available() ):
				child.current_tab = 0
		if(child.name.match(selected)):
			var new_stylebox = child.get_theme_stylebox("panel").duplicate()
			new_stylebox.border_color = Color8(204,204,204,255)
			new_stylebox.border_width_top = 5
			new_stylebox.border_width_bottom = 5
			new_stylebox.border_width_left = 5
			new_stylebox.border_width_right = 5
			child.add_theme_stylebox_override("panel", new_stylebox)
		else:
			child.remove_theme_stylebox_override("panel")
