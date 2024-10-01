extends Node

@onready var game_manager: Node = %GameManager

# TODO
# - add current pair
# - show next pairs
# - move current pair around
# - drop pairs
# - rotate pairs

class DeflectResult:
	var is_valid := false
	var pos: Vector2i
	var dir: Vector2i
	func _init(p: Vector2i, d: Vector2i, v := true):
		pos = p
		dir = d
		is_valid = v
	static func make_invalid() -> DeflectResult:
		return DeflectResult.new(Vector2i(0, 0), Vector2i(0, 0), false)

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
	func clear_clusters_of_size(size: int) -> Array[Piece]:
		var visited = {}
		var cells_to_clear = []
		var clear: Array[Piece] = []
		for_each_piece(func(pos, piece):
			if piece.type != Piece.Type.FULL:
				return
			if visited.get(pos):
				return
			var cluster = []
			var stack = [pos]
			while not stack.is_empty():
				var cur_pos = stack.pop_back()
				if visited.get(cur_pos):
					continue
				visited[cur_pos] = true
				cluster.append(cur_pos)
				var up = cur_pos + Vector2i(0, -1)
				var down = cur_pos + Vector2i(0, 1)
				var left = cur_pos + Vector2i(-1, 0)
				var right = cur_pos + Vector2i(1, 0)
				for adj_pos in [up, down, left, right]:
					if is_out_of_bounds(adj_pos):
						continue
					if visited.get(adj_pos):
						continue
					var adj_piece = get_piece(adj_pos)
					if adj_piece and adj_piece.type == Piece.Type.FULL:
						stack.push_back(adj_pos)
			if len(cluster) >= size:
				cells_to_clear.append_array(cluster)
		)
		for cell_xy in cells_to_clear:
			clear.append(get_piece(cell_xy))
			set_piece(cell_xy, null)
		return clear
	func try_deflect(incoming_pos: Vector2i, deflector_pos: Vector2i) -> DeflectResult:
		var deflector_piece = get_piece(deflector_pos)
		if not deflector_piece:
			return DeflectResult.make_invalid()
		var incoming_dir = deflector_pos - incoming_pos
		if incoming_dir != Vector2i(0, 1):
			return DeflectResult.make_invalid()
		
		var deflect_dir = Vector2i(0, 0)
		match deflector_piece.type:
			Piece.Type.DOWN_LEFT:
				deflect_dir = Vector2i(1, 0)
			Piece.Type.DOWN_RIGHT:
				deflect_dir = Vector2i(-1, 0)
		var deflected_pos = deflector_pos + deflect_dir
		if is_out_of_bounds(deflected_pos) or get_piece(deflected_pos):
			return DeflectResult.make_invalid()
		return DeflectResult.new(deflected_pos, deflect_dir)
	func update(game_manager: Node) -> Board:
		game_manager.add_clear(clear_clusters_of_size(4))
		var next = Board.new(width, height)
		# Copy all non-moving pieces to the new board. This must be done in several passes.
		# The first pass only copies pieces against the boundaries.
		# After the first pass, more pieces may realize they cannot move, so we keep doing passes
		# until we reach equilibrium.
		for i in range(max(width, height)):
			for_each_piece(func(pos, piece):
				var next_pos = pos + piece.velocity
				var piece_at_next_pos = next.get_piece(next_pos)
				var piece_will_merge = piece_at_next_pos and piece.can_merge_with(piece_at_next_pos)
				var piece_will_deflect = piece_at_next_pos and next.try_deflect(pos, next_pos).is_valid
				if piece_will_merge or piece_will_deflect:
					return
				if next.is_out_of_bounds(next_pos) or piece_at_next_pos:
					set_piece(pos, null)
					piece.velocity = Vector2i(0, 1)
					next.set_piece(pos, piece)
					return
			)
		# Now that all the non-moving pieces are copied, copy the moving pieces.
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
			# The position the piece is moving to contains a piece that can deflect it.
			var deflect_result = next.try_deflect(pos, next_pos)
			if deflect_result.is_valid:
				set_piece(pos, null)
				piece.velocity = deflect_result.dir
				next.set_piece(deflect_result.pos, piece)
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
	if event.is_action_pressed("spawn_up_left"):
		board.set_piece(cursor, Piece.new(Piece.Type.UP_LEFT));
	if event.is_action_pressed("spawn_up_right"):
		board.set_piece(cursor, Piece.new(Piece.Type.UP_RIGHT));
	if event.is_action_pressed("spawn_down_left"):
		board.set_piece(cursor, Piece.new(Piece.Type.DOWN_LEFT));
	if event.is_action_pressed("spawn_down_right"):
		board.set_piece(cursor, Piece.new(Piece.Type.DOWN_RIGHT));
	if event.is_action_pressed("spawn_full"):
		board.set_piece(cursor, Piece.new(Piece.Type.FULL));

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_elapsed += delta
	if time_elapsed > UPDATE_DURATION:
		time_elapsed -= UPDATE_DURATION
		board = board.update(game_manager)
	
	$cursor_layer.clear()
	$cursor_layer.set_cell(cursor, 0, Vector2i(2, 0))
	
	$board_layer.clear()
	for x in range(board.width):
		for y in range(board.height):
			var pos = Vector2i(x, y)
			var piece = board.get_piece(pos)
			if piece:
				$board_layer.set_cell(pos, 0, piece.atlas_coords())
