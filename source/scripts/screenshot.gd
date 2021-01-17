extends Node2D

var count = 0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		self.screenshot()

func screenshot() -> void:
	var capture
	self.hide()
#	yield(get_tree().create_timer(0.5), "timeout")
	capture = get_viewport().get_texture().get_data()
	capture.flip_y()
	capture.save_png("user://screenshot_%d.png" % self.count)
	OS.shell_open(OS.get_user_data_dir())

	count += 1
