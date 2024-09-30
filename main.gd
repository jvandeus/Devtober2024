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
		return data[pos.x + pos.y * width]
	func update() -> Board:
		var next = Board.new(width, height)
		for x in range(width):
			for y in range(height-1, -1, -1):
				var pos = Vector2i(x, y)
				var piece = get_piece(pos)
				if piece == null:
					continue
				var new_pos = pos + Vector2i(0, 1)
				if new_pos.y >= height: # bottom of board
					next.set_piece(pos, piece)
					continue
				var other_piece = next.get_piece(new_pos)
				if other_piece == null:
					next.set_piece(new_pos, piece)
					continue
				if piece.can_merge_with(other_piece):
					next.set_piece(new_pos, Piece.new(Piece.Type.FULL))
					continue
				# piece doesn't move
				next.set_piece(pos, piece)
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
