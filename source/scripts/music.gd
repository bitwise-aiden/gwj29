extends AudioStreamPlayer


export (AudioStream) var default
export (AudioStream) var boss


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.music_instance = self


func play_default() -> void:
	self.fade_between(self.default)


func play_boss() -> void:
	self.fade_between(self.boss)
#	self.set_stream(self.boss)
#	self.playing = true


func fade_between(stream: AudioStream) -> void:
	TaskManager.add_queue(
		"music",
		Task.Lerp.new(0.0, -80.0, 2.0, funcref(self, "set_volume_db"))
	)

	TaskManager.add_queue(
		"music",
		Task.RunFunc.new(funcref(self, "set_stream"), [stream])
	)

	TaskManager.add_queue(
		"music",
		Task.RunFunc.new(funcref(self, "_set_playing"), [true])
	)

	TaskManager.add_queue(
		"music",
		Task.RunFunc.new(funcref(self, "set_volume_db"), [0.0])
	)
