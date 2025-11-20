class_name PlayerProfileElement
extends Control

@export var character_spacing: int = 43

@onready var tab_container: PlayerProfileTabContainer = %"PlayerProfileTabContainer"
@onready var create_profile_panel: PanelContainer = %"PanelContainer"
@onready var character_selector: CharacterSelector = %"CharacterSelector"
@onready var profile_name_input: Label = %"ProfileNameInput"

var assigned_control_stack: ControlStack = null
var is_creating_profile: bool = false


func begin_create_profile(control_stack: ControlStack) -> void:
  # Assign the control stack and push this element onto it
  assigned_control_stack = control_stack
  assigned_control_stack.push_control(self)

  # Initialize the profile creation UI
  profile_name_input.text = ""
  is_creating_profile = true
  create_profile_panel.visible = true
  character_selector.visible = true

  # Hide the main tab container while creating a profile
  tab_container.visible = false


func next_tab() -> void:
  tab_container.navigate_right()


func previous_tab() -> void:
  tab_container.navigate_left()


func delete_current_profile() -> void:
  tab_container.delete_current_profile()


func _process(_delta: float) -> void:

  # Only process input if we are in profile creation mode
  if (!is_creating_profile || assigned_control_stack == null || assigned_control_stack.get_current_control() != self):
    return
  
  if (Input.is_action_just_pressed(assigned_control_stack.player_controls.code_down)):
    character_selector.next()
  elif (Input.is_action_just_pressed(assigned_control_stack.player_controls.code_up)):
    character_selector.previous()
  elif (Input.is_action_just_pressed(assigned_control_stack.player_controls.code_right)):
    _confirm_character_selection()
  elif (Input.is_action_just_pressed(assigned_control_stack.player_controls.code_left)):
    _undo_character_selection()
  elif (Input.is_action_just_pressed(assigned_control_stack.player_controls.begin_game) && profile_name_input.text.length() > 0):
    _end_create_profile()


func _confirm_character_selection() -> void:
  if (!character_selector.visible):
    return

  profile_name_input.text += character_selector.get_character()
  character_selector.position += Vector2(character_spacing, 0)
  character_selector.current_tab = 0

  if (profile_name_input.text.length() >= 8):
    character_selector.hide()


func _undo_character_selection() -> void:

  if (profile_name_input.text.length() <= 0):
    _end_create_profile()
    return

  profile_name_input.text = profile_name_input.text.substr(0, profile_name_input.text.length() - 1)
  character_selector.position -= Vector2(character_spacing, 0)

  if (!character_selector.is_visible()):
    character_selector.show()
    


func _end_create_profile() -> void:
  # Reset profile creation UI
  is_creating_profile = false
  create_profile_panel.visible = false
  character_selector.visible = false
  tab_container.visible = true
  character_selector.reset()

  # remove this element from the control stack
  assigned_control_stack.pop_control()
  assigned_control_stack = null

  if (profile_name_input.text.length() > 0):
    profile_name_input.text += character_selector.get_character()
    ProfileManager.create_profile(profile_name_input.text)

  profile_name_input.text = ""