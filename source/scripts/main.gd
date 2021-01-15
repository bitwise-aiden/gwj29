extends Node2D

func _ready() -> void:
	randomize()
	Globals.main_instance = self
