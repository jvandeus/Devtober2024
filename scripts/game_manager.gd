extends Node

var score = 0
var cumulative_points: int = 0
var combo: int = 0
@onready var score_display: Label = $ScoreDisplay
@onready var flip_board: FlipBoard = $FlipBoard
@onready var tia_v: Node3D = $"../TIA-V_MASTER"

func display_points():
	#score_display.text = "Score: " + str(score)
	pass;
