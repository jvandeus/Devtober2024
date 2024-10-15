@tool

class_name Board
extends Node2D

const LINE_COLOR = Color(1, 1, 1, 0.2)
const BG_COLOR = Color(.1, .1, .1, 0.7)

var scene_DoublePiece = preload("res://scenes/double_piece.tscn")

@onready var BoardEdge_Left = $BoardEdge_Left
@onready var BoardEdge_Right = $BoardEdge_Right
@onready var BoardEdge_Bottom = $BoardEdge_Bottom

@export var board_width := 6
@export var board_height := 10
@export var cell_size := 64

var columns : Array
var dp : DoublePiece

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	columns = []
	for c in range(board_width):
		columns.append([])
	if not Engine.is_editor_hint():
		run()

func _draw() -> void:
	draw_rect(Rect2(0, 0, board_width * cell_size, board_height * cell_size), BG_COLOR)
	for i in range(1, board_width):
		var x = i * cell_size
		draw_line(Vector2(x, 0), Vector2(x, board_height * cell_size), LINE_COLOR)
	for i in range(1, board_height):
		var y = i * cell_size
		draw_line(Vector2(0, y), Vector2(board_width * cell_size, y), LINE_COLOR)

func reindex_columns() -> void:
	for column in columns:
		(column as Array).clear()
	for child in get_children():
		if child is not Piece:
			continue
		if child.is_queued_for_deletion():
			continue
		var column_index = int(child.transform.origin.x / cell_size)
		columns[column_index].append(child)

func create_new_double_piece() -> void:
	dp = scene_DoublePiece.instantiate()
	dp.transform.origin = Vector2(cell_size/2, cell_size/2)
	dp.on_placed.connect(place)
	dp.cell_size = cell_size
	add_child(dp)
	
func place(p1: Piece, p2: Piece) -> void:
	add_child(p1)
	add_child(p2)
	run()

func run() -> void:
	reindex_columns()
	await settle()
	while await clear():
		reindex_columns()
		await settle()
	create_new_double_piece()

func sort_columns() -> void:
	for column in columns:
		column.sort_custom(func(a, b):
			return a.transform.origin.y > b.transform.origin.y
		)

func settle() -> void:
	sort_columns()
	var changed_pieces := []
	for column in columns:
		for i in len(column):
			var new_y = cell_size / 2 + cell_size * (board_height - 1 - i)
			if column[i].transform.origin.y == new_y:
				continue
			changed_pieces.append(column[i])
			column[i].fall_to(new_y)
	for piece in changed_pieces:
		await piece.done_animation_fall

func clear() -> bool:
	var pieces_to_clear = []
	var visited = {}
	for piece in get_children():
		if piece is not Piece:
			continue
		if piece.is_queued_for_deletion():
			continue
		if visited.has(hash(piece)):
			continue
		var cluster = piece.get_cluster(visited)
		if len(cluster) >= 4:
			pieces_to_clear.append_array(cluster)
	for piece in pieces_to_clear:
		piece.clear()
	for piece in pieces_to_clear:
		await piece.done_animation_clear
	for piece in pieces_to_clear:
		piece.queue_free()
	return len(pieces_to_clear) > 0

func update_children() -> void:
	queue_redraw()
	if BoardEdge_Left:
		BoardEdge_Left.transform.origin = Vector2(0, board_height * cell_size / 2)
	if BoardEdge_Right:
		BoardEdge_Right.transform.origin = Vector2(board_width * cell_size, board_height * cell_size / 2)
	if BoardEdge_Bottom:
		BoardEdge_Bottom.transform.origin = Vector2(board_width * cell_size / 2, board_height * cell_size)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_children()
