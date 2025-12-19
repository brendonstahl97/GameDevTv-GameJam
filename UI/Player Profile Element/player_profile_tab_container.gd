class_name PlayerProfileTabContainer
extends MultiplayerTabContainer

@export var player_profile_tab_scene: PackedScene

var selected_tab_profile_id: int

@onready var profile_creator: PlayerProfileCreator = %ProfileCreator
@onready var player_default: PlayerProfileTab = %PlayerDefault
@onready var money_display: Label = %MoneyDisplay


func _ready() -> void:
	ProfileManager.profiles_changed.connect(_on_profiles_changed)
	selected_tab_profile_id = get_current_tab_profile_id()
	_on_profiles_changed()


func delete_current_profile() -> void:
	var tab = get_current_tab_control() as PlayerProfileTab
	if tab:
		ProfileManager.delete_profile(tab.profile_id)


func navigate_left() -> void:
	super()
	selected_tab_profile_id = get_current_tab_profile_id()
	_update_money_display()


func navigate_right() -> void:
	super()
	selected_tab_profile_id = get_current_tab_profile_id()
	_update_money_display()


func get_current_tab_profile_id() -> int:
	var tab = get_current_tab_control() as PlayerProfileTab
	return tab.profile_id


func _on_profiles_changed() -> void:
	var profiles = ProfileManager.get_profiles()
	var previous_index = current_tab

	## Clear existing tabs
	for child in get_children():
		if (child != profile_creator && child != player_default):
			remove_child(child)
			child.queue_free()

	# Ensure that the player default profile is the first option
	remove_child(player_default)
	add_child(player_default)

	# Create new tabs
	for profile in profiles:
		var tab_instance = player_profile_tab_scene.instantiate() as PlayerProfileTab
		tab_instance.profile_id = profile["id"]
		tab_instance.text = profile["name"]
		tab_instance.profile = profile
		add_child(tab_instance)

	# Ensure the profile creator is the last option
	remove_child(profile_creator)
	add_child(profile_creator)

	num_tabs = get_children().size()
	if (previous_index <= num_tabs - 1):
		current_tab = previous_index

	_update_money_display()


func _update_money_display() -> void:
	var current_profile_tab = get_child(current_tab) as PlayerProfileTab
	if (!current_profile_tab.should_display_money):
		money_display.hide()
		return

	if (!money_display.visible):
		money_display.show()

	money_display.text = "$" + str(current_profile_tab.profile["coins"])
