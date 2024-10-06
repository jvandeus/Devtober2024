class_name PieceFull
extends SinglePiece

func can_merge(other: SinglePiece) -> bool:
	return false
func try_deflect(other: SinglePiece) -> Deflect:
	return Deflect.NONE
