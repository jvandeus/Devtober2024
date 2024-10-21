@tool

extends Node2D

@export var base_color := Color.YELLOW
@export var width := 400
@export var height := 50
@export var max_value := 60
@export var initial_value := 0
var value: int
var color: Color
var color_tween: Tween
signal on_empty

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value = initial_value
	color = base_color
	
func _draw() -> void:
	draw_rect(Rect2(0, 0, float(value) / max_value * width, height), color, true, -1.0, true)

func decrement(amount: int) -> void:
	value = max(0, value - amount)
	if value == 0:
		on_empty.emit()
	
func increment(amount: int) -> void:
	value = min(max_value, value + amount)
	if value == max_value:
		color_tween = create_tween()
		color_tween.tween_property($".", "color", Color.WHITE, 1)

func is_full() -> bool:
	return value == max_value

func is_empty() -> bool:
	return value == 0

func clear() -> void:
	color_tween.stop()
	color_tween = null
	color = base_color
	value = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
