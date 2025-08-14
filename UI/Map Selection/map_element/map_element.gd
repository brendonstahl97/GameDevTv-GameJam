class_name MapElement
extends PanelContainer

@onready var label: Label = %Label
@onready var texture_rect: TextureRect = %TextureRect

@export var map_resource: Map

func _ready() -> void:
	label.text = map_resource.map_name
	texture_rect.texture = map_resource.map_thumbnail
