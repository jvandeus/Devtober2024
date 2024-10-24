extends Node2D

var timer: SceneTreeTimer
@onready var animator: AnimatedSprite2D = $CharMask/AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animator.play("idle")

func hurt() -> void:
	animator.play("hurt")
	timer = get_tree().create_timer(1)
	await timer.timeout
	idle()
	
func attack() -> void:
	animator.play("attack")
	
func idle() -> void:
	animator.play("idle")

func win() -> void:
	animator.play("victory")
	
func lose() -> void:
	if timer: timer.timeout.disconnect(idle)
	animator.play("defeat")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
