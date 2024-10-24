extends Node2D

@export var max_value := 20
@export var initial_value := 0
var value: float = 0
const COLOR_CHARGING: Color = Color("F5E461")
const COLOR_READY: Color = Color.WHITE
const SHAKE_DURATION := 0.1
const SHAKE_AMPLITUDE := 10
var tween_shake: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value = initial_value

func increment(amount : int) -> void:
	value = min(max_value, value + amount)
	if value == max_value:
		start_shaking()

func clear() -> void:
	value = 0
	$container.position = Vector2(0, 0)

func is_full() -> bool:
	return value == max_value

func start_shaking() -> void:
	tween_shake = create_tween()
	tween_shake\
		.tween_property($container, "position", Vector2(0, SHAKE_AMPLITUDE).rotated(randf() * 2 * PI), SHAKE_DURATION)\
		.set_custom_interpolator(func(v): return 1.0)
	tween_shake.finished.connect(start_shaking)
	
func stop_shaking() -> void:
	if tween_shake: tween_shake.finished.disconnect(start_shaking)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$container/mask/rect.scale.x = value / max_value
	if is_full():
		$container/mask/rect.color = COLOR_READY
	else:
		$container/mask/rect.color = COLOR_CHARGING
		stop_shaking()
