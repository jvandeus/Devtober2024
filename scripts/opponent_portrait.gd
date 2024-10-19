extends Node2D

var timer: SceneTreeTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("idle")

func hurt() -> void:
	$AnimatedSprite2D.play("hurt")
	timer = get_tree().create_timer(1)
	timer.timeout.connect(idle)
	
func idle() -> void:
	$AnimatedSprite2D.play("idle")

func win() -> void:
	timer.timeout.disconnect(idle)
	$AnimatedSprite2D.play("victory")
	
func lose() -> void:
	timer.timeout.disconnect(idle)
	$AnimatedSprite2D.play("defeat")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
