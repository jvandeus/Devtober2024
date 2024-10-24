extends Node2D

signal on_empty
@export var max_value := 100
@export var initial_value := 0
var value: float = 0
const FOLLOW_SPEED := 0.5 # scale per second

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value = initial_value

func decrement(amount : int) -> void:
	value = max(0, value - amount)
	if value == 0:
		on_empty.emit()

func is_empty() -> bool:
	return value == 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$mask/rect.scale.x = value / max_value
	
	var target = $mask/rect.scale.x
	var diff = $mask/rect.scale.x - $mask/rect_follow.scale.x
	if diff == 0:
		pass
	if diff < 0:
		$mask/rect_follow.scale.x = max(target, $mask/rect_follow.scale.x - FOLLOW_SPEED * delta)
	if diff > 0:
		$mask/rect_follow.scale.x = target
