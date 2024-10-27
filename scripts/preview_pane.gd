class_name PreviewPane
extends Node2D

@onready var scene_DoublePiecePreview = preload("res://scenes/double_piece_preview.tscn")
@onready var poly_bg: Polygon2D = $PolyBg
@onready var poly_bg_inner: Polygon2D = $PolyBgInner
@onready var poly_ref: Polygon2D = $PolyRef
@onready var connector: CableConnector = $CableConnector

@export var cell_size := 64

const POP_DURATION = 0.25

@onready var t1 := Transform2D(0, Vector2(0, 0)) # next piece transform
@onready var t2 := Transform2D(PI/2, Vector2(-cell_size * 3, 0)) # next next piece transform
@onready var t3 := Transform2D(PI/2, Vector2(-cell_size * 6, 0)) # off screen transform
var p1: DoublePiecePreview # next piece
var p2: DoublePiecePreview # next next piece

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	p1 = scene_DoublePiecePreview.instantiate()
	p1.cell_size = cell_size
	add_child(p1)
	p1.transform = t1
	p2 = scene_DoublePiecePreview.instantiate()
	p2.cell_size = cell_size
	add_child(p2)
	p2.transform = t2

func pop() -> Array:
	var tmp = p1
	p1 = p2
	p2 = scene_DoublePiecePreview.instantiate()
	add_child(p2)
	p2.transform = t3
	
	var tweens = [
		create_tween().tween_property(tmp, "transform", tmp.transform.translated(Vector2(0, -300)), POP_DURATION).finished,
		create_tween().tween_property(p1, "transform", t1, POP_DURATION).finished,
		create_tween().tween_property(p2, "transform", t2, POP_DURATION).finished
	]
	for tween in tweens:
		await tween
	
	return tmp.queue_free_and_yield_pieces()
	

func resize(ref_points: PackedVector2Array, board_width: int, board_height: int, cell_size: int):
	poly_bg.resize(poly_ref.polygon, board_width, board_height, cell_size)
	poly_bg_inner.resize(poly_ref.polygon, board_width, board_height, cell_size)
	connector.resize(poly_ref.polygon, board_width, board_height, cell_size)
	
