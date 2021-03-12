class_name ProjectileController extends EntityController


func _init(position: Vector2, options: Dictionary = {}).(position, options) -> void:
	self.tile_index = 20


func handle_collision(entity: EntityController) -> bool:
	return false


func update() -> void:
	var from: Vector2 = self.position
	self.position += self.direction

	self.emit_signal("move", from, self.position)
