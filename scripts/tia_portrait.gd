class_name TiaPortrait
extends Node3D

@onready var tia = $"TIA-V_MASTER"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func play_atk() -> void:
	tia.play_atk()

func play_dmg() -> void:
	tia.play_dmg()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
