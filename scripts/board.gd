class_name Board
extends Node2D

var scene_DoublePiece = preload("res://scenes/double_piece.tscn")


const BOARD_WIDTH := 6
const BOARD_HEIGHT := 10
const CELL_SIZE := 64
const UPDATE_TIME := 0.5

var columns : Array
var dp : DoublePiece

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	columns = []
	for c in range(BOARD_WIDTH):
		columns.append([])
	run()

func reindex_columns() -> void:
	for column in columns:
		(column as Array).clear()
	for child in get_children():
		if child is not Piece:
			continue
		if child.is_queued_for_deletion():
			continue
		var column_index = int(child.transform.origin.x / CELL_SIZE)
		columns[column_index].append(child)

func create_new_double_piece() -> void:
	dp = scene_DoublePiece.instantiate()
	dp.transform.origin = Vector2(CELL_SIZE/2, CELL_SIZE/2)
	dp.on_placed.connect(place)
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
			var new_y = CELL_SIZE / 2 + CELL_SIZE * (BOARD_HEIGHT - 1 - i)
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
