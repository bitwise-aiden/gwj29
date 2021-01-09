class_name PlayerInput


var player_input = [
	"up",
	"down",
	"left",
	"right",
]


var __input_queue: CurrentQueue = CurrentQueue.new( "idle" )


func current():
	return self.__input_queue.current()


func update():
	for input in self.player_input:
		if Input.is_action_just_pressed( input ):
			self.__input_queue.add( input )
		elif Input.is_action_just_released( input ):
			self.__input_queue.remove( input )
