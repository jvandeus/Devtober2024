class_name PreviewPane
extends Node2D

@onready var scene_DoublePiecePreview = preload("res://scenes/double_piece_preview.tscn")
@onready var poly_bg: Polygon2D = $PolyBg
@onready var poly_bg_inner: Polygon2D = $PolyBgInner
@onready var poly_ref: Polygon2D = $PolyRef
@onready var connector: CableConnector = $CableConnector

@onready var Slot1 = $Slot1
@onready var Slot2 = $Slot2
@onready var Slot3 = $Slot3

@export var cell_size := 64

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# position origins for slots/peices - i think?
	var offset = -cell_size*0.5
	Slot1.transform.origin = Vector2(offset, offset)
	Slot2.transform.origin = Vector2(-(cell_size * 3 / 2)+offset, offset)
	Slot3.transform.origin = Vector2(-(cell_size * 3)+offset, offset)
	for slot in [Slot1, Slot2, Slot3]:
		var preview = scene_DoublePiecePreview.instantiate()
		preview.cell_size = cell_size
		slot.add_child(preview)

func pop() -> Array:
	var p1 = Slot1.get_child(0)
	var p2 = Slot2.get_child(0)
	var p3 = Slot3.get_child(0)
	var p4 = scene_DoublePiecePreview.instantiate()
	p4.cell_size = cell_size
	Slot1.remove_child(p1)
	Slot2.remove_child(p2)
	Slot3.remove_child(p3)
	Slot1.add_child(p2)
	Slot2.add_child(p3)
	Slot3.add_child(p4)
	return p1.queue_free_and_yield_pieces()

func resize(ref_points: PackedVector2Array, board_width: int, board_height: int, cell_size: int):
	poly_bg.resize(poly_ref.polygon, board_width, board_height, cell_size)
	poly_bg_inner.resize(poly_ref.polygon, board_width, board_height, cell_size)
	connector.resize(poly_ref.polygon, board_width, board_height, cell_size)
	
