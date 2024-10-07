class_name PieceUL
extends SinglePiece

func can_merge(other: SinglePiece) -> bool:
	return other is PieceDR
func try_deflect(other: SinglePiece) -> Deflect:
	return Deflect.NONE
