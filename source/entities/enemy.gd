class_name EnemyController extends EntityController

const WANDER: Array = [
	Vector2.UP,
	Vector2.UP,
	Vector2.UP,
	Vector2.DOWN,
	Vector2.DOWN,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.LEFT,
	Vector2.LEFT,
	Vector2.RIGHT,
	Vector2.RIGHT,
	Vector2.RIGHT
]

var attacking: int = 0
var wander_index: int = 0


# Lifecycle methods
func _init(position: Vector2, options: Dictionary = {}).(position, options) -> void:
	self.tile_index = 16
	self.wander_index = randi() % self.WANDER.size()


# Public methods
func handle_collision(entity: EntityController) -> bool:
	return true


func telegraph(player: PlayerController, world: WorldInterface) -> void:
	var distance_to_player: float = self.position.distance_to(player.position)
	if distance_to_player <= 1.5:
		self.attacking = 5
		return

	if distance_to_player < 5 && world.has_line_of_sight(self, player):
		var direction_to_player: Vector2 = self.position.direction_to(player.position)
		if abs(direction_to_player.x) <= abs(direction_to_player.y):
			direction_to_player.x = 0.0
		else:
			direction_to_player.y = 0.0

		self.direction = direction_to_player
	else:
		self.wander_index = (self.wander_index + 1) % self.WANDER.size()
		self.direction = self.WANDER[self.wander_index]


func update() -> void:
	match self.attacking:
		0:
			var from = self.position
			self.position += self.direction

			self.emit_signal("move", from, self.position)
		3:
			# handle actually attacking
			continue
		_:
			self.attacking = max(self.attacking - 1, 0)
