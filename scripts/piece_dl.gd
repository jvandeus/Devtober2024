class_name PieceDL
extends SinglePiece

func can_merge(other: SinglePiece) -> bool:
	return other is PieceUR
func try_deflect(other: SinglePiece) -> Deflect:
	if raycast_right.is_colliding():
		return Deflect.NONE
	return Deflect.RIGHT
