class_name WorldInterface


var __entities: Array = []
var __ray: RayCast2D = null
var __world: TileMap = null


# Lifecycle methods
func _init(ray: RayCast2D, world: TileMap, entities: Array) -> void:
	self.__entities = entities
	self.__ray = ray
	self.__world = world


# Public methods
func has_line_of_sight(from: EntityController, to: EntityController) -> bool:
	var position_from: Vector2 = w2s(from.position)
	var position_to: Vector2 = w2s(to.position)
	var direction: Vector2 = position_from - position_to

	self.__ray.position = position_from
	self.__ray.cast_to = direction

	return !self.__ray.is_colliding()


func can_traverse(entity: EntityController, position: Vector2) -> bool:
	if self.__world.get_cellv(position) == TileMap.INVALID_CELL:
		return false

	for other_entity in self.__entities:
		if entity == other_entity:
			continue

		if other_entity.position != position:
			continue

		return !other_entity.handle_collision(entity)

	return true


# s2w: Converts the Vector2 from screen space to world space
func s2w(value: Vector2) -> Vector2:
	return (value - Vector2(8.0, 8.0)) / 16.0


# w2s: Converts the Vector2 from world space to screen space
func w2s(value: Vector2) -> Vector2:
	return value * 16.0 + Vector2(8.0, 8.0)
