@tool
extends EditorScript


# Called when the node enters the scene tree for the first time.
func _run() -> void:
	var templateLabel = get_scene().get_node("CharSelUI/1/NavigableItems/Guy/Template")
	var newLabel
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Base Character")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "BaseCharacter"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Blue Soldier Female")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "BlueSoldier_Female"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Blue Soldier Male")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "BlueSoldier_Male"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Casual2 Female")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Casual2_Female"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Casual2 Male")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Casual2_Male"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Casual3 Female")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Casual3_Female"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Casual3 Male")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Casual3_Male"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Casual Bald")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Casual_Bald"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Casual Female")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Casual_Female"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Casual Male")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Casual_Male"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Chef Female")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Chef_Female"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Chef Hat")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Chef_Hat"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Chef Male")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Chef_Male"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Cow")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Cow"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Cowboy Female")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Cowboy_Female"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Cowboy Hair")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Cowboy_Hair"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Cowboy Male")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Cowboy_Male"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Doctor Female Old")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Doctor_Female_Old"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Doctor Female Young")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Doctor_Female_Young"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Doctor Male Old")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Doctor_Male_Old"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Doctor Male Young")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Doctor_Male_Young"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Elf")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Elf"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Goblin Female")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Goblin_Female"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Goblin Male")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Goblin_Male"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Kimono Female")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Kimono_Female"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Kimono Male")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Kimono_Male"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Knight Golden Female")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Knight_Golden_Female"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Knight Golden Male")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Knight_Golden_Male"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Knight Male")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Knight_Male"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Ninja Female")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Ninja_Female"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Ninja Male")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Ninja_Male"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Ninja Male Hair")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Ninja_Male_Hair"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Ninja Sand")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Ninja_Sand"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Ninja Sand Female")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Ninja_Sand_Female"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Old Classy Female")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "OldClassy_Female"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Old Classy Male")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "OldClassy_Male"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Pirate Female")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Pirate_Female"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Pirate Male")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Pirate_Male"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Pug")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Pug"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Soldier Female")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Soldier_Female"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Soldier Male")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Soldier_Male"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Suit Female")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Suit_Female"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Suit Male")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Suit_Male"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Viking Helmet")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "VikingHelmet"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Viking Female")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Viking_Female"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Viking Male")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Viking_Male"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Witch")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Witch"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Wizard")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Wizard"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Worker Female")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Worker_Female"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Worker Male")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Worker_Male"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Zombie Female")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Zombie_Female"
	newLabel = templateLabel.duplicate()
	newLabel.set_text("Zombie Male")
	get_scene().get_node("CharSelUI/1/NavigableItems/Guy").add_child(newLabel)
	newLabel.owner = get_scene()
	newLabel.name = "Zombie_Male"
