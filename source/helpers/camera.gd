extends Camera2D


onready var __fade: ColorRect = $fade
onready var __stories: Array = $story.get_children()
onready var __user_interface: TileMap = $user_interface

var __next_story: int = 0

# Lifecycle methods
func _ready() -> void:
	self.make_current()
	self.__fade.visible = true

# Public methods
func create_camera_shake(intensity: float, duration: float) -> Task.CameraShake:
	return Task.CameraShake.new(self, intensity, duration)


func create_fade_in(duration: float, color: Color = Color.black) -> Task.Lerp:
	var transparent = color
	transparent.a = 0.0

	return Task.Lerp.new(color, transparent, duration, funcref($fade,
		"set_frame_color"))


func create_fade_out(duration: float, color: Color = Color.black) -> Task.Lerp:
	var transparent = color
	transparent.a = 0.0

	return Task.Lerp.new(transparent, color, duration, funcref($fade,
		"set_frame_color"))


func show_next_story(fade_out: bool = true) -> void:
	TaskManager.add_queue("screen", Task.RunFunc.new(
		funcref(self.__user_interface, "set_visible"),
		[false]
	))
	if fade_out:
		TaskManager.add_queue("screen", self.create_fade_out(0.5))
	TaskManager.add_queue("screen", Task.RunFunc.new(
		funcref(self.__stories[self.__next_story], "set_visible"),
		[true]
	))

	TaskManager.add_queue("screen", Task.Wait.new(1.0))
	TaskManager.add_queue("screen", Task.Lerp.new(
		Color.white,
		Color(1.0, 1.0, 1.0, 0.0),
		0.5,
		funcref(self.__stories[self.__next_story], "set_modulate")
	))
	TaskManager.add_queue("screen", Task.RunFunc.new(
		funcref(self.__stories[self.__next_story], "set_visible"),
		[false]
	))
	TaskManager.add_queue("screen", self.create_fade_in(0.5))
	TaskManager.add_queue("screen", Task.RunFunc.new(
		funcref(self.__user_interface, "set_visible"),
		[true]
	))
	TaskManager.add_queue("screen", Task.RunFunc.new(
		funcref(self, "set"),
		["__next_story", self.__next_story + 1]
	))
