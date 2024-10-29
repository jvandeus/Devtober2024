class_name Piece
extends Node2D

enum Kind { GREEN, RED, BLUE, YELLOW, GARBAGE }

@onready var change_sfx = $ChangeSFX

@export var kind: Kind
@export var cell_size := 64

const DEFAULT_CELL_SIZE = 80
const FALL_SPEED := 1000.0 # pixels per second
const KINDS = [Kind.GREEN, Kind.RED, Kind.BLUE, Kind.YELLOW]

func _ready() -> void:
	idle()
	
func idle() -> void:
	match kind:
		Kind.GREEN: play("idle_green")
		Kind.RED: play("idle_red")
		Kind.YELLOW: play("idle_yellow")
		Kind.BLUE: play("idle_blue")
		Kind.GARBAGE: play("idle_garbage")

func play_clear_animation() -> void:
	match kind:
		Kind.GREEN: play("clear_green")
		Kind.RED: play("clear_red")
		Kind.YELLOW: play("clear_yellow")
		Kind.BLUE: play("clear_blue")
		Kind.GARBAGE: play("clear_garbage")

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
	
func play(animation: String) -> void:
	$Sprite.play(animation)
	$Shadow.play(animation)

func _process(delta: float) -> void:
	var scale = 0.5 * float(cell_size) / DEFAULT_CELL_SIZE
	$Sprite.scale = Vector2(scale, scale)
	# shadow is always a little left and down, independent of local transform
	$Shadow.global_transform = get_global_transform().translated(Vector2(-16, 16))
	$Shadow.scale = Vector2(scale, scale)
