@tool

class_name DoublePiece
extends Node2D


enum Orientation { UP, LEFT, RIGHT, DOWN }

@onready var scene_Piece = preload("res://scenes/piece.tscn")
@onready var NodePrimary = $NodePrimary
@onready var NodeSecondary = $RotationContainer/NodeSecondary
@onready var RotationContainer = $RotationContainer
@onready var PrimaryLeft = $NodePrimary/Left
@onready var PrimaryRight = $NodePrimary/Right
@onready var PrimaryUp = $NodePrimary/Up
@onready var PrimaryDown = $NodePrimary/Down
@onready var SecondaryUp = $RotationContainer/NodeSecondary/Up
@onready var SecondaryLeft = $RotationContainer/NodeSecondary/Left
@onready var SecondaryRight = $RotationContainer/NodeSecondary/Right
@onready var SecondaryDown = $RotationContainer/NodeSecondary/Down

signal on_placed
@export var cell_size := 64
var primary: Piece
var secondary: Piece
var orientation_index := 0
const ORIENTATION_ORDER := [ Orientation.RIGHT, Orientation.UP, Orientation.LEFT, Orientation.DOWN ]

func _ready() -> void:
	primary = scene_Piece.instantiate()
	secondary = scene_Piece.instantiate()
	primary.cell_size = cell_size
	secondary.cell_size = cell_size
	NodePrimary.add_child(primary)
	NodeSecondary.add_child(secondary)
	primary.transform = Transform2D()
	secondary.transform = Transform2D()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_up"):
		move_up()
	if event.is_action_pressed("move_left"):
		move_left()
	if event.is_action_pressed("move_right"):
		move_right()
	if event.is_action_pressed("move_down"):
		move_down()
	if event.is_action_pressed("rotate_cw"):
		rotate_cw()
	if event.is_action_pressed("rotate_ccw"):
		rotate_ccw()

func move_left():
	match get_orientation():
		Orientation.UP, Orientation.DOWN:
			if PrimaryLeft.is_colliding() or SecondaryLeft.is_colliding():
				return
		Orientation.LEFT:
			if SecondaryLeft.is_colliding():
				return
		Orientation.RIGHT:
			if PrimaryLeft.is_colliding():
				return
	translate(Vector2(-cell_size, 0))
	
func move_right():
	match get_orientation():
		Orientation.UP, Orientation.DOWN:
			if PrimaryRight.is_colliding() or SecondaryRight.is_colliding():
				return
		Orientation.LEFT:
			if PrimaryRight.is_colliding():
				return
		Orientation.RIGHT:
			if SecondaryRight.is_colliding():
				return
	translate(Vector2(cell_size, 0))

func move_up():
	translate(Vector2(0, -cell_size))
	
func move_down():
	match get_orientation():
		Orientation.UP:
			if PrimaryDown.is_colliding():
				place()
				return
		Orientation.LEFT, Orientation.RIGHT:
			if PrimaryDown.is_colliding() or SecondaryDown.is_colliding():
				place()
				return
		Orientation.DOWN:
			if SecondaryDown.is_colliding():
				place()
				return
	translate(Vector2(0, cell_size))

func place():
	queue_free()
	NodePrimary.remove_child(primary)
	NodeSecondary.remove_child(secondary)
	primary.transform.origin = transform.origin
	var relative_position = NodeSecondary.transform.rotated(RotationContainer.transform.get_rotation()).origin
	secondary.transform.origin = transform.origin + relative_position
	on_placed.emit(primary, secondary)

func rotate_cw():
	match get_orientation():
		Orientation.UP:
			if PrimaryRight.is_colliding():
				move_left()
		Orientation.LEFT:
			pass # no adjustment needed
		Orientation.RIGHT:
			if PrimaryDown.is_colliding():
				move_up()
		Orientation.DOWN:
			if PrimaryLeft.is_colliding():
				move_right()
	rotate_90_cw()
	
func rotate_ccw():
	match get_orientation():
		Orientation.UP:
			if PrimaryLeft.is_colliding():
				move_right()
		Orientation.LEFT:
			if PrimaryDown.is_colliding():
				move_up()
		Orientation.RIGHT:
			pass # no adjustment needed
		Orientation.DOWN:
			if PrimaryRight.is_colliding():
				move_left()
	rotate_90_ccw()

func get_orientation() -> Orientation:
	return ORIENTATION_ORDER[orientation_index]

func rotate_90_ccw():
	orientation_index = (orientation_index + 1) % len(ORIENTATION_ORDER)
	
func rotate_90_cw():
	orientation_index = (orientation_index + len(ORIENTATION_ORDER) - 1) % len(ORIENTATION_ORDER)

func set_angle(angle: float):
	RotationContainer.rotation = angle
	NodeSecondary.rotation = -angle

func update_children() -> void:
	if NodeSecondary: NodeSecondary.transform.origin.x = cell_size
	for ray in [PrimaryUp, PrimaryDown, PrimaryLeft, PrimaryRight, SecondaryUp, SecondaryDown, SecondaryLeft, SecondaryRight]:
		if ray: ray.target_position.x = cell_size
	if primary: primary.cell_size = cell_size
	if secondary: secondary.cell_size = cell_size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_children()
	match get_orientation():
		Orientation.UP:
			set_angle(-PI/2)
		Orientation.LEFT:
			set_angle(PI)
		Orientation.RIGHT:
			set_angle(0)
		Orientation.DOWN:
			set_angle(PI/2)
		
