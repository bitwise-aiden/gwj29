class_name Pet extends Node2D

enum STATES { gnomeless = 0, joining, orbiting, attacking, resting }

const WANDER_VELOCITY_X_MAX = 0.5
const WANDER_DISTANCE_MAX = 30.0
const ATTACKING_DISTANCE_MAX = 250.0
const ATTACKING_TIME_MAX = 0.25


export (Resource) var resource = null


var state: int = STATES.gnomeless

onready var wander_origin_x: float = self.position.x
var wander_velocity_x: float = 0.0
var wander_acceleration_x: float = 0.05
var wander_return_desire: float = 0.0

var orbit_position: Vector2 = Vector2.ZERO

var attacking_timer = 0.0
var attacking_start_x = 0.0
var attacking_end_x = 0.0
var attacking_direction = 0.0


func _ready() -> void:
	$sprite.texture = self.resource.texture
	self.add_to_group("pets")


func _physics_process(delta: float) -> void:
	match self.state:
		STATES.gnomeless:
			self.__handle_gnomeless()
		STATES.joining:
			self.__handle_joining()
		STATES.orbiting:
			self.__handle_orbiting()
		STATES.attacking:
			self.__handle_attacking()
		STATES.resting:
			self.__handle_resting()

	if self.state != STATES.gnomeless:
		print(self.state)


func set_state( incoming_state: int ) -> void:
	match incoming_state:
		STATES.joining:
			$sprite.position.y = 0.0
		STATES.attacking:
			self.attacking_start_x = self.position.x
			self.attacking_end_x = self.attacking_start_x + self.ATTACKING_DISTANCE_MAX * self.attacking_direction
			self.attacking_timer = PhysicsTime.elapsed_time

	self.state = incoming_state



func __handle_gnomeless() -> void:
	var elapsed = PhysicsTime.elapsed_time
	var radians = fmod( pow( elapsed , 2.0 ), TAU )

	$sprite.position.y = sin( elapsed ) * 10.0

	if randi() % 250 == 0:
		self.wander_acceleration_x *= -1.0

	var distance = self.position.x - self.wander_origin_x
	self.wander_return_desire = abs(distance) / self.WANDER_DISTANCE_MAX * -sign(distance) * 0.05

	self.wander_velocity_x += self.wander_acceleration_x + self.wander_return_desire
	self.wander_velocity_x = clamp(self.wander_velocity_x, -self.WANDER_VELOCITY_X_MAX, self.WANDER_VELOCITY_X_MAX)

	self.position.x += self.wander_velocity_x

	$sprite.scale.x = -sign(self.wander_velocity_x)


func __handle_joining() -> void:
	if self.position.distance_to(self.orbit_position) <= 0.001:
		self.state = STATES.orbiting


func __handle_orbiting() -> void:
	pass


func __handle_attacking() -> void:
	var time_since_start = PhysicsTime.elapsed_time - self.attacking_timer
	var time_delta = time_since_start / self.ATTACKING_TIME_MAX

	if time_delta >= 1.0:
		self.state = STATES.joining

	self.position.x = lerp( self.attacking_start_x, self.attacking_end_x, time_delta )


func __handle_resting() -> void:
	pass
