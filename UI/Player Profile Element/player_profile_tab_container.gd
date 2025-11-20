class_name PlayerProfileTabContainer
extends MultiplayerTabContainer

@export var player_profile_tab_scene: PackedScene

var selected_tab_profile_id: int

func _ready() -> void:
	ProfileManager.profiles_changed.connect(_on_profiles_changed)
	selected_tab_profile_id = _get_current_tab_profile_id()
	_on_profiles_changed()


func delete_current_profile() -> void:
	var tab = get_current_tab_control() as PlayerProfileTab
	if tab:
		ProfileManager.delete_profile(tab.profile_id)


func navigate_left() -> void:
	super()
	selected_tab_profile_id = _get_current_tab_profile_id()


func navigate_right() -> void:
	super()
	selected_tab_profile_id = _get_current_tab_profile_id()


func _get_current_tab_profile_id() -> int:
	var tab = get_current_tab_control() as PlayerProfileTab
	return tab.profile_id


func _on_profiles_changed() -> void:
	var profiles = ProfileManager.get_profiles()

	## Clear existing tabs
	for child in get_children():
		remove_child(child)
		child.queue_free()
	
	## Create new tabs
	for profile in profiles:
		var tab_instance = player_profile_tab_scene.instantiate() as PlayerProfileTab
		tab_instance.profile_id = profile["id"]
		tab_instance.text = profile["name"]
		add_child(tab_instance)
	
	num_tabs = get_children().size()