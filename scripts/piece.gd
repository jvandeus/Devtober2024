class_name Piece
extends Node2D

enum Kind { GREEN, RED, BLUE, YELLOW, GARBAGE }

@onready var change_sfx = $ChangeSFX

@export var kind: Kind
@export var cell_size := 64

const FALL_SPEED := 1000.0 # pixels per second
const KINDS = [Kind.GREEN, Kind.RED, Kind.BLUE, Kind.YELLOW]

func _ready() -> void:
	idle()
	
func idle() -> void:
	match kind:
		Kind.GREEN: $Sprite.play("idle_green")
		Kind.RED: $Sprite.play("idle_red")
		Kind.YELLOW: $Sprite.play("idle_yellow")
		Kind.BLUE: $Sprite.play("idle_blue")
		Kind.GARBAGE: $Sprite.play("idle_garbage")

func play_clear_animation() -> void:
	match kind:
		Kind.GREEN: $Sprite.play("clear_green")
		Kind.RED: $Sprite.play("clear_red")
		Kind.YELLOW: $Sprite.play("clear_yellow")
		Kind.BLUE: $Sprite.play("clear_blue")
		Kind.GARBAGE: $Sprite.play("clear_garbage")

func randomize() -> void:
	kind = KINDS.pick_random()

func fall_to(y: int) -> Tween:
	var distance = abs(position.y - y)
	var target = position
	target.y = y
	var tween = create_tween()
	tween.tween_property(self, "position", target, distance / FALL_SPEED)
	return tween

func set_kind(k: Kind) -> void:
	change_sfx.play()
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.play("shine")
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.visible = false
	kind = k
