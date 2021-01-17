class_name Pet extends Node2D

enum STATES { gnomeless = 0, joining, orbiting, attacking, resting }

const WANDER_VELOCITY_X_MAX = 0.5
const WANDER_DISTANCE_MAX = 30.0
const ATTACKING_DISTANCE_MAX = 200.0
const ATTACKING_TIME_MAX = 0.25
const RESTING_TIME_MAX = 1.0

var state: int = STATES.gnomeless

onready var wander_origin_x: float = self.position.x
var wander_velocity_x: float = 0.0
var wander_acceleration_x: float = 0.05
var wander_return_desire: float = 0.0

var orbit_position: Vector2 = Vector2.ZERO

var attacking_timer: float = 0.0
var attacking_start = Vector2.ZERO
var attacking_end = Vector2.ZERO
var attacking_direction: float = 0.0
var attacking_enemy: Node = null

var resting_timer: float = 0.0
var facing_direction: float = 0.0

func _ready() -> void:
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


func set_state( incoming_state: int ) -> void:
	self.set_text("")
	match incoming_state:
		STATES.joining:
			$sprite.position.y = 0.0
			$sprite.scale.y = 1.0
		STATES.orbiting:
			$sprite.scale.y = 1.0
		STATES.attacking:
			self.__handle_change_to_attacking()
		STATES.resting:
			self.resting_timer = PhysicsTime.elapsed_time + self.RESTING_TIME_MAX

	self.state = incoming_state


func __handle_change_to_attacking():
	var closest_distance = self.ATTACKING_DISTANCE_MAX
	var closest_enemy = null

	for enemy in self.get_tree().get_nodes_in_group("enemies"):
		var direction = self.position.direction_to(enemy.position)
		if sign(direction.x) != self.attacking_direction:
			continue

		var distance = self.position.distance_to(enemy.position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy

	self.attacking_start = self.position
	self.attacking_timer = PhysicsTime.elapsed_time
	self.attacking_enemy = closest_enemy
	$sprite.scale.x = -self.attacking_direction

	if closest_enemy:
		var direction = self.position.direction_to(closest_enemy.position)
		self.attacking_end = self.position + direction * self.ATTACKING_DISTANCE_MAX
	else:
		self.attacking_end = self.position + Vector2(self.ATTACKING_DISTANCE_MAX * self.attacking_direction, 0.0)



func __handle_gnomeless() -> void:
	self.set_text("Buzz!")

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


func __handle_orbiting() -> void:
	if self.facing_direction:
		$sprite.scale.x = -self.facing_direction

func __handle_joining() -> void:
	self.set_text("")
	$sprite.scale.y = 1.0

	var direction = self.position.direction_to(self.orbit_position);
	if sign(direction.x):
		$sprite.scale.x = -sign(direction.x)

	if self.position.distance_to(self.orbit_position) <= 0.001:
		self.state = STATES.orbiting


func __handle_attacking() -> void:
	self.set_text("BUZZZZZ!!!")

	var time_since_start = PhysicsTime.elapsed_time - self.attacking_timer
	var time_delta = time_since_start / self.ATTACKING_TIME_MAX

	if time_delta >= 1.0:
		self.state = STATES.joining

	self.position = lerp( self.attacking_start, self.attacking_end, time_delta )

	if self.attacking_enemy && self.position.distance_to(self.attacking_enemy.position) < self.attacking_enemy.DAMAGE_RADIUS:
		self.set_state(STATES.resting)
		self.attacking_enemy.damage()
		self.attacking_enemy = null


func __handle_resting() -> void:
	self.set_text("Zzzzzz")

	if PhysicsTime.on_timestamp(self.resting_timer):
		self.set_state(STATES.joining)

	$sprite.position.y = sin( PhysicsTime.elapsed_time ) * 10.0
	$sprite.scale.y = -1.0

func set_text(text: String) -> void:
	$message.rect_size.x = 0
	$message.text = text
	$message.rect_position.x = -text.length() * 4
	$shadow.rect_size.x = 0
	$shadow.text = text
	$shadow.rect_position.x = 1 - text.length() * 4
	$shadow.rect_position.y = $message.rect_position.y + 1
