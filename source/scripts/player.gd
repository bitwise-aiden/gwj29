extends KinematicBody2D


const VELOCITY_MAX = 250.0
const JUMP_VELOCITY_MAX = 500.0
const JUMP_BUFFER_MAX = 0.1
const ON_GROUND_BUFFER = 0.1


var acceleration: float = 1000.0
var velocity: Vector2 = Vector2.ZERO

var drag: float = 0.1
var gravity: float = -30

var jumping = false
var jump_buffer: float = 0.0
var on_ground_buffer: float = 0.0

var facing_direction: float = 1.0

func _physics_process(delta: float) -> void:
	if self.jump_buffer > 0.0:
		self.jump_buffer = max(0.0, self.jump_buffer - PhysicsTime.delta_time)

	if self.on_ground_buffer > 0.0:
		self.on_ground_buffer = max(0.0, self.on_ground_buffer - PhysicsTime.delta_time)

	if Input.is_action_just_pressed( "ui_up" ):
		self.jump_buffer = self.JUMP_BUFFER_MAX
	elif Input.is_action_just_released( "ui_up" ):
		if self.velocity.y < 0.0:
			self.velocity.y *= 0.3

	self.velocity.y -= self.gravity

	if self.is_on_floor():
		$Label.text = "I am on the floor"
		self.jumping = false
		self.on_ground_buffer = self.ON_GROUND_BUFFER
	else:
		$Label.text = "Weee, I am flying"

	if self.is_on_floor():
		self.velocity = lerp( self.velocity, Vector2.ZERO, self.drag)

		var movement_direction = Vector2(
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			0.0
		).normalized()

		self.velocity += movement_direction * self.acceleration * PhysicsTime.delta_time

	self.velocity.x = min( self.velocity.x, self.VELOCITY_MAX )

	if self.should_jump():
		self.velocity.y = -self.JUMP_VELOCITY_MAX
		self.jumping = true

	self.move_and_slide(PhysicsTime.scale_vector2(self.velocity), Vector2.UP)
	self.facing_direction = sign(self.velocity.x)


func should_jump() -> bool:
	return self.on_ground_buffer > 0.0 && self.jump_buffer > 0.0 && !self.jumping
