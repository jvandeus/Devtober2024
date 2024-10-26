extends Node2D

signal on_empty
@export var max_value := 100
@export var initial_value := 0
var value: float = 0
const FOLLOW_SPEED := 0.5 # scale per second
const SHAKE_DURATION := 0.05 # duration of one half oscillation
const SHAKE_ATTACK := 30 # starting amplitude
const SHAKE_DECAY := 0.5 # amplitude reduction
const SHAKE_EPSILON := 0.2 # amplitude below which shake terminates
var shake_amplitude: float
var shake_timer: SceneTreeTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value = initial_value

func decrement(amount : int) -> void:
	value = max(0, value - amount)
	if value == 0:
		on_empty.emit()
	start_shake()

func start_shake():
	shake_amplitude = SHAKE_ATTACK
	continue_shake()

func continue_shake():
	if shake_amplitude <= SHAKE_EPSILON:
		$container.position.y = 0
		return
	if $container.position.y <= 0:
		$container.position.y = shake_amplitude
	else:
		$container.position.y = -shake_amplitude
	shake_amplitude *= SHAKE_DECAY
	get_tree().create_timer(SHAKE_DURATION).timeout.connect(continue_shake)

func is_empty() -> bool:
	return value == 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$container/mask/rect.scale.x = value / max_value
	
	var target = $container/mask/rect.scale.x
	var diff = $container/mask/rect.scale.x - $container/mask/rect_follow.scale.x
	if diff == 0:
		pass
	if diff < 0:
		$container/mask/rect_follow.scale.x = max(target, $container/mask/rect_follow.scale.x - FOLLOW_SPEED * delta)
	if diff > 0:
		$container/mask/rect_follow.scale.x = target
