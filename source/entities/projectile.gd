class_name ProjectileController extends EntityController


var speed: int = 1


func _init(position: Vector2, options: Dictionary = {}).(position, options) -> void:
	self.speed = options.get('speed', self.speed)
	self.tile_index = 20


func update() -> void:
	var from: Vector2 = self.position
	self.position += self.direction * self.speed

	self.emit_signal("move", from, self.position)
