class_name DoublePiece

extends Node2D

const TILE_SIZE = 64

enum Orientation { UP, LEFT, RIGHT, DOWN }

@onready var NodePrimary = $NodePrimary
@onready var RotationContainer = $RotationContainer
@onready var NodeSecondary = $RotationContainer/NodeSecondary
@onready var PrimaryLeft = $NodePrimary/Left
@onready var PrimaryRight = $NodePrimary/Right
@onready var PrimaryUp = $NodePrimary/Up
@onready var PrimaryDown = $NodePrimary/Down
@onready var SecondaryUp = $RotationContainer/NodeSecondary/Up
@onready var SecondaryLeft = $RotationContainer/NodeSecondary/Left
@onready var SecondaryRight = $RotationContainer/NodeSecondary/Right
@onready var SecondaryDown = $RotationContainer/NodeSecondary/Down

var primary: SinglePiece
var secondary: SinglePiece
var target_orientation_index := 0
const ORIENTATION_ORDER := [ Orientation.RIGHT, Orientation.UP, Orientation.LEFT, Orientation.DOWN ]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is SinglePiece:
			if not primary:
				primary = child
				continue
			if not secondary:
				secondary = child
				break
	if not primary:
		push_warning("DoublePiece without primary SinglePiece")
	if not secondary:
		push_warning("DoublePiece without secondary SinglePiece")
	remove_child(primary)
	remove_child(secondary)
	NodePrimary.add_child(primary)
	NodeSecondary.add_child(secondary)
	primary.transform = Transform2D()
	secondary.transform = Transform2D()

func move_left():
	match target_orientation():
		Orientation.UP, Orientation.DOWN:
			if PrimaryLeft.is_colliding() or SecondaryLeft.is_colliding():
				return
		Orientation.LEFT:
			if SecondaryLeft.is_colliding():
				return
		Orientation.RIGHT:
			if PrimaryLeft.is_colliding():
				return
	translate(Vector2(-TILE_SIZE, 0))
	
func move_right():
	match target_orientation():
		Orientation.UP, Orientation.DOWN:
			if PrimaryRight.is_colliding() or SecondaryRight.is_colliding():
				return
		Orientation.LEFT:
			if PrimaryRight.is_colliding():
				return
		Orientation.RIGHT:
			if SecondaryRight.is_colliding():
				return
	translate(Vector2(TILE_SIZE, 0))

func move_up():
	translate(Vector2(0, -TILE_SIZE))
	
func move_down():
	match target_orientation():
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
	translate(Vector2(0, TILE_SIZE))

func place():
	print("place")

func rotate_cw():
	match target_orientation():
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
	match target_orientation():
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

func target_orientation() -> Orientation:
	return ORIENTATION_ORDER[target_orientation_index]

func rotate_90_ccw():
	target_orientation_index = (target_orientation_index + 1) % len(ORIENTATION_ORDER)
	
func rotate_90_cw():
	target_orientation_index = (target_orientation_index + len(ORIENTATION_ORDER) - 1) % len(ORIENTATION_ORDER)

func set_rotation_piecewise(angle: float):
	RotationContainer.rotation = angle
	NodeSecondary.rotation = -angle

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match target_orientation():
		Orientation.UP:
			set_rotation_piecewise(-PI/2)
		Orientation.LEFT:
			set_rotation_piecewise(PI)
		Orientation.RIGHT:
			set_rotation_piecewise(0)
		Orientation.DOWN:
			set_rotation_piecewise(PI/2)
		
