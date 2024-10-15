@tool

class_name DoublePiece
extends Node2D

const PRIMARY_INDICATOR_COLOR = Color(1, 1, 1, 0.5)
const REPEAT_DELAY = 0.25
const REPEAT_DURATION = 0.05
const TIME_TO_FALL_ONE_CELL = 1

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
var orientation_index := 1
const ORIENTATION_ORDER := [ Orientation.RIGHT, Orientation.UP, Orientation.LEFT, Orientation.DOWN ]

var is_left_pressed := false
var is_right_pressed := false
var is_down_pressed := false

func _ready() -> void:
	primary = scene_Piece.instantiate()
	secondary = scene_Piece.instantiate()
	primary.cell_size = cell_size
	secondary.cell_size = cell_size
	NodePrimary.add_child(primary)
	NodeSecondary.add_child(secondary)
	primary.transform = Transform2D()
	secondary.transform = Transform2D()
	start_falling()

func _draw() -> void:
	draw_circle(Vector2(0, 0), cell_size/2, PRIMARY_INDICATOR_COLOR, false, 4.0, true)

func start_falling() -> void:
	#TODO fix this to restart fall timer when down is released
	while true:
		await get_tree().create_timer(TIME_TO_FALL_ONE_CELL).timeout
		if is_down_pressed:
			continue
		move_down()

#TODO fix bug where double pieces can go out of bounds if you hold left/right and rotate repeatedly
func hold_left() -> void:
	move_left()
	await get_tree().create_timer(REPEAT_DELAY).timeout
	while is_left_pressed:
		move_left()
		await get_tree().create_timer(REPEAT_DURATION).timeout
		
func hold_right() -> void:
	move_right()
	await get_tree().create_timer(REPEAT_DELAY).timeout
	while is_right_pressed:
		move_right()
		await get_tree().create_timer(REPEAT_DURATION).timeout
		
func hold_down() -> void:
	move_down()
	await get_tree().create_timer(REPEAT_DELAY).timeout
	while is_down_pressed:
		move_down()
		await get_tree().create_timer(REPEAT_DURATION).timeout

#TODO migrate input handling to board.gd
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_up"):
		rotate_cw()
		
	if event.is_action_pressed("move_left"):
		is_left_pressed = true
		hold_left()
	if event.is_action_released("move_left"):
		is_left_pressed = false
		
	if event.is_action_pressed("move_right"):
		is_right_pressed = true
		hold_right()
	if event.is_action_released("move_right"):
		is_right_pressed = false
		
	if event.is_action_pressed("move_down"):
		is_down_pressed = true
		hold_down()
	if event.is_action_released("move_down"):
		is_down_pressed = false
		
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
	queue_redraw()
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
		
