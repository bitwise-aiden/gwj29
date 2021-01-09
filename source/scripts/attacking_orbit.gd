extends Node


const COLLECTION_RADIUS_MAX = 50.0
const ORBITING_RADIUS_MAX = 30.0


var orbiting: Array = []

func _physics_process(delta: float) -> void:
	self.__collect_pets()
	self.__orbit_pets()


	if Input.is_action_just_pressed( "attacking" ):
		self.__handle_attacking()


func __collect_pets() -> void:
	for pet in self.get_tree().get_nodes_in_group("pets"):
		if pet.state != Pet.STATES.gnomeless:
			continue

		var distance = self.__position().distance_to(pet.position)
		if distance <= self.COLLECTION_RADIUS_MAX:
			pet.set_state(Pet.STATES.joining)
			self.orbiting.append(pet)


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
			print(pet.state)
			pet.attacking_direction = facing_direction
			pet.set_state(Pet.STATES.attacking)

			return


func __sort_position( a, b ) -> bool:
	return a.position.x <= b.position.x


func __orbit_pets() -> void:
	if self.orbiting.empty():
		return

	var count = self.orbiting.size()

	var separation_angle = TAU / count

	for i in range(count):
		if !self.orbiting[i].state in [Pet.STATES.joining, Pet.STATES.orbiting]:
			continue

		var orbit_offset = Vector2.UP.rotated(separation_angle * i + PhysicsTime.elapsed_time)
		var orbit_position = self.__position() + orbit_offset * self.ORBITING_RADIUS_MAX

		var move_speed = 200.0

		self.orbiting[i].position = self.orbiting[i].position.move_toward(
			orbit_position,
			PhysicsTime.delta_time * move_speed
		)
		self.orbiting[i].orbit_position = orbit_position


func __position() -> Vector2:
	return self.get_parent().position
