class_name DoublePiecePreview
extends Node2D

@onready var scene_Piece = preload("res://scenes/piece.tscn")

@onready var PrimarySlot = $PrimarySlot
@onready var SecondarySlot = $SecondarySlot

@export var cell_size := 64

var primary: Piece
var secondary: Piece

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SecondarySlot.transform.origin = Vector2(0, -cell_size)
	primary = scene_Piece.instantiate()
	secondary = scene_Piece.instantiate()
	primary.cell_size = cell_size
	secondary.cell_size = cell_size
	PrimarySlot.add_child(primary)
	SecondarySlot.add_child(secondary)

func queue_free_and_yield_pieces() -> Array:
	queue_free()
	PrimarySlot.remove_child(primary)
	SecondarySlot.remove_child(secondary)
	return [primary, secondary]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
