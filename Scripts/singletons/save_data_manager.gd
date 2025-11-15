extends Node

const save_location = "user://save_game.json"

var current_save_data: Dictionary = {
	"profiles": [
		{
			"id": 1,
			"name": "Test Profile", 
			"coins": 200, 
			"owned_costumes": []
		}
	]
}


func _ready() -> void:
	_save_game()
	# _load_game()
	print(current_save_data)


func update_save_data(new_data: Dictionary) -> void:
	current_save_data = new_data.duplicate()
	_save_game()


func get_save_data() -> Dictionary:
	return current_save_data.duplicate()


func _save_game() -> void:
	var save_file = FileAccess.open(save_location, FileAccess.WRITE)
	save_file.store_var(current_save_data.duplicate())
	save_file.close()
	print("Game saved.")


func _load_game() -> void:
	if (FileAccess.file_exists(save_location)):
		var save_file = FileAccess.open(save_location, FileAccess.READ)
		var data = save_file.get_var()
		save_file.close()

		current_save_data = data.duplicate()
	else:
		print("No save file found, using default data.")
	print("Game loaded.")