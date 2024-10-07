class_name PieceUR
extends SinglePiece

func can_merge(other: SinglePiece) -> bool:
	return other is PieceDL
func try_deflect(other: SinglePiece) -> Deflect:
	return Deflect.NONE
