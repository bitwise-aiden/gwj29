class_name Player extends KinematicBody2D

const VELOCITY_MAX = 250.0
const JUMP_VELOCITY_MAX = 500.0
const JUMP_BUFFER_MAX = 0.125
const ON_GROUND_BUFFER = 0.125

var health = 3

var acceleration: float = 1000.0
var velocity: Vector2 = Vector2.ZERO

var drag: float = 0.1
var gravity: float = -30

var jumping = false
var jump_buffer: float = 0.0
var on_ground_buffer: float = 0.0

var facing_direction: float = 1.0

var found_bee: bool = false

var damaged_timer: float = 0.0


func _ready() -> void:
	Globals.player_instance = self
	self.set_text("")
	$sprite.play("idle")


func _physics_process(delta: float) -> void:
	self.__handle_damaged()
	self.__handle_movement()


func __handle_damaged() -> void:
	if !self.damaged_timer:
		return

	if !PhysicsTime.on_timestamp( self.damaged_timer ):
		if PhysicsTime.on_interval( 0.1, 0.0 ):
			$sprite.visible = !$sprite.visible

		self.set_text("Ouch!")
		self.stop_sound($attacking_orbit/buzz)
		self.stop_sound($wee)
		self.play_sound($ouch)
	else:
		self.damaged_timer = 0.0
		$sprite.visible = true
		self.set_text("")

		if self.health <= 0:
			if self.found_bee:
				var pet = $attacking_orbit.orbiting.pop_back()
				pet.call_deferred("queue_free")

			Globals.world_instance.reload_current()


func __handle_movement():
	if self.jump_buffer > 0.0:
		self.jump_buffer = max(0.0, self.jump_buffer - PhysicsTime.delta_time)

	if self.on_ground_buffer > 0.0:
		self.on_ground_buffer = max(0.0, self.on_ground_buffer - PhysicsTime.delta_time)

	if Input.is_action_just_pressed( "jump" ):
		self.jump_buffer = self.JUMP_BUFFER_MAX
	elif Input.is_action_just_released( "jump" ):
		if self.velocity.y < 0.0:
			self.velocity.y *= 0.3

	self.velocity.y -= self.gravity

	if self.is_on_floor():
		self.jumping = false
		self.on_ground_buffer = self.ON_GROUND_BUFFER

	if self.is_on_floor() && !self.damaged_timer:
		self.velocity = lerp( self.velocity, Vector2.ZERO, self.drag)

		var movement_direction = Vector2(
			Input.get_action_strength("right") - Input.get_action_strength("left"),
			0.0
		).normalized()

		if movement_direction:
			self.velocity += movement_direction * self.acceleration * PhysicsTime.delta_time
		else:
			self.velocity.x = 0.0

	self.velocity.x = min( self.velocity.x, self.VELOCITY_MAX )

	if self.should_jump() && !self.damaged_timer:
		self.set_text("Weee!")
		self.play_sound($wee, $attacking_orbit/buzz)
		self.velocity.y = -self.JUMP_VELOCITY_MAX
		self.jumping = true

	self.move_and_slide(PhysicsTime.scale_vector2(self.velocity), Vector2.UP)
	if self.velocity.x:
		self.facing_direction = sign(self.velocity.x)

	if self.facing_direction != 0.0:
		$sprite.scale.x = self.facing_direction

	if !self.is_on_floor():
		$sprite.play("jump")
	elif abs(self.velocity.x) > 5.0:
		$sprite.play("walking")
	else:
		$sprite.play("idle")

	if self.position.y <= 0.0 && Globals.world_instance.current == Vector2(7,1):
		Globals.world_instance.load_next_up()
		self.velocity = Vector2(-250.0, -500.0)


func damage(body: Node) -> void:
	var direction = Vector2(
		-self.position.direction_to(body.position).x,
		-1.0
	).normalized()

	self.damaged_timer = PhysicsTime.elapsed_time + 0.5
	$sprite.visible = false

	TaskManager.add_queue(
		"camera",
		Globals.camera_instance.create_camera_shake(2.0, 0.1)
	)

	self.velocity = direction * 300.0

	self.health -= 1
	Globals.health_instance.health_changed(self.health)

	if health <= 0:
		$attacking_orbit.stop_attack()


func should_jump() -> bool:
	return self.on_ground_buffer > 0.0 && self.jump_buffer > 0.0 && !self.jumping


func set_text(text: String) -> void:
	$message.rect_size.x = 0
	$message.text = text
	$message.rect_position.x = -text.length() * 4
	$shadow.rect_size.x = 0
	$shadow.text = text
	$shadow.rect_position.x = 1 - text.length() * 4
	$shadow.rect_position.y = $message.rect_position.y + 1


func _on_hit_area_body_entered(body: Node) -> void:
	if body is Slime && !self.damaged_timer:
		self.damage(body)

	if body is WorldEdges:
		if self.position.x > 1280 / 2 - 30:
			Globals.world_instance.load_next_right()
			self.found_bee = false
		elif self.position.y > 720 / 2:
			if Globals.world_instance.current == Vector2(4,0):
				Globals.world_instance.load_next_down()
				self.velocity = Vector2.ZERO
			else:
				Globals.world_instance.reload_current()
				if self.found_bee:
					var pet = $attacking_orbit.orbiting.pop_back()
					pet.call_deferred("queue_free")
		elif self.velocity.y < 0.0:
			self.velocity.y = 0.0

func play_sound(sound: Node, other: Node = null) -> void:
	if other:
		for child in other.get_children():
			if child.playing:
				return

	for child in sound.get_children():
		if child.playing:
			return
	sound.get_child(randi() % sound.get_child_count()).play()


func stop_sound(sound: Node) -> void:
	for child in sound.get_children():
		child.playing = false


func _on_buzz_finished() -> void:
	if $message.text == "Buzzzz!":
		self.set_text("")


func _on_ouch_finished() -> void:
	if $message.text == "Ouch!":
		self.set_text("")


func _on_wee_finished() -> void:
	if $message.text == "Weee!":
		self.set_text("")
