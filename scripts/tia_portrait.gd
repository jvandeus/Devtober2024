class_name TiaPortrait
extends Node3D

@onready var tia = $"TIA-V_MASTER"
var is_scared = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tia.toggle_anim_tree()
	
func idle_scared():
	tia.idle_scared()
	
func idle_ditsy():
	tia.idle_ditsy()
	
func super_atk():
	pass

func play_atk() -> void:
	tia.play_atk()

func play_dmg() -> void:
	tia.play_dmg()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
