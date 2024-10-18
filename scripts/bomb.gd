@tool

class_name Bomb
extends Node2D

const POINT_MULTIPLIER := 2
var size := 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _draw() -> void:
	draw_circle(Vector2(0, 0), size, Color.WHITE, true, -1.0, true)

func add_points(pts: int) -> void:
	size += POINT_MULTIPLIER * pts
	queue_redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
