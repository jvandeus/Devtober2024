@tool

class_name Board
extends Node2D

class DoublePiece:
	enum Orientation { UP, LEFT, RIGHT, DOWN }
	const ORIENTATION_ORDER := [ Orientation.RIGHT, Orientation.UP, Orientation.LEFT, Orientation.DOWN ]
	var orientation_index := 1
	var origin := Vector2i(0, 0)
	func _init(p_origin: Vector2i) -> void:
		origin = p_origin
	func get_primary_coords() -> Vector2i:
		return origin
	func get_secondary_coords() -> Vector2i:
		match get_orientation():
			Orientation.UP:
				return origin + Vector2i(0, -1)
			Orientation.DOWN:
				return origin + Vector2i(0, 1)
			Orientation.LEFT:
				return origin + Vector2i(-1, 0)
			Orientation.RIGHT:
				return origin + Vector2i(1, 0)
		assert(false)
		return Vector2i(0, 0)
	func get_primary_pos(cell_size: int) -> Vector2:
		return Vector2(get_primary_coords() * cell_size) + Vector2(cell_size / 2, cell_size / 2)
	func get_secondary_pos(cell_size: int) -> Vector2:
		return Vector2(get_secondary_coords() * cell_size) + Vector2(cell_size / 2, cell_size / 2)
	func get_orientation() -> Orientation:
		return ORIENTATION_ORDER[orientation_index]
	func rotate_ccw():
		orientation_index = (orientation_index + 1) % len(ORIENTATION_ORDER)
	func rotate_cw():
		orientation_index = (orientation_index + len(ORIENTATION_ORDER) - 1) % len(ORIENTATION_ORDER)
	func move_left():
		origin.x -= 1
	func move_right():
		origin.x += 1
	func move_up():
		origin.y -= 1
	func move_down():
		origin.y += 1

const TIME_TO_FALL_ONE_CELL := 1.0
const LINE_COLOR := Color(1, 1, 1, 0.2)
const BG_COLOR := Color(.1, .1, .1, 0.7)
const REPEAT_DELAY := 0.3
const REPEAT_PERIOD := 0.06
const PLACING_DELAY := 0.25

@onready var scene_Piece = preload("res://scenes/piece.tscn")

@export var board_width := 6
@export var board_height := 10
@export var cell_size := 64

var columns : Array
var dp: DoublePiece
var primary: Piece
var secondary: Piece
var fall_timer: SceneTreeTimer
var is_down_pressed := false
var is_left_pressed := false
var is_right_pressed := false

signal intent_to_move_down
signal pieces_cleared

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	columns = []
	for c in range(board_width):
		columns.append([])
	if not Engine.is_editor_hint():
		start_double_piece_fall_loop()
		run()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_down"):
		is_down_pressed = true
		hold_down()
	if event.is_action_released("move_down"):
		is_down_pressed = false
	if event.is_action_pressed("move_left"):
		is_right_pressed = false
		is_left_pressed = true
		hold_left()
	if event.is_action_released("move_left"):
		is_left_pressed = false
	if event.is_action_pressed("move_right"):
		is_left_pressed = false
		is_right_pressed = true
		hold_right()
	if event.is_action_released("move_right"):
		is_right_pressed = false
	if event.is_action_pressed("rotate_cw"):
		if dp: rotate_cw()
	if event.is_action_pressed("rotate_ccw"):
		if dp: rotate_ccw()

func is_occupied(pos: Vector2i) -> bool:
	if pos.x < 0 or len(columns) <= pos.x:
		return true
	if pos.y >= board_height - len(columns[pos.x]):
		return true
	return false

func hold_down() -> void:
	# soft drop doesn't use repeat delay
	while is_down_pressed:
		if dp: move_down()
		await get_tree().create_timer(REPEAT_PERIOD).timeout

func hold_left() -> void:
	if dp: move_left()
	await get_tree().create_timer(REPEAT_DELAY).timeout
	while is_left_pressed:
		if dp: move_left()
		await get_tree().create_timer(REPEAT_PERIOD).timeout

func hold_right() -> void:
	if dp: move_right()
	await get_tree().create_timer(REPEAT_DELAY).timeout
	while is_right_pressed:
		if dp: move_right()
		await get_tree().create_timer(REPEAT_PERIOD).timeout

func move_left():
	var primary_left = dp.get_primary_coords() + Vector2i(-1, 0)
	var secondary_left = dp.get_secondary_coords() + Vector2i(-1, 0)
	match dp.get_orientation():
		DoublePiece.Orientation.UP, DoublePiece.Orientation.DOWN:
			if is_occupied(primary_left) or is_occupied(secondary_left):
				return
		DoublePiece.Orientation.LEFT:
			if is_occupied(secondary_left):
				return
		DoublePiece.Orientation.RIGHT:
			if is_occupied(primary_left):
				return
	dp.move_left()
	
func move_right():
	var primary_right = dp.get_primary_coords() + Vector2i(1, 0)
	var secondary_right = dp.get_secondary_coords() + Vector2i(1, 0)
	match dp.get_orientation():
		DoublePiece.Orientation.UP, DoublePiece.Orientation.DOWN:
			if is_occupied(primary_right) or is_occupied(secondary_right):
				return
		DoublePiece.Orientation.LEFT:
			if is_occupied(primary_right):
				return
		DoublePiece.Orientation.RIGHT:
			if is_occupied(secondary_right):
				return
	dp.move_right()

func move_down():
	var primary_down = dp.get_primary_coords() + Vector2i(0, 1)
	var secondary_down = dp.get_secondary_coords() + Vector2i(0, 1)
	match dp.get_orientation():
		DoublePiece.Orientation.UP:
			if is_occupied(primary_down):
				place()
				return
		DoublePiece.Orientation.LEFT, DoublePiece.Orientation.RIGHT:
			if is_occupied(primary_down) or is_occupied(secondary_down):
				place()
				return
		DoublePiece.Orientation.DOWN:
			if is_occupied(secondary_down):
				place()
				return
	dp.move_down()
	reset_fall_timer()

func rotate_cw():
	var primary_right = dp.get_primary_coords() + Vector2i(1, 0)
	var primary_left = dp.get_primary_coords() + Vector2i(-1, 0)
	var primary_down = dp.get_primary_coords() + Vector2i(0, 1)
	match dp.get_orientation():
		DoublePiece.Orientation.UP:
			if is_occupied(primary_right):
				move_left()
		DoublePiece.Orientation.LEFT:
			pass # no adjustment needed
		DoublePiece.Orientation.RIGHT:
			if is_occupied(primary_down):
				dp.move_up()
		DoublePiece.Orientation.DOWN:
			if is_occupied(primary_left):
				move_right()
	dp.rotate_cw()

func rotate_ccw():
	var primary_right = dp.get_primary_coords() + Vector2i(1, 0)
	var primary_left = dp.get_primary_coords() + Vector2i(-1, 0)
	var primary_down = dp.get_primary_coords() + Vector2i(0, 1)
	match dp.get_orientation():
		DoublePiece.Orientation.UP:
			if is_occupied(primary_left):
				move_right()
		DoublePiece.Orientation.LEFT:
			if is_occupied(primary_down):
				dp.move_up()
		DoublePiece.Orientation.RIGHT:
			pass # no adjustment needed
		DoublePiece.Orientation.DOWN:
			if is_occupied(primary_right):
				move_left()
	dp.rotate_ccw()


func _draw() -> void:
	draw_rect(Rect2(0, 0, board_width * cell_size, board_height * cell_size), BG_COLOR)
	for i in range(1, board_width):
		var x = i * cell_size
		draw_line(Vector2(x, 0), Vector2(x, board_height * cell_size), LINE_COLOR)
	for i in range(1, board_height):
		var y = i * cell_size
		draw_line(Vector2(0, y), Vector2(board_width * cell_size, y), LINE_COLOR)
	
	if dp:
		var primary = dp.get_primary_pos(cell_size)
		var secondary = dp.get_secondary_pos(cell_size)
		draw_circle(primary, cell_size / 2 - 16, LINE_COLOR, false, 4.0, true)
		draw_circle(secondary, cell_size / 2 - 24, LINE_COLOR, false, 4.0, true)

func reindex_columns() -> void:
	for column in columns:
		(column as Array).clear()
	for child in get_children():
		if child is not Piece:
			continue
		if child.is_queued_for_deletion():
			continue
		var column_index = int(child.transform.origin.x / cell_size)
		if column_index < 0 or len(columns) <= column_index:
			push_warning("piece placed out of bounds")
			child.queue_free()
			continue
		columns[column_index].append(child)

func create_new_double_piece() -> void:
	dp = DoublePiece.new(Vector2i(int(board_width / 2), 0))
	primary = scene_Piece.instantiate()
	secondary = scene_Piece.instantiate()
	primary.cell_size = cell_size
	secondary.cell_size = cell_size
	add_child(primary)
	add_child(secondary)
	update_primary_and_secondary()

func start_double_piece_fall_loop() -> void:
	while true:
		await intent_to_move_down
		move_down()

func cancel_fall_timer() -> void:
	if fall_timer: fall_timer.timeout.disconnect(intent_to_move_down.emit)
	
func reset_fall_timer() -> void:
	if fall_timer: fall_timer.timeout.disconnect(intent_to_move_down.emit)
	fall_timer = get_tree().create_timer(TIME_TO_FALL_ONE_CELL)
	fall_timer.timeout.connect(intent_to_move_down.emit)

func update_primary_and_secondary() -> void:
	if not dp:
		return
	primary.transform.origin = dp.get_primary_pos(cell_size)
	secondary.transform.origin = dp.get_secondary_pos(cell_size)
	
func place() -> void:
	dp = null
	run()

func run() -> void:
	cancel_fall_timer()
	reindex_columns()
	await settle()
	while await clear():
		reindex_columns()
		await settle()
	# small arbitrary delay
	await get_tree().create_timer(PLACING_DELAY).timeout
	create_new_double_piece()
	reset_fall_timer()

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
	if len(pieces_to_clear) > 0:
		pieces_cleared.emit()
	return len(pieces_to_clear) > 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	update_primary_and_secondary()
