extends Panel
var selected
var readyUp = false
var joined = false
var currentIndex = 0
var borderStyleBox
@onready var navigable_items: Control = $NavigableItems
var verticalItems

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if(get_parent().name == "CharSelUI"):
		selected = get_child(2).name # initialize focus on the press a to join box
	else:
		# bypasses joiner box functionality for start screen
		joined = true 
		selected = navigable_items.get_child(0).name

	if(get_parent().name != "TitleScreen"):
		for child:Control in get_children():
			if(child.name != "Joiner"):
				child.visible = false
	get_children()[0].placeholder_text = "Player" + name ## set current player box to current player number
	#make all ui elements invisible except the joiner box 
	
			
	# Create the styleBox
	borderStyleBox = navigable_items.get_child(0).get_theme_stylebox("panel").duplicate()
	borderStyleBox.border_color = Color8(204,204,204,255)
	borderStyleBox.border_width_bottom = 5
	borderStyleBox.border_width_left = 5
	borderStyleBox.border_width_top = 5
	borderStyleBox.border_width_right = 5
	
	# Easy access to the array of children
	verticalItems = navigable_items.get_children()

func _process(_delta: float) -> void:
	if( (Input.is_action_just_pressed("p" + name + "_sprint") || Input.is_action_just_pressed("p" + name + "_slam")) && !joined ):
		# when the a button is pressed make everything visible and make joiner box invisible
		_join_player()

	# Unready
	if (Input.is_action_just_pressed("p" + name + "_slam") && readyUp):
		readyUp = false
		_join_player()
	
	if (joined and !readyUp):
		_handle_navigation()

func _join_player() -> void:
	joined = true
	get_child(0).visible = true
	get_child(1).visible = true
	get_child(2).visible = false
	get_child(3).visible = false
	
	selected = verticalItems[0].name ## switch focus to first user input element 
	currentIndex = 0 ## I don't know how else to keep this number (current index in the getChildren array)
	
	get_node("/root/CharacterSelect/" + name).visible = true
	get_node("/root/CharacterSelect")._replace_players()

func _ready_player() -> void:
	readyUp = true
	joined = true
	get_child(3).visible = true

func _navigate_vertically(steps: int) -> void:
	var boxRange = verticalItems.size()
	currentIndex = (currentIndex + boxRange + steps) % boxRange
	selected = verticalItems[currentIndex].name
	_apply_border_style(verticalItems[currentIndex])

func _handle_navigation() -> void:
	_handle_vertical_navigation()
	_handle_horizontal_navigation()
	
func _handle_vertical_navigation() -> void:
	if(Input.is_action_just_pressed("p" + name + "_code_down") || Input.is_action_just_pressed("p" + name + "_move_down") ):
		_navigate_vertically(1)
	if(Input.is_action_just_pressed("p" + name + "_code_up") || Input.is_action_just_pressed("p" + name + "_move_up") ):
		_navigate_vertically(-1)
	
func _handle_horizontal_navigation() -> void:
	for child:Control in verticalItems:
		if( !(child is Button) && (child.name.match(selected) ) && (Input.is_action_just_pressed("p" + name + "_code_left") || Input.is_action_just_pressed("p" + name + "_move_left") ) ):
			get_node("/root/CharacterSelect")._replace_players()
			if(!child.select_previous_available()):
				child.current_tab = child.get_tab_count()-1
		if( !(child is Button) && (child.name.match(selected) ) && (Input.is_action_just_pressed("p" + name + "_code_right") || Input.is_action_just_pressed("p" + name + "_move_right") ) ):
			get_node("/root/CharacterSelect")._replace_players()
			if( !child.select_next_available() ):
				child.current_tab = 0
		if(child.name.match(selected) && child is Button):
			child.add_theme_stylebox_override("normal", borderStyleBox)
			_handle_buttons(child)
		if(child.name.match(selected)):
			child.add_theme_stylebox_override("panel", borderStyleBox)
		else:
			child.remove_theme_stylebox_override("panel")
			child.remove_theme_stylebox_override("normal")
	
func _handle_buttons(child:Button) -> void:
	if Input.is_action_just_pressed("p" + name + "_sprint"):
		if (child.name == "PlayButton"):
			onPlayPressed()
		if (child.name == "QuitButton"):
			onQuitPressed()
		if (child.name.match("ReadyUp")):
			_ready_player()

func _apply_border_style(selectedItem: Node) -> void:
		if(selectedItem.name.match(selected)):
			selectedItem.add_theme_stylebox_override("tab_focus", borderStyleBox)
		else:
			selectedItem.remove_theme_stylebox_override("tab_focus")

func onPlayPressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/character_select.tscn")
	BackgroundMusic.crossfade_to(BackgroundMusic.get_child(1).stream)
	
func onQuitPressed() -> void:
	get_tree().quit()
