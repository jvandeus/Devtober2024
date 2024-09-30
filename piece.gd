class_name Piece

enum Type { UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT, FULL }

var type: Type
var velocity: Vector2i

func _init(t := Type.UP_LEFT, v := Vector2i(0, 0)):
	type = t
	velocity = v

static func rand() -> Piece:
	var random_type = Type.values()[randi_range(0, Type.size() - 1)]
	return Piece.new(random_type)

func can_merge_with(other: Piece) -> bool:
	if other == null:
		return false
	return \
		type == Type.DOWN_RIGHT and other.type == Type.UP_LEFT or \
		type == Type.DOWN_LEFT and other.type == Type.UP_RIGHT or \
		type == Type.UP_LEFT and other.type == Type.DOWN_RIGHT or \
		type == Type.UP_RIGHT and other.type == Type.DOWN_LEFT

func atlas_coords() -> Vector2i:
	match type:
		Type.UP_LEFT:
			return Vector2i(3, 0)
		Type.UP_RIGHT:
			return Vector2i(4, 0)
		Type.DOWN_LEFT:
			return Vector2i(5, 0)
		Type.DOWN_RIGHT:
			return Vector2i(6, 0)
		Type.FULL:
			return Vector2i(7, 0)
	return Vector2i(0, 0)
