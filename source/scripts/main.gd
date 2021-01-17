extends Node2D

func _ready() -> void:
	randomize()
	Globals.main_instance = self

	TaskManager.add_queue(
		"main",
		$camera.create_fade_in(0.5)
	)

	if !Globals.played_intro:
		$intro.play()
		Globals.played_intro = true
