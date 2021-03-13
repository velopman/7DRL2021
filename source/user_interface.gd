extends TileMap

var score: int = 0

onready var __score_text: Label = $score


func state_change(health: int, damage: int) -> void:
	self.clear()

	for i in health:
		self.set_cell(-9 + i, -4, 0)

	for i in damage:
		self.set_cell(-9 + i, -3, 1)


func increment_score() -> void:
	self.score += 1
	self.__score_text.text = "score: %d" % self.score
