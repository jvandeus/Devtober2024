class_name PieceFull
extends SinglePiece

func can_merge(other: SinglePiece) -> bool:
	return false
func try_deflect(other: SinglePiece) -> Deflect:
	return Deflect.NONE
func find_adj(visited := {}) -> Array:
	visited[hash(self)] = true
	var result = [self]
	for raycast in [raycast_up, raycast_down, raycast_left, raycast_right]:
		var collider = raycast.get_collider()
		if collider is PieceFull and !visited.has(hash(collider)):
			result.append_array(collider.find_adj(visited))
	return result
