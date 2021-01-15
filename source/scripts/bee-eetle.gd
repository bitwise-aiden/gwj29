extends KinematicBody2D

enum STATES { idle, walking, readying, charging, stunned, dying }


const WALKING_SPEED_MAX = 50.0
const CHARGING_SPEED_MAX = 500.0
const STUNNED_TIME_MAX = 2.0
const READYING_TIME_MAX = 1.5
const STAGE_TWO_HEALTH = 5
const DAMAGE_RADIUS = 25.0

var health: int = 15


var acceleration: float = 1000.0
var velocity: Vector2 = Vector2.ZERO

var drag: float = 0.1
var gravity: float = -30

var state: int = STATES.idle

var facing_direction: float = -1.0

var stunned_time: float = 0.0
var readying_time: float = 0.0
var stunned_charging: bool = false


func _ready() -> void:
	self.add_to_group("enemies")


func _physics_process(delta: float) -> void:
	var player = Globals.player_instance

	match self.state:
		STATES.idle:
			var player_direction_x = sign(self.position.direction_to(player.position).x)
			if player.position.y > 250.0:
				self.state = STATES.readying
				self.readying_time = PhysicsTime.elapsed_time + self.READYING_TIME_MAX
				self.velocity.x = player_direction_x * 7.5

		STATES.walking:
			var player_direction_x = sign(self.position.direction_to(player.position).x)
			self.velocity.x += self.facing_direction * self.acceleration * PhysicsTime.delta_time

			self.velocity.x = clamp(self.velocity.x, -self.WALKING_SPEED_MAX, self.WALKING_SPEED_MAX)
			$sprite.play("walking")

			var distance = self.position.distance_to(player.position)
			if sign(player_direction_x) == self.facing_direction && distance < 250.0:
				self.state = STATES.readying
				self.readying_time = PhysicsTime.elapsed_time + self.READYING_TIME_MAX
				self.velocity.x = player_direction_x * 7.5

		STATES.charging:
			var player_direction_x = sign(self.position.direction_to(player.position).x)
			self.velocity.x += self.facing_direction * self.acceleration * PhysicsTime.delta_time

			self.velocity.x = clamp(self.velocity.x, -self.CHARGING_SPEED_MAX, self.CHARGING_SPEED_MAX)
			$sprite.play("charging")

		STATES.stunned:
			if PhysicsTime.on_timestamp(self.stunned_time):
				self.facing_direction *= -1
				self.state = STATES.charging
				self.stunned_time = 0.0
				self.stunned_charging = true

		STATES.readying:
			$sprite.play("idle")
			if PhysicsTime.on_timestamp(self.readying_time):
				self.state = STATES.charging
				self.readying_time = 0.0


	if self.velocity.x:
		$sprite.scale.x = -sign(self.velocity.x) * 2.0

	self.move_and_slide(PhysicsTime.scale_vector2(self.velocity), Vector2.UP)

	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.name == "world":
			match self.state:
				STATES.walking:
					self.facing_direction *= -1
					self.velocity.x = 0.0
					$collision_horn.position.x *= -1
				STATES.charging:
					if self.stunned_charging:
						self.stunned_charging = false
						self.facing_direction *= -1
						self.velocity.x = 0.0
						if self.health > self.STAGE_TWO_HEALTH:
							self.state = STATES.walking
					elif self.health > self.STAGE_TWO_HEALTH:
						self.state = STATES.stunned
						self.velocity.x = 0.0
						$sprite.play("idle")
						self.stunned_time = PhysicsTime.elapsed_time + self.STUNNED_TIME_MAX
					else:
						self.facing_direction *= -1
						self.velocity.x = 0.0
		elif self.state == STATES.charging:
			player.damage(self)
			self.state = STATES.stunned
			self.velocity.x = 0.0
			$sprite.play("idle")
			self.stunned_time = PhysicsTime.elapsed_time + self.STUNNED_TIME_MAX



func damage() -> void:
	self.health -= 1

	if self.health <= 0:
		self.call_deferred("queue_free")

		self.state = STATES.dying
		self.velocity = Vector2.ZERO

		var player = Globals.player_instance
		var player_direction = self.position.direction_to(player.position)

		var defeated = load("res://source/scenes/bee-eetle_defeated.tscn").instance()
		defeated.position = self.position
		defeated.apply_impulse(player_direction * 32.0, Vector2(player_direction.x * -250.0, -250.0))
		defeated.get_child(0).scale.x = $sprite.scale.x

		Globals.main_instance.call_deferred("add_child", defeated)


		var wing_a = load("res://source/scenes/bee-wing.tscn").instance()
		wing_a.position = self.position
		wing_a.apply_impulse(player_direction * -32.0, Vector2(player_direction.x * 500.0, 250.0))
		wing_a.get_child(0).scale.x = $sprite.scale.x

		Globals.main_instance.call_deferred("add_child", wing_a)


		var wing_b = load("res://source/scenes/bee-wing.tscn").instance()
		wing_b.position = self.position
		wing_b.apply_impulse(player_direction * 32.0, Vector2(player_direction.x * -500.0, -250.0))
		wing_b.get_child(0).scale.x = $sprite.scale.x

		Globals.main_instance.call_deferred("add_child", wing_b)


		var butt = load("res://source/scenes/bee-butt.tscn").instance()
		butt.position = self.position
		butt.apply_impulse(player_direction * -32.0, Vector2(player_direction.x * 250.0, 250.0))
		butt.get_child(0).scale.x = $sprite.scale.x

		Globals.main_instance.call_deferred("add_child", butt)



