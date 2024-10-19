@tool

extends Node2D

@export var color := Color.YELLOW
@export var width := 400
@export var height := 50
@export var max_value := 60
@export var initial_value := 0
var value: int
signal on_full
signal on_empty

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value = initial_value
	
func _draw() -> void:
	draw_rect(Rect2(0, 0, float(value) / max_value * width, height), color, true, -1.0, true)

func decrement(amount: int) -> void:
	value = max(0, value - amount)
	if value == 0:
		on_empty.emit()
	
func increment(amount: int) -> void:
	value = min(max_value, value + amount)
	if value == max_value:
		var color_tween = create_tween()
		var position_tween = create_tween()
		color_tween.tween_property($".", "color", Color.WHITE, 1)
		color_tween.tween_property($".", "color", Color.RED, 0)
		position_tween.tween_property($".", "position", transform.origin + Vector2(0, 10), 1)
		position_tween.tween_property($".", "position", transform.origin, 0)
		await color_tween.finished
		await position_tween.finished
		on_full.emit()

func clear() -> void:
	value = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
