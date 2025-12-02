extends Node

@warning_ignore_start("unused_signal")

signal display_dialog(text_key: String)
signal dialog_completed
signal successful_parry(global_position: Vector3)
signal customer_completed(reward: int, player_name: String)

@warning_ignore_restore("unused_signal")