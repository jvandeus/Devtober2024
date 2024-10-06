class_name PieceDR
extends SinglePiece

func can_merge(other: SinglePiece) -> bool:
	return other is PieceUL
func try_deflect(other: SinglePiece) -> Deflect:
	return Deflect.LEFT
