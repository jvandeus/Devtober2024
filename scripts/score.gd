extends Node

var score = 0
var cumulative_points: int = 0
var combo: int = 0
@onready var score_board: FlipBoard = $FlipBoard

func _on_pieces_cleared(num_pieces: int, combo: int):
	var points = num_pieces * combo
	self.score += points
	score_board.text = score
	
func _ready() -> void:
	score_board.text = score
