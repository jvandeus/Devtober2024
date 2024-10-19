@tool

class_name Bomb
extends Node2D

const POINT_MULTIPLIER := 2
var size := 10
var damage := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _draw() -> void:
	if is_too_weak_to_send():
		return
	draw_circle(Vector2(0, 0), size, Color.WHITE, true, -1.0, true)

func add_points(pts: int) -> void:
	size += POINT_MULTIPLIER * pts
	damage += pts
	queue_redraw()
	
func get_damage() -> int:
	return damage

func is_too_weak_to_send() -> bool:
	return damage <= 4

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
