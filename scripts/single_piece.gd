class_name SinglePiece

extends Node2D

enum Type { UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT, FULL }

@onready var raycast_velocity = $RayCastVelocity
@onready var raycast_down = $RayCastDown
@onready var raycast_left = $RayCastLeft
@onready var raycast_right = $RayCastRight
@onready var raycast_up = $RayCastUp
@onready var sprite = $AnimatedSprite2D
@onready var scene_PieceFull = preload("res://scenes/piece_full.tscn")
@onready var shape: Path2D = $shape
@onready var fill: Polygon2D = $fill
@onready var line: Line2D = $line


var type: Type
@export var velocity := Vector2i(0, 1)
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

func _draw() -> void:
#	link the line and fill with the baked points from the path.
	if shape == null or fill == null or line == null:
		return
	var points = shape.curve.get_baked_points()
	fill.polygon = points
	line.points = points
#	shift the color of the line to a lighter version of the polygon color
	line.default_color = fill.color.lightened(0.7)

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
	add_sibling(new_piece)
	new_piece.transform = transform
	queue_free()

func find_adj_like_pieces(visited := {}) -> Array:
	visited[hash(self)] = true
	var result = [self]
	for raycast in [raycast_up, raycast_down, raycast_left, raycast_right]:
		var collider = raycast.get_collider()
		if collider is SinglePiece and type == collider.type and !visited.has(hash(collider)):
			result.append_array(collider.find_adj_like_pieces(visited))
	return result


func update() -> bool:
	raycast_velocity.target_position = velocity * TILE_SIZE
	var collider = raycast_velocity.get_collider()
	if not collider:
		position += Vector2(TILE_SIZE * velocity)
		return true
	
	
	if collider is SinglePiece:
		if collider.can_merge(type):
			collider.become_full()
			queue_free()
			return true
		
		var deflect_result = collider.try_deflect(type)
		match deflect_result:
			-1:
				position.y += TILE_SIZE
				position.x -= TILE_SIZE
				velocity = Vector2i(-1, 0)
				return true
			1:
				position.y += TILE_SIZE
				position.x += TILE_SIZE
				velocity = Vector2i(1, 0)
				return true
	
	# At this point, the piece has exhausted all options, so it cannot move.
	velocity = Vector2i(0, 1)
	# draw polygons again
	queue_redraw()
	return false
