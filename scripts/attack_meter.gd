extends Node2D

@export var max_value := 20
@export var initial_value := 0
var value: float = 0
const COLOR_CHARGING: Color = Color("F5E461")
const COLOR_READY: Color = Color.WHITE
const SHAKE_DURATION := 0.05
const SHAKE_AMPLITUDE := 4
var shake_timer: SceneTreeTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value = initial_value

func increment(amount : int) -> void:
	value = min(max_value, value + amount)
	if is_full():
		$container/mask/rect.color = COLOR_READY
		shake()

func clear() -> void:
	value = 0
	$container.position = Vector2(0, 0)
	$container/mask/rect.color = COLOR_CHARGING
	stop_shaking()

func is_full() -> bool:
	return value == max_value

func shake() -> void:
	if $container.position.x < 0:
		$container.position.x = SHAKE_AMPLITUDE
	else:
		$container.position.x = -SHAKE_AMPLITUDE
	shake_timer = get_tree().create_timer(SHAKE_DURATION)
	shake_timer.timeout.connect(shake)

func stop_shaking() -> void:
	if shake_timer:
		shake_timer.timeout.disconnect(shake)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$container/mask/rect.scale.x = value / max_value
