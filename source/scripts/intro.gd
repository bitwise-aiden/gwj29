extends Node2D


func _ready() -> void:
	TaskManager.add_queue(
		"intro",
		$camera.create_fade_in(0.5)
	)

	TaskManager.add_queue(
		"intro",
		Task.Wait.new(1.0)
	)

	TaskManager.add_queue(
		"intro",
		Task.RunFunc.new(funcref($intro, "play"))
	)

	var camera_shake = $camera.create_camera_shake(20.0, 0.2)
	TaskManager.add_queue(
		"intro",
		camera_shake
	)


	TaskManager.add_queue(
		"intro",
		Task.Lerp.new(Vector2(244.0, 166.0), Vector2(244.0, 500.0), 10.0, funcref($hive, "set_position"))
	)

	TaskManager.add_queue(
		"intro_2",
		Task.WaitForTask.new(camera_shake)
	)

	TaskManager.add_queue(
		"intro_2",
		Task.Lerp.new(0.0, PI, 10.0, funcref($hive, "set_rotation"))
	)

	TaskManager.add_queue(
		"intro",
		$camera.create_camera_shake(20.0, 0.2)
	)


func _on_audio_finished() -> void:
	TaskManager.add_queue(
		"intro",
		$camera.create_fade_out(0.5)
	)

	TaskManager.add_queue(
		"intro",
		Task.RunFunc.new(funcref(SceneManager, "load_scene"), ["main"])
	)
