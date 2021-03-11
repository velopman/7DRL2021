extends Node

onready var room_one_file = 'res://assets/rooms/room_one.txt'
onready var room_two_file = 'res://assets/rooms/room_two.txt'

func get_room_tiles():
	var random = randi()
	if(random % 2 == 0):
		return load_room(room_one_file)
	else:
		return load_room(room_two_file)

func load_room(file):
	var f = File.new()
	if !f.file_exists(file):
		return [['P', 'F'], ['F', 'F']]

	f.open(file, File.READ)

	var room_array = []

	while not f.eof_reached():
		var row = f.get_line()
		room_array.append(row.rsplit(" "))
	f.close()

	return room_array


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
