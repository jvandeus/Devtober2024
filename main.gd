extends Node

enum CellState { EMPTY, UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT, FULL }

const PIECE_PAIRS = [
	[CellState.UP_LEFT, CellState.DOWN_RIGHT],
	[CellState.UP_RIGHT, CellState.DOWN_LEFT],
]

class Board:
	var data: Array
	var width: int
	var height: int
	func _init(w, h):
		data.resize(w * h)
		data.fill(CellState.EMPTY)
		width = w
		height = h
	func set_cell(pos: Vector2i, state: CellState):
		data[pos.x + pos.y * width] = state
	func get_cell(pos: Vector2i) -> CellState:
		return data[pos.x + pos.y * width]
	func is_piece(state: CellState) -> bool:
		return PIECES.has(state)
	func update() -> Board:
		var next = Board.new(width, height)
		for x in range(width):
			for y in range(height-1, -1, -1):
				var pos = Vector2i(x, y)
				var cell = get_cell(pos)
				if not is_piece(cell):
					continue
				var new_pos = pos + Vector2i(0, 1)
				if new_pos.y >= height: # bottom of board
					next.set_cell(pos, cell)
					continue
				var next_cell = next.get_cell(new_pos)
				if next_cell == CellState.EMPTY: # unoccupied
					next.set_cell(new_pos, cell)
					continue
				var cells = [cell, next_cell]
				cells.sort()
				if PIECE_PAIRS.has(cells): # merge
					next.set_cell(new_pos, CellState.FULL)
					continue
				# piece doesn't move
				next.set_cell(pos, cell)
				
		return next

const STATE_MAP = {
	CellState.UP_LEFT: Vector2i(1, 0),
	CellState.UP_RIGHT: Vector2i(2, 0),
	CellState.DOWN_LEFT: Vector2i(3, 0),
	CellState.DOWN_RIGHT: Vector2i(4, 0),
	CellState.EMPTY: Vector2i(0, 0),
	CellState.FULL: Vector2i(6, 0),
}

const PIECES = [
	CellState.UP_LEFT,
	CellState.UP_RIGHT,
	CellState.DOWN_LEFT,
	CellState.DOWN_RIGHT,
	CellState.FULL,
]
var cursor = Vector2i(1, 2)
var board = Board.new(6, 10)
var time_elapsed = 0
const UPDATE_DURATION = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

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
		spawn_piece(cursor, random_piece());



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_elapsed += delta
	if time_elapsed > UPDATE_DURATION:
		time_elapsed -= UPDATE_DURATION
		board = board.update()
	
	$cursor_layer.clear()
	$cursor_layer.set_cell(cursor, 0, Vector2i(5, 0))
	
	$board_layer.clear()
	for x in range(board.width):
		for y in range(board.height):
			var pos = Vector2i(x, y)
			var state = board.get_cell(pos)		
			$board_layer.set_cell(pos, 0, state2atlas(state))



func state2atlas(state: CellState) -> Vector2i:
	return STATE_MAP.get(state)

func random_piece() -> CellState:
	return PIECES[randi_range(0, 3)]


func spawn_piece(position: Vector2i, piece: CellState):
	board.set_cell(position, piece)
