class_name PlayerController extends EntityController

signal state_change(health, damage)


const INPUT_MAP = {
	"up": Vector2.UP,
	"down": Vector2.DOWN,
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT,
}

const TILE_MAP = {
	"up": 14,
	"down": 13,
	"left": 12,
	"right": 12
}


# Lifecycle methods
func _init(position: Vector2, options: Dictionary = {}).(position, options) -> void:
	self.health = 3
	self.tile_index = 12


# Public methods
func hurt():
	self.health -= 1
	self.emit_signal("state_change", self.health, self.damage)

	if self.health <= 0:
		self.emit_signal("remove")

func pick_up(type: int) -> void:
	match type:
		PickUp.Type.health:
			self.health += 1
		PickUp.Type.damage:
			self.damage += 1

	self.emit_signal("state_change", self.health, self.damage)


func owns_tile(tile: int) -> bool:
	return tile in [12, 13, 14]


func update() -> void:
	for input in self.INPUT_MAP.keys():
		if Input.is_action_just_pressed(input):
			var from = self.position
			self.direction = self.INPUT_MAP[input]
			self.tile_index = self.TILE_MAP[input]
			self.tile_flip = input == "left"
			self.position += self.direction

			self.emit_signal("move", from, self.position)
			break


	if self.damage && Input.is_action_just_pressed("attack"):
		self.damage -= 1
		self.emit_signal("attack")
		self.emit_signal("state_change", self.health, self.damage)
