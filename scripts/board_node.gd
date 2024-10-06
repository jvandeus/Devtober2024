extends Node2D

var is_clearing := false
var time_elapsed := 0.0
var UPDATE_TIME := 0.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_elapsed += delta
	if time_elapsed < UPDATE_TIME:
		return
	time_elapsed -= UPDATE_TIME
	
	if is_clearing:
		return
	
	var any_piece_updated = false
	var full_pieces = []
	for piece in get_children():
		if piece is SinglePiece:
			var did_update = piece.update()
			any_piece_updated = any_piece_updated || did_update
			if piece is PieceFull:
				full_pieces.append(piece)
	
	var pieces_to_clear = []
	if !any_piece_updated: # board is stable
		var visited = {}
		
		for full_piece in full_pieces:
			full_piece = full_piece as PieceFull
			if visited.has(hash(full_piece)):
				continue
			var cluster = full_piece.find_adj(visited)
			if len(cluster) >= 4:
				pieces_to_clear.append_array(cluster)
	
	if len(pieces_to_clear) > 0:
		for piece in pieces_to_clear:
			piece.sprite.play()
		is_clearing = true
		await get_tree().create_timer(1.0).timeout
		is_clearing = false
		for piece in pieces_to_clear:
			piece.queue_free()
