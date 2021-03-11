class_name PlayerController extends EntityController


signal attack(direction)


const INPUT_MAP = {
	"up": Vector2.UP,
	"down": Vector2.DOWN,
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT,
}


# Lifecycle methods
func _init(position: Vector2, options: Dictionary = {}).(position, options) -> void:
	self.tile_index = 10


# Public methods
func pick_up(type: int) -> void:
	match type:
		PickUp.Type.health:
			self.health_max += 1
			self.health += 1
		PickUp.Type.potion:
			self.health = min(self.health + 1, self.health_max)
		PickUp.Type.damage:
			self.damage += 1


func update() -> void:
	for input in self.INPUT_MAP.keys():
		if Input.is_action_just_pressed(input):
			var from = self.position
			self.direction = self.INPUT_MAP[input]
			self.position += self.direction

			self.emit_signal("move", from, self.position)
			break

	if Input.is_action_just_pressed("attack"):
		self.emit_signal("attack")
