@tool

class_name Piece
extends Node2D

enum Kind { GREEN, RED, BLUE, YELLOW }

@onready var apparent_transform = $ApparentTransform
@onready var raycast_up = $RayCast_Up
@onready var raycast_down = $RayCast_Down
@onready var raycast_left = $RayCast_Left
@onready var raycast_right = $RayCast_Right

var kind: Kind
var is_visible := true

const FALL_SPEED := 16.0
const KINDS = [Kind.GREEN, Kind.RED, Kind.BLUE, Kind.YELLOW]

signal done_animation_fall
signal done_animation_clear

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	kind = KINDS.pick_random()

func _draw() -> void:
	if not Engine.is_editor_hint():
		draw_line(Vector2(-8, -8), Vector2(8, 8), Color.RED, 2.0)
		draw_line(Vector2(-8, 8), Vector2(8, -8), Color.RED, 2.0)
	var color: Color
	match kind:
		Kind.GREEN: color = Color.GREEN
		Kind.BLUE: color = Color.AQUA
		Kind.RED: color = Color.RED
		Kind.YELLOW: color = Color.YELLOW
	if is_visible:
		draw_circle(apparent_transform.transform.origin, 24, color, false, 2)

func fall_to(y: int) -> void:
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
	for i in 20:
		is_visible = !is_visible
		await get_tree().create_timer(0.05).timeout
	done_animation_clear.emit()
	

# get immmediately adjacent pieces
func get_adj_pieces() -> Array:
	var adj_pieces = []
	for raycast in [raycast_down, raycast_up, raycast_left, raycast_right]:
		var collider = raycast.get_collider()
		if collider is Piece:
			adj_pieces.append(raycast.get_collider())
	return adj_pieces

# recursive depth-first search to find the contiguous cluster of same-kind pieces touching this one
func get_cluster(visited := {}) -> Array:
	visited[hash(self)] = true
	var result = [self]
	for piece in get_adj_pieces():
		if piece.kind == kind and !visited.has(hash(piece)):
			result.append_array(piece.get_cluster(visited))
	return result


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		animate(delta)
	queue_redraw()
