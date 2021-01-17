extends TileMap

var current: Vector2 = Vector2(0,0)
var moving_horizontal: bool = true

func _ready() -> void:
	Globals.world_instance = self

	self.load_from_vector(self.current)


func load_from_vector(map_position: Vector2, reload: bool = false) -> void:
	var texture = self.load_texture(map_position)
	self.load_from_texture(texture, reload)


func load_from_texture(texture: Texture, reload: bool = false) -> void:
	self.clear()

	var message = ""
	match self.current:
		Vector2(0, 0):
			message = "HELP THE BEES!\nmove - left/right\njump - space"
		Vector2(1, 0):
			message = "collect the bees"
		Vector2(3, 0):
			message = "throw bees - c"


	if message:
		$help_message.visible = true
		$help_message/message.text = message
		$help_message/shadow.text = message
	else:
		$help_message.visible = false


	var image = texture.get_data()
	image.lock()

	for enemy in self.get_tree().get_nodes_in_group("enemies"):
		enemy.call_deferred("queue_free")

	for x in range(image.get_width()):
		for y in range(image.get_height()):
			match image.get_pixel(x,y):
				Color("9de64e"):
					self.set_cellv(Vector2(x,y), 0)
				Color("6e4c30"):
					self.set_cellv(Vector2(x,y), 1)
				Color("543a25"):
					self.set_cellv(Vector2(x,y), 2)
				Color("ec273f"):
					self.spawn_player(Vector2(x,y), reload)
				Color("f3a833"):
					self.spawn_pet(Vector2(x,y), reload)
				Color("5ab552"):
					self.spawn_slime(Vector2(x,y))
				Color("3c4391"):
					self.spawn_beeeetle(Vector2(x, y))

	for layer in self.get_tree().get_nodes_in_group( "world_layers" ):
		layer.update_layer()

func load_texture(map_position: Vector2) -> Resource:
	return load("res://source/assets/levels/%dx%d.png" % [map_position.x, map_position.y])


func reload_current():
	self.get_tree().paused = true

	TaskManager.add_queue(
		"world",
		Globals.camera_instance.create_fade_out( 0.2 )
	)

	TaskManager.add_queue(
		"world",
		Task.RunFunc.new(funcref($death_message/label, "set_visible"), [true])
	)

	TaskManager.add_queue(
		"world",
		Task.RunFunc.new(funcref(self, "load_from_vector"), [self.current, true])
	)

	TaskManager.add_queue(
		"world",
		Task.Wait.new(1.0)
	)

	TaskManager.add_queue(
		"world",
		Task.RunFunc.new(funcref($death_message/label, "set_visible"), [false])
	)

	TaskManager.add_queue(
		"world",
		Globals.camera_instance.create_fade_in( 0.2 )
	)

	TaskManager.add_queue(
		"world",
		Task.RunFunc.new(funcref(self, "unpause"))
	)


func load_next_right() -> void:
	self.load_next_offset(Vector2.RIGHT)
	self.moving_horizontal = true


func load_next_down() -> void:
	self.load_next_offset(Vector2.DOWN)
	self.moving_horizontal = false


func load_next_up() -> void:
	self.load_next_offset(Vector2.UP)
	self.moving_horizontal = false


func load_next_offset(offset: Vector2) -> void:
	var next = self.current + offset
	var texture = self.load_texture(next)
	if !texture:
		return

	self.current = next

	self.get_tree().paused = true

	TaskManager.add_queue(
		"world",
		Globals.camera_instance.create_fade_out( 0.5 )
	)

	TaskManager.add_queue(
		"world",
		Task.RunFunc.new(funcref(self, "update_entities"))
	)

	TaskManager.add_queue(
		"world",
		Task.RunFunc.new(funcref(self, "load_from_texture"), [texture])
	)

	TaskManager.add_queue(
		"world",
		Task.RunFunc.new(funcref(self, "switch_background"), [self.current.y])
	)

	TaskManager.add_queue(
		"world",
		Globals.camera_instance.create_fade_in( 0.5 )
	)

	TaskManager.add_queue(
		"world",
		Task.RunFunc.new(funcref(self, "unpause"))
	)


func switch_background(background: int) -> void:
	Globals.main_instance.get_child(0).visible = background == 0
	Globals.main_instance.get_child(1).visible = background == 1


func update_entities():
	if self.moving_horizontal:
		Globals.player_instance.position.x = 16
	else:
		Globals.player_instance.position.y = -(Globals.player_instance.position.y - 360.0)

	for pet in self.get_tree().get_nodes_in_group("pets"):
		if pet.state == Pet.STATES.gnomeless:
			pet.call_deferred( "queue_free" )
		else:
			pet.position = Globals.player_instance.position
			pet.set_state(Pet.STATES.orbiting)

func unpause():
	self.get_tree().paused = false

func spawn_player(position: Vector2, reload: bool = true) -> void:
	if !Globals.player_instance:
		var instance = load("res://source/scenes/player.tscn").instance()
		instance.position = position * 32
		Globals.health_instance.health_changed(3)

		self.get_parent().call_deferred("add_child", instance)
	elif reload:
		Globals.player_instance.position = position * 32
		Globals.player_instance.health = 3
		Globals.player_instance.velocity = Vector2.ZERO
		Globals.player_instance.found_bee = false
		Globals.health_instance.health_changed(3)


func spawn_pet(position: Vector2, reload: bool) -> void:
	for pet in self.get_tree().get_nodes_in_group("pets"):
		if pet.state == Pet.STATES.gnomeless:
			return

	var instance = load("res://source/scenes/pet.tscn").instance()
	instance.position = position * 32

	self.get_parent().call_deferred("add_child", instance)


func spawn_slime(position: Vector2) -> void:
	var instance = load("res://source/scenes/slime.tscn").instance()
	instance.position = position * 32

	self.get_parent().call_deferred("add_child", instance)

func spawn_beeeetle(position: Vector2) -> void:
	var instance = load("res://source/scenes/bee-eetle.tscn").instance()
	instance.position = position * 32
#	instance.position.y += 50.0

	self.get_parent().call_deferred("add_child", instance)
