class_name Piece
extends Node2D

enum Kind { GREEN, RED, BLUE, YELLOW, GARBAGE }

@onready var apparent_transform = $ApparentTransform
@onready var ray_up = $Up
@onready var ray_down = $Down
@onready var ray_left = $Left
@onready var ray_right = $Right
@onready var Shape = $Shape
@onready var change_sfx = $ChangeSFX

@export var kind: Kind
@export var cell_size := 64

const FALL_SPEED := 1000.0 # pixels per second
const KINDS = [Kind.GREEN, Kind.RED, Kind.BLUE, Kind.YELLOW]

# Called when the node enters the scene tree for the first time.
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

# get immmediately adjacent pieces
func get_adj_pieces() -> Array:
	var adj_pieces = []
	for ray in [ray_down, ray_up, ray_left, ray_right]:
		var collider = ray.get_collider()
		if collider is Piece:
			adj_pieces.append(ray.get_collider())
	return adj_pieces

# recursive depth-first search to find the contiguous cluster of same-kind pieces touching this one
func get_cluster(visited := {}) -> Array:
	visited[hash(self)] = true
	var result = [self]
	for piece in get_adj_pieces():
		if piece.kind == kind and !visited.has(hash(piece)):
			result.append_array(piece.get_cluster(visited))
	return result

func update_children() -> void:
	for ray in [ray_down, ray_up, ray_left, ray_right]:
		if ray: ray.target_position.x = cell_size
	if Shape: Shape.scale = Vector2(cell_size / 64.0, cell_size / 64.0)

func set_kind(k: Kind) -> void:
	change_sfx.play()
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.play("shine")
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.visible = false
	kind = k

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_children()
