extends Node


const COLLECTION_RADIUS_MAX = 50.0
const ORBITING_RADIUS_MAX = 30.0


var orbiting: Array = []

func _physics_process(delta: float) -> void:
	self.__collect_pets()
	self.__orbit_pets()


	if Input.is_action_just_pressed( "attack" ):
		self.__handle_attacking()


func __collect_pets() -> void:
	for pet in self.get_tree().get_nodes_in_group("pets"):
		if pet.state != Pet.STATES.gnomeless:
			continue

		var distance = self.__position().distance_to(pet.position)
		if distance <= self.COLLECTION_RADIUS_MAX:
			pet.set_state(Pet.STATES.joining)
			self.orbiting.append(pet)
			self.get_parent().found_bee = true


func __handle_attacking():
	if self.orbiting.empty():
		return

	var facing_direction = self.get_parent().facing_direction

	var position = self.__position()
	var pets = self.orbiting.duplicate()
	pets.sort_custom(self, "__sort_position")

	while !pets.empty():
		var pet = null
		if facing_direction < 0:
			pet = pets.pop_front()
		else:
			pet = pets.pop_back()

		if pet.state == Pet.STATES.orbiting:
			pet.attacking_direction = facing_direction
			pet.set_state(Pet.STATES.attacking)

			self.get_parent().set_text("Buzzzz!")
			self.get_parent().play_sound($buzz)

			return


func __sort_position( a, b ) -> bool:
	return a.position.x <= b.position.x


func __orbit_pets() -> void:
	if self.orbiting.empty():
		return

	var count = self.orbiting.size()

	var separation_angle = TAU / count

	var rng = RandomNumberGenerator.new()
	rng.set_seed(3)

	for i in range(count):
		if !self.orbiting[i].state in [Pet.STATES.joining, Pet.STATES.orbiting]:
			continue

#		var direction = -1 if randi() % 2 == 0 else 1
		var orbit_offset = Vector2.UP.rotated(separation_angle * i + PhysicsTime.elapsed_time)
		var orbiting_radius = self.ORBITING_RADIUS_MAX
		if !self.get_parent() is Player:
			orbiting_radius *= 2.5

		orbiting_radius *= rng.randf() * 0.1 - 1.0

		var orbit_position = self.__position() + orbit_offset * orbiting_radius

		var move_speed = 200.0

		self.orbiting[i].position = self.orbiting[i].position.move_toward(
			orbit_position,
			PhysicsTime.delta_time * move_speed
		)
		self.orbiting[i].orbit_position = orbit_position
		self.orbiting[i].facing_direction = self.get_parent().facing_direction


func __position() -> Vector2:
	return self.get_parent().position


func stop_attack() -> void:
	for pet in self.orbiting:
		if pet.state == Pet.STATES.attacking:
			pet.state = Pet.STATES.orbiting


func reparent(parent) -> void:
	self.get_parent().remove_child(self)
	parent.add_child(self)


func spawn_bees() -> void:
	var bee_scene = load("res://source/scenes/pet.tscn")

	for i in range(10):
		var instance = bee_scene.instance()
		instance.position = self.__position() + Vector2(-500.0, 0.0).rotated(PI * 1.5 + PI/10 * i)
		instance.state = Pet.STATES.joining

		self.orbiting.insert(randi() % self.orbiting.size(), instance)

		Globals.main_instance.call_deferred("add_child", instance)
