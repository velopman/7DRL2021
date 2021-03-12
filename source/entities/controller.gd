class_name EntityController


signal move(from, to)
signal remove()
signal telegraph(from, to)
signal debug(content)


var damage: int = 1
var direction: Vector2 = Vector2.ZERO
var health: int = 1
var health_max: int = 1
var position: Vector2 = Vector2.ZERO
var tile_index: int = 0
var tile_flip: bool = false


# Public methods
func _init(position: Vector2, options: Dictionary = {}) -> void:
	self.damage = options.get('damage', self.damage)
	self.direction = options.get('direction', self.direction)
	self.health_max = options.get('health', self.health_max)
	self.health = self.health_max
	self.position = position


func handle_collision(_entity: EntityController) -> bool:
	return true


func update() -> void:
	pass
