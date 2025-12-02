@abstract class_name SequentialScreen
extends Control

@warning_ignore_start("unused_signal")
signal previous_screen
signal next_screen

@abstract func update(delta: float)
