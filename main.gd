extends Node

# TODO
# - add velocity property to class
# - spawn pieces using JUIK
# - add clear check

class Board:
	var data: Array[Piece]
	var width: int
	var height: int
	func _init(w, h):
		data.resize(w * h)
		data.fill(null)
		width = w
		height = h
	func set_piece(pos: Vector2i, piece: Piece):
		data[pos.x + pos.y * width] = piece
	func get_piece(pos: Vector2i) -> Piece:
		if is_out_of_bounds(pos):
			return null
		return data[pos.x + pos.y * width]
	func is_out_of_bounds(pos: Vector2i) -> bool:
		return pos.x < 0 or width <= pos.x or \
			   pos.y < 0 or height <= pos.y
	func for_each_piece(fn):
		for x in range(width):
			for y in range(height):
				var pos = Vector2i(x, y)
				var piece = get_piece(pos)
				if piece:
					fn.call(pos, piece)
	func update() -> Board:
		var next = Board.new(width, height)
		# Copy all non-moving pieces to the new board. This must be done in several passes.
		# The first pass only copies pieces against the boundaries.
		# After the first pass, more pieces may realize they cannot move, so we keep doing passes
		# until we reach equilibrium.
		for i in range(max(width, height)):
			for_each_piece(func(pos, piece):
				var next_pos = pos + piece.velocity
				var piece_at_next_pos = next.get_piece(next_pos)
				if next.is_out_of_bounds(next_pos) or \
				piece_at_next_pos and not piece.can_merge_with(piece_at_next_pos):
					set_piece(pos, null)
					piece.velocity = Vector2i(0, 1)
					next.set_piece(pos, piece)
					return
			)
		# Now that all the non-moving pieces are copied, update the moving pieces.
		for_each_piece(func(pos, piece):
			var next_pos = pos + piece.velocity
			var piece_at_next_pos = next.get_piece(next_pos)
			# The position the piece is moving to is unoccupied.
			if not next.is_out_of_bounds(next_pos) and not piece_at_next_pos:
				set_piece(pos, null)
				next.set_piece(next_pos, piece)
				return
			# The position the piece is moving to contains a piece that it can merge with.
			if piece_at_next_pos and piece.can_merge_with(piece_at_next_pos):
				set_piece(pos, null)
				next.set_piece(next_pos, Piece.new(Piece.Type.FULL))
				return
		)
		return next

var cursor = Vector2i(1, 2)
var board = Board.new(6, 10)
var time_elapsed = 0
const UPDATE_DURATION = 0.1

func _input(event):
	if event.is_action_pressed("move_left"):
		cursor.x = max(cursor.x - 1, 0)
	if event.is_action_pressed("move_right"):
		cursor.x = min(cursor.x + 1, board.width - 1)
	if event.is_action_pressed("move_up"):
		cursor.y = max(cursor.y - 1, 0)
	if event.is_action_pressed("move_down"):
		cursor.y = min(cursor.y + 1, board.height - 1)
	if event.is_action_pressed("action"):
		board.set_piece(cursor, Piece.rand());

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_elapsed += delta
	if time_elapsed > UPDATE_DURATION:
		time_elapsed -= UPDATE_DURATION
		board = board.update()
	
	$cursor_layer.clear()
	$cursor_layer.set_cell(cursor, 0, Vector2i(2, 0))
	
	$board_layer.clear()
	for x in range(board.width):
		for y in range(board.height):
			var pos = Vector2i(x, y)
			var piece = board.get_piece(pos)
			if piece:
				$board_layer.set_cell(pos, 0, piece.atlas_coords())
