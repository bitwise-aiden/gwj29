extends RigidBody2D

func _ready() -> void:
	Globals.queen_instance.get_child(1).connect("finished", self, "on_audio_finished")

	TaskManager.add_queue(
		"end_game",
		Task.Wait.new(5.0)
	)

	TaskManager.add_queue(
		"end_game",
		Task.RunFunc.new(funcref($message, "set_visible"), [false])
	)

	TaskManager.add_queue(
		"end_game",
		Task.RunFunc.new(funcref($shadow, "set_visible"), [false])
	)

	TaskManager.add_queue(
		"end_game",
		Task.RunFunc.new(funcref(Globals.boss_health_instance, "set_visible"), [false])
	)

	TaskManager.add_queue(
		"end_game",
		Task.Lerp.new(Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), 0.2, funcref(self, "set_modulate"))
	)

	TaskManager.add_queue(
		"end_game",
		Task.Lerp.new(Vector2(750.0, 0.0), Vector2(545.0, 130.0), 1.0, funcref(Globals.queen_instance, "set_position"))
	)

	TaskManager.add_queue(
		"end_game",
		Globals.camera_instance.create_camera_shake(5.0, 0.2)
	)

	TaskManager.add_queue(
		"end_game",
		Task.RunFunc.new(funcref(Globals.queen_instance.get_child(1), "play"))
	)

	TaskManager.add_queue(
		"end_game",
		Task.RunFunc.new(funcref(Globals.queen_instance.get_child(0), "set_visible"), [true])
	)

	TaskManager.add_queue(
		"end_game",
		Task.Wait.new(1.0)
	)

	TaskManager.add_queue(
		"end_game",
		Task.RunFunc.new(funcref(Globals.player_instance.get_child(4), "reparent"), [Globals.queen_instance])
	)

	TaskManager.add_queue(
		"end_game",
		Task.RunFunc.new(funcref(Globals.player_instance.get_child(4), "spawn_bees"))
	)


func on_audio_finished():
	TaskManager.add_queue(
		"end_game",
		Task.RunFunc.new(funcref(Globals.queen_instance.get_child(0), "set_visible"), [false])
	)

	TaskManager.add_queue(
		"end_game",
		Task.Wait.new(1.0)
	)

	TaskManager.add_queue(
		"end_game",
		Globals.camera_instance.create_fade_out(1.0)
	)

	TaskManager.add_queue(
		"end_game",
		Task.RunFunc.new(funcref(Globals, "reset_player_instance"))
	)

	TaskManager.add_queue(
		"end_game",
		Task.RunFunc.new(funcref(self.get_tree(), "reload_current_scene"))
	)
