extends TileMap


func state_change(health: int, damage: int) -> void:
	self.clear()

	for i in health:
		self.set_cell(-9 + i, -5, 0)

	for i in damage:
		self.set_cell(-9 + i, -4, 1)
