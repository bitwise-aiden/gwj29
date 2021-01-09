extends Camera2D

export( bool ) var is_default = false

func _ready() -> void: 
	if self.is_default: 
		self.make_current()


func create_camera_shake( intensity: float, duration: float ) -> Task.CameraShake:
	return Task.CameraShake.new( self, intensity, duration)


func create_fade_in( duration: float, color: Color = Color.black ) -> Task.Lerp:
	var transparent = color
	transparent.a = 0.0
	
	return Task.Lerp.new( color, transparent, duration, funcref( $fade, 
		"set_frame_color" ) )


func create_fade_out( duration: float, color: Color = Color.black ) -> Task.Lerp:
	var transparent = color
	transparent.a = 0.0
	
	return Task.Lerp.new( transparent, color, duration, funcref( $fade, 
		"set_frame_color" ) )
