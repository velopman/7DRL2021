class_name DamageController extends EntityController


var turns_remaining: int = 2


# Lifecycle methods
func _init(position: Vector2, options: Dictionary = {}).(position, options) -> void:
	self.tile_index = 23


# Public methods
func handle_collision(entity: EntityController) -> bool:
	return false


func update() -> void:
	print(self.turns_remaining)
	self.turns_remaining -= 1
	if self.turns_remaining == 0:
		self.emit_signal("remove")
