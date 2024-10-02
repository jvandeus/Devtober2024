class_name MultiPiece

extends Node2D

var offset: Vector2i:
	set(value):
		offset = value
		queue_redraw()
var primary: Piece.Type:
	set(value):
		primary = value
		queue_redraw()
var secondary: Piece.Type:
	set(value):
		secondary = value
		queue_redraw()
var origin: Vector2:
	set(value):
		origin = value
		queue_redraw()

func _init(p: Piece.Type, s: Piece.Type, offs: Vector2i, orig := Vector2(0, 0)):
	primary = p
	secondary = s
	offset = offs
	origin = orig

func _draw():
	draw_rect(Rect2(origin.x + 1.5, origin.y + 1.5, 13, 13), Color.GREEN, false, 1.0)
	draw_rect(Rect2(origin.x + offset.x * 16 + 1.5, origin.y + offset.y * 16 + 1.5, 13, 13), Color.CORNFLOWER_BLUE, false, 1.0)
	var p1 = origin + Vector2(8, 8)
	var p2 = p1 + Vector2(offset * 16)
	draw_line(p1, p2, Color.HOT_PINK, 1.0)

func rotate_whole(dir: Piece.RotationDirection):
	primary = Piece.rotate_type(primary, dir)
	secondary = Piece.rotate_type(secondary, dir)
	offset = rotate_offset(offset, dir)

func rotate_piecewise(dir: Piece.RotationDirection):
	offset = rotate_offset(offset, dir)

# private helper function
static func rotate_offset(offset: Vector2i, dir: Piece.RotationDirection) -> Vector2i:
	match dir:
		Piece.RotationDirection.CLOCKWISE:
			match offset:
				Vector2i(0, -1):
					return Vector2i(1, 0)
				Vector2i(1, 0):
					return Vector2i(0, 1)
				Vector2i(0, 1):
					return Vector2i(-1, 0)
				Vector2i(-1, 0):
					return Vector2i(0, -1)
		Piece.RotationDirection.COUNTERCLOCKWISE:
			match offset:
				Vector2i(0, -1):
					return Vector2i(-1, 0)
				Vector2i(-1, 0):
					return Vector2i(0, 1)
				Vector2i(0, 1):
					return Vector2i(1, 0)
				Vector2i(1, 0):
					return Vector2i(0, -1)
	assert(false) # should not reach this point
	return Vector2i(0, 0)
