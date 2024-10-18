extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("idle")

func hurt() -> void:
	$AnimatedSprite2D.play("hurt")
	await get_tree().create_timer(1).timeout
	$AnimatedSprite2D.play("idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
