# Class for the customers that will be in the game
# GameController will spawn these customers in a random spot on the map.
# Player will need to approach the customer, once they get close enough, the customer will give them a task.
# The task will be a sequence such as up right right down left left up.
# The player will need to complete the sequence in order to get the reward.
# The reward will be money based on what tier of customer they are.
# The customer will then leave the map and the player will need to find another customer to get more money.

extends Area3D

@export_enum("Serf", "Normie", "Royalty", "King") var customerTier: String = "Serf"

# Nested dictionary of each enum tier, inside each tier is task length, and reward
var customerTierDataList = {
	"Serf": {
		"taskLength": 3,
		"reward": 20
	},
	"Normie": {
		"taskLength": 4,
		"reward": 30
	},
	"Royalty": {
		"taskLength": 5,
		"reward": 50
	},
	"King": {
		"taskLength": 6,
		"reward": 100
	}
}


# STRUCTURE -------------------------------------------------------------------------------------------
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
