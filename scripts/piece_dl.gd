class_name PieceDL
extends SinglePiece

func can_merge(other: SinglePiece) -> bool:
	return other is PieceUR
func try_deflect(other: SinglePiece) -> Deflect:
	return Deflect.RIGHT
