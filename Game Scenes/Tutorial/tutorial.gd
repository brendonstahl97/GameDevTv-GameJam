extends Node3D

@onready var objective_manager: ObjectiveManager = %ObjectiveManager
@export var game_camera: Camera3D
@export var environment: Node
@onready var pause_menu: Control = %PauseMenu


func _ready() -> void:
  game_camera.setup()


func _process(_delta: float) -> void:
  if (Input.is_action_just_pressed("ui_cancel")):
    pause_menu.open()


func _on_objective_manager_all_objectives_completed() -> void:
  global.playerInfo = null
  for child in BackgroundMusic.get_children():
    if (child is AudioStreamPlayer):
      child.stop()

  BackgroundMusic.get_child(0).volume_db = -12
  BackgroundMusic.get_child(0).play()
  pause_menu.close()
  get_tree().change_scene_to_file("res://Game Scenes/Start Menu/Start.tscn")
