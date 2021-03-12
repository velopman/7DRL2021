class_name PickUpController extends EntityController


var type: int = PickUp.Type.MAX


# Lifecycle methods
func _init(position: Vector2, options: Dictionary = {}).(position, options) -> void:
	self.type = randi() % PickUp.Type.MAX
	self.tile_index = 18 + self.type


# Public methods
func handle_collision(entity: EntityController) -> bool:
	if entity is PlayerController:
		entity.pick_up(self.type)
		self.emit_signal("remove")
		return false

	return true
