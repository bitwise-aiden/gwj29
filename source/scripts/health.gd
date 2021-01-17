extends Node2D

onready var health_display = self.get_children()

func _ready() -> void:
	Globals.health_instance = self


func health_changed(health: int) -> void:
	for index in range(self.health_display.size()):
		if index < health:
			self.health_display[index].play("full")
		else:
			self.health_display[index].play("empty")
