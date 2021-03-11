class_name Dungeon extends Node2D

const ROOM_COUNT = [10, 15, 20, 30, 1] # Amount of rooms

#Used tiles
enum Tile {NW, N, NE, W, F, E, SW, S, SE, T, P, G}


# Var for this level
var level_number = 0
var map = []
var portals = []
var rooms = []
var room_buffer = []
var room_count
var level_size
var walls: Array
var exit: Vector2

# Nodes
onready var tile_map = $TileMap_Level
onready var rooms_script = $Rooms
onready var tile_map_things = $TileMap_Things

# Draws the level
func draw_level():
	rooms.clear()
	tile_map.clear()

	room_count = ROOM_COUNT[level_number]
	level_size = Vector2(room_count * 20, room_count * 24) # Fix this so it's not hard coded
	for x in range(level_size.x):
		map.append([])
		for y in range(level_size.y):
			map[x].append(Tile.G)
			tile_map.set_cell(x, y, Tile.G)

	var free_regions = [Rect2(Vector2(2, 2), level_size - Vector2(4, 4))]
	for i in range(room_count):
		draw_room(free_regions, i == 0)
		if free_regions.empty():
			break

# Draws all the rooms in the level 18x32-room size 24x38 to have 3 clear rows on each side?
func draw_room(free_regions, spawn_player: bool):
	var region = free_regions[randi() % free_regions.size()]

	room_buffer = rooms_script.get_room_tiles()
	var size_x = room_buffer[0].size()
	var size_y = room_buffer.size()

	var start_x = region.position.x
	if region.size.x > size_x:
		start_x += randi() % int(region.size.x - size_x)

	var start_y = region.position.y
	if region.size.y > size_y:
		start_y += randi() % int(region.size.y - size_y)

	var room = Rect2(start_x, start_y, size_x, size_y)
	rooms.append(room)

	# get tile-information from the room_buffer and set the tiles at the right spot.
	for y in range(room_buffer.size()):
		for x in range(room_buffer[y - 1].size()):
			if(room_buffer[y][x] == "NW"):
				tile_map.set_cell(start_x + x, start_y + y, Tile.NW)
			elif(room_buffer[y][x] == "N"):
				tile_map.set_cell(start_x + x, start_y + y, Tile.N)
			elif(room_buffer[y][x] == "NE"):
				tile_map.set_cell(start_x + x, start_y + y, Tile.NE)
			elif(room_buffer[y][x] == "W"):
				tile_map.set_cell(start_x + x, start_y + y, Tile.W)
			elif(room_buffer[y][x] == "F"):
				tile_map.set_cell(start_x + x, start_y + y, Tile.F)
			elif(room_buffer[y][x] == "E"):
				tile_map.set_cell(start_x + x, start_y + y, Tile.E)
			elif(room_buffer[y][x] == "SW"):
				tile_map.set_cell(start_x + x, start_y + y, Tile.SW)
			elif(room_buffer[y][x] == "S"):
				tile_map.set_cell(start_x + x, start_y + y, Tile.S)
			elif(room_buffer[y][x] == "SE"):
				tile_map.set_cell(start_x + x, start_y + y, Tile.SE)
			elif(room_buffer[y][x] == "P"):
				if spawn_player:
					self.emit_signal("spawn_player", Vector2(start_x + x, start_y + y))
				tile_map.set_cell(start_x + x, start_y + y, Tile.F)
				tile_map_things.set_cell(start_x + x, start_y + y, Tile.P)
			elif(room_buffer[y][x] == "M"):
				self.emit_signal("spawn_enemy", Vector2(start_x + x, start_y + y))
				tile_map.set_cell(start_x + x, start_y + y, Tile.F)
			elif(room_buffer[y][x] == 'G'):
				self.emit_signal("spawn_pick_up", Vector2(start_x + x, start_y + y))
				tile_map.set_cell(start_x + x, start_y + y, Tile.F)
			elif(room_buffer[y][x] == "T"):
				tile_map.set_cell(start_x + x, start_y + y, Tile.F)
				tile_map_things.set_cell(start_x + x, start_y + y, Tile.T)
				portals.append(Vector2(start_x + x, start_y + y))
			else:
				# error tile so we can figure out if we missed something
				tile_map.set_cell(start_x + x, start_y + y, Tile.N)

	# split up the remaining free areas
	cut_regions(free_regions, room)

# inspired by https://github.com/Thoughtquake/dungeon-of-recycling/blob/main/Game.gd
# using this just to see if/how it works
func cut_regions(free_regions, region_to_cut):
	var removal_queue = []
	var addition_queue = []

	for region in free_regions:
		if(region.intersects(region_to_cut)):
			removal_queue.append(region)

			var leftover_left = region_to_cut.position.x - region.position.x - 1
			var leftover_right = region.end.x - region_to_cut.end.x - 1
			var leftover_above = region_to_cut.position.y - region.position.y - 1
			var leftover_below = region.end.y - region_to_cut.end.y - 1

			# Check if there is enough room for a new free region around the newly placed room
			if(leftover_left >= room_buffer[1].size()):
				addition_queue.append(Rect2(region.position, Vector2(leftover_left, region.size.y)))
			if(leftover_right >= room_buffer[1].size()):
				addition_queue.append(Rect2(Vector2(region_to_cut.end.x + 1, region.position.y), Vector2(leftover_right, region.size.y)))
			if(leftover_above >= room_buffer[0].size()):
				addition_queue.append(Rect2(region.position, Vector2(region.size.x, leftover_above)))
			if(leftover_below >= room_buffer[0].size()):
				addition_queue.append(Rect2(Vector2(region.position.x, region_to_cut.end.y + 1), Vector2(region.size.x, leftover_below)))

	for region in removal_queue:
		free_regions.erase(region)

	for region in addition_queue:
		free_regions.append(region)

# Called when the node enters the scene tree for the first time.
func initialize():
	draw_level()
	populate_traversable()

	self.emit_signal("load_complete")


signal load_complete()
signal spawn_enemy(position)
signal spawn_pick_up(position)
signal spawn_player(position)

onready var traversable: TileMap = $traversable

func populate_traversable() -> void:
	for tile in self.tile_map.get_used_cells_by_id(4):
		self.traversable.set_cellv(tile, 0)


func get_traversable() -> TileMap:
	return self.traversable


func get_room_for_entity(entity: EntityController) -> Rect2:
	if !entity:
		return rooms.front()

	for room in rooms:
		if room.has_point(entity.position):
			return room

	return Rect2(0.0, 0.0, 0.0, 0.0)

