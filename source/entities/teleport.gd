class_name TeleportController extends EntityController


var enabled: bool = false
var switch_timestamp: float = 0.0

# Lifecycle methods
func _init(position: Vector2, options: Dictionary = {}).(position, options) -> void:
	self.tile_index = 15


# Public methods
func handle_collision(entity: EntityController) -> bool:
	if self.enabled && entity is PlayerController:
		self.emit_signal("remove")
		return false

	return true


func update() -> void:
	if self.enabled:
		if self.switch_timestamp <= Time.elapsed_time:
			self.tile_index = 21 if self.tile_index == 22 else 22
			self.switch_timestamp = Time.elapsed_time + 0.2

