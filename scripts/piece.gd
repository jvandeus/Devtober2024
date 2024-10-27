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

const FALL_SPEED := 16.0
const KINDS = [Kind.GREEN, Kind.RED, Kind.BLUE, Kind.YELLOW]

signal start_animation_fall
signal done_animation_fall
signal start_animation_clear
signal done_animation_clear

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

func _draw() -> void:
	pass

func fall_to(y: int) -> void:
	start_animation_fall.emit()
	var diff = transform.origin.y - y
	transform.origin.y = y
	apparent_transform.transform.origin.y = diff

func animate(delta: float) -> void:
	var offset: Vector2 = apparent_transform.transform.origin
	if offset.distance_to(Vector2(0, 0)) < FALL_SPEED:
		apparent_transform.transform.origin = Vector2(0, 0)
		done_animation_fall.emit()
	apparent_transform.translate(offset.normalized() * -FALL_SPEED)

func is_animating() -> bool:
	return apparent_transform.transform.origin != Vector2(0, 0)

func clear() -> void:
	start_animation_clear.emit()
	for i in 20:
		play_clear_animation()
		await get_tree().create_timer(0.04).timeout
	done_animation_clear.emit()

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
	animate(delta)
	queue_redraw()
