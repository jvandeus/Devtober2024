class_name PieceDR
extends SinglePiece

func can_merge(other: SinglePiece) -> bool:
	return other is PieceUL
func try_deflect(other: SinglePiece) -> Deflect:
	if raycast_left.is_colliding():
		return Deflect.NONE
	return Deflect.LEFT
