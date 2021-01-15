extends TileMap


export (int) var layer = 0
export (int) var type_count = 0


func update_layer():
	self.clear()

	for location in Globals.world_instance.get_used_cells():
		var cell = Globals.world_instance.get_cellv(location)

		if cell == layer && randi() % 10 == 0:
			var val = randi() % type_count
			self.set_cellv(location, val)

