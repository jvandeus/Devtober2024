class_name SinglePiece

extends Node2D

enum Type { UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT, FULL }

@onready var raycast = $RayCast2D
@onready var sprite = $AnimatedSprite2D
@onready var scene_PieceFull = load("res://scenes/piece_full.tscn")

var type: Type
@export var velocity := Vector2i(0, 1)
var time_elapsed: float
const UPDATE_TIME = 0.1
const TILE_SIZE = 64

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match sprite.animation:
		"up_left":
			type = Type.UP_LEFT
		"up_right":
			type = Type.UP_RIGHT
		"down_left":
			type = Type.DOWN_LEFT
		"down_right":
			type = Type.DOWN_RIGHT
		"full":
			type = Type.FULL

func can_merge(other: Type):
	var a = type
	var b = other
	if b < a:
		var tmp = a
		a = b
		b = tmp
	return a == Type.UP_LEFT and b == Type.DOWN_RIGHT or \
		   a == Type.UP_RIGHT and b == Type.DOWN_LEFT

func try_deflect(other: Type) -> int:
	if type == Type.UP_LEFT or type == Type.UP_RIGHT or type == Type.FULL:
		return 0
	if type == Type.DOWN_LEFT and other != Type.UP_RIGHT:
		return 1
	if type == Type.DOWN_RIGHT and other != Type.UP_LEFT:
		return -1
	return 0

func become_full():
	var new_piece = scene_PieceFull.instantiate()
	new_piece.transform = transform
	add_sibling(new_piece)
	queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_elapsed += delta
	if time_elapsed < UPDATE_TIME:
		return
	time_elapsed -= UPDATE_TIME
	
	raycast.target_position = velocity * TILE_SIZE
	var collider = raycast.get_collider()
	if not collider:
		position += Vector2(TILE_SIZE * velocity)
		return
	
	
	if collider is SinglePiece:
		if collider.can_merge(type):
			collider.become_full()
			queue_free()
			return
		
		var deflect_result = collider.try_deflect(type)
		match deflect_result:
			-1:
				position.y += TILE_SIZE
				position.x -= TILE_SIZE
				velocity = Vector2i(-1, 0)
				return
			1:
				position.y += TILE_SIZE
				position.x += TILE_SIZE
				velocity = Vector2i(1, 0)
				return
	
	# At this point, the piece has exhausted all options, so it cannot move.
	velocity = Vector2i(0, 1)
