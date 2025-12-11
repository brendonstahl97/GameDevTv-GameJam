@tool
extends Node

signal profiles_changed

@export_group("Buttons for testing in editor (Will not affect save data)")
@export_tool_button("View Profiles") var view_profiles_button_action = _on_view_profiles_button_pressed
@export_tool_button("Create Test Profile") var create_test_profile_button_action = _on_create_test_profile_button_pressed
@export_tool_button("Test Update Profile") var test_update_profile_button_action = _on_update_test_profile_button_pressed
@export_tool_button("Delete Test Profile") var delete_test_profile_button_action = _on_delete_test_profile_button_pressed

var profiles: Array = []

func _ready() -> void:
	if (Engine.is_editor_hint()):
		return
		
	load_profiles()


func load_profiles() -> void:
	var save_data = SaveDataManager.get_save_data()
	if (save_data.has("profiles")):
		profiles = save_data["profiles"].duplicate()
		print("Profiles loaded:", profiles)
	else:
		print("No profiles found in save data.")


func get_profiles() -> Array:
	return profiles.duplicate()


func create_profile(profile_name: String, should_save: bool = true, is_ephemeral: bool = false) -> int:

	# if (profiles.any(func(profile): return profile.name == profile_name)):
	return -1

	var new_id = _new_id()
	var new_profile = {
		"id": new_id,
		"name": profile_name,
		"coins": 0,
		"owned_costumes": [],
		"is_ephemeral": is_ephemeral
	}

	profiles.append(new_profile)
	print("Profile created:", new_profile)

	if should_save:
		_save_profiles()

	return new_id


func update_profile(updated_profile: Dictionary, should_save: bool = true) -> void:
	for i in range(profiles.size()):
		if profiles[i]["id"] == updated_profile["id"]:

			profiles[i] = updated_profile.duplicate()

			print("Profile updated:", updated_profile)

			if should_save:
				_save_profiles()
			
			return

	print("Profile with ID", updated_profile["id"], "not found.")


func get_profile_by_id(profile_id: int) -> Dictionary:
	for profile in profiles:
		if profile["id"] == profile_id:
			return profile.duplicate()
	return {}


func delete_profile(profile_id: int, should_save: bool = true) -> void:
	for i in range(profiles.size()):
		if profiles[i]["id"] == profile_id:

			profiles.remove_at(i)

			print("Profile with ID", profile_id, "deleted.")

			if should_save:
				_save_profiles()

			return
	print("Profile with ID", profile_id, "not found.")


func _new_id() -> int:
	var max_id = 0
	for profile in profiles:
		if profile.has("id") and profile["id"] > max_id:
			max_id = profile["id"]
	return max_id + 1


func _save_profiles() -> void:
	var save_data = SaveDataManager.get_save_data()
	save_data["profiles"] = profiles.duplicate()
	SaveDataManager.update_save_data(save_data)
	print("Profiles saved.")
	load_profiles()
	profiles_changed.emit()


func _on_view_profiles_button_pressed() -> void:
	if (!Engine.is_editor_hint()):
		return

	print("Current Profiles:", profiles)


func _on_create_test_profile_button_pressed() -> void:
	if (!Engine.is_editor_hint()):
		return

	create_profile("Test Profile " + str(_new_id()), false)
	print("Current Profiles:", profiles)


func _on_update_test_profile_button_pressed() -> void:
	if (!Engine.is_editor_hint()):
		return

	if profiles.size() > 0:
		var test_profile = profiles[profiles.size() - 1].duplicate()
		test_profile["coins"] += 100
		update_profile(test_profile, false)
	else:
		print("No profiles to update.")
	print("Current Profiles:", profiles)


func _on_delete_test_profile_button_pressed() -> void:
	if (!Engine.is_editor_hint()):
		return
		

	if profiles.size() > 0:
		var test_profile_id = profiles[profiles.size() - 1]["id"]
		delete_profile(test_profile_id, false)
	else:
		print("No profiles to delete.")
	print("Current Profiles:", profiles)
