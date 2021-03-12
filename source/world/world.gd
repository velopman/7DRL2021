class_name WorldController extends Node2D


const DAMAGE_ENEMY = 1
const DAMAGE_PLAYER = 1
const HEALTH_ENEMY = 1
const HEALTH_PLAYER = 3

onready var __camera: Camera2D = $camera
onready var __dungeon: Dungeon = $dungeon
onready var __entities_map: TileMap = $entities
onready var __ray: RayCast2D = $line_of_sight

var __attacks: Array = []
var __can_update: bool = false
var __enemies: Array = []
var __entities: Array = []
var __player: PlayerController = null
var __world_interface: WorldInterface = null


# Lifecycle method
func _ready() -> void:
	randomize()

	self.__dungeon.connect("load_complete", self, "__dungeon_complete")
	self.__dungeon.connect("spawn_enemy", self, "__spawn_enemy")
	self.__dungeon.connect("spawn_pick_up", self, "__spawn_pick_up")
	self.__dungeon.connect("spawn_player", self, "__spawn_player")

	self.__dungeon.initialize()


func _process(_delta: float) -> void:
	if !self.__can_update || !self.__player:
		return

	self.__player.update()


# Private methods
func __attack_entity(entity: EntityController) -> void:
	var options: Dictionary = {
		'damage': entity.damage,
		'direction': entity.direction,
	}

	var spawn_position: Vector2 = entity.position
	var projectile: ProjectileController = ProjectileController.new(spawn_position, options)
	self.__connect_entity(projectile)

	self.__entities.append(projectile)
	self.__attacks.append(projectile)

	if entity is PlayerController:
		self.__move_player(entity.position, entity.position, entity)


func __center_camera_on_entity(entity: EntityController, pan: bool = false) -> void:
	var room: Rect2 = self.__dungeon.get_room_for_entity(entity)
	if room.size.length() == 0:
		self.__center_camera_on_position(entity.position, pan)
	else:
		self.__center_camera_on_room(room, pan)


func __center_camera_on_position(position: Vector2, pan: bool = false) -> void:
	self.__camera.offset = self.__world_interface.w2s(position)


func __center_camera_on_room(room: Rect2, pan: bool = false) -> void:
	if room.size.length() == 0:
		return

	var room_center = room.position + room.size * 0.5
	self.__center_camera_on_position(room_center, pan)


func __connect_entity(entity: EntityController) -> void:
	if entity is PlayerController:
		entity.connect("move", self, "__move_player", [entity])
		entity.connect("attack", self, "__attack_entity", [entity])
	else:
		entity.connect("move", self, "__move_entity", [entity])

	entity.connect("remove", self, "__remove_entity", [entity])


func __dungeon_complete() -> void:
	self.__world_interface = WorldInterface.new(
		self.__ray,
		self.__dungeon.get_traversable(),
		self.__entities
	)

	self.__world_interface.connect("collision_detected", self, "__handle_collision")

	self.__can_update = true

	self.__redraw()
	self.__center_camera_on_entity(self.__player, false)


func __get_entity_name(entity: EntityController) -> String:
	if entity is EnemyController:
		return Entity.ENEMY

	if entity is PickUpController:
		return Entity.PICK_UP

	if entity is PlayerController:
		return Entity.PLAYER

	if entity is ProjectileController:
		return Entity.PROJECTILE

	return Entity.NONE


func __handle_collision(entity: EntityController, other: EntityController) -> void:
	var entities_by_name: Array = [
		self.__get_entity_name(entity),
		self.__get_entity_name(other)
	]
	entities_by_name.sort()

	match entities_by_name:
		[Entity.ENEMY, Entity.PROJECTILE]:
			self.__remove_entity(entity)
			self.__remove_entity(other)
		[Entity.NONE, Entity.PROJECTILE]:
			self.__remove_entity(entity)


func __move_entity(from: Vector2, to: Vector2, entity: EntityController) -> void:
	if from == to:
		return

	if !self.__world_interface.can_traverse(entity, to):
		entity.position = from


func __move_player(from: Vector2, to: Vector2, entity: EntityController) -> void:
	self.__move_entity(from, to, entity)

	for attack in self.__attacks:
		attack.update()

	self.__center_camera_on_entity(entity)

	for enemy in self.__enemies:
		enemy.update()
		enemy.telegraph(entity, self.__world_interface)

	self.__redraw()


func __redraw() -> void:
	self.__entities_map.clear()

	for entity in self.__entities:
		self.__entities_map.set_cellv(entity.position, entity.tile_index, entity.tile_flip)


func __remove_entity(entity: EntityController) -> void:
	self.__entities.erase(entity)

	if entity is EnemyController:
		self.__enemies.erase(entity)
	elif entity is ProjectileController:
		self.__attacks.erase(entity)


func __spawn_enemy(position: Vector2) -> void:
	var options: Dictionary = {
		'damage': self.DAMAGE_ENEMY,
		'health': self.HEALTH_ENEMY
	}
	var enemy: EnemyController = EnemyController.new(position, options)
	self.__connect_entity(enemy)

	self.__entities.append(enemy)
	self.__enemies.append(enemy)


func __spawn_pick_up(position: Vector2) -> void:
	var pick_up: PickUpController = PickUpController.new(position)
	self.__connect_entity(pick_up)

	self.__entities.append(pick_up)


func __spawn_player(position: Vector2) -> void:
	var options: Dictionary = {
		'damage': self.DAMAGE_PLAYER,
		'health': self.HEALTH_PLAYER
	}
	self.__player = PlayerController.new(position, options)
	self.__connect_entity(self.__player)

	self.__entities.append(self.__player)
