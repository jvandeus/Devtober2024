@tool

extends Node2D

@export var width := 400
@export var height := 50
@export var max_value := 60:
	set(v):
		max_value = v
		value = v
var value: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value = max_value
	
func _draw() -> void:
	draw_rect(Rect2(0, 0, float(value) / max_value * width, height), Color.YELLOW, true, -1.0, true)

func decrement(amount: int) -> void:
	value = max(0, value - amount)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
