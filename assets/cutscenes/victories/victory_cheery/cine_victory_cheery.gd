extends Node3D

@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var tia = $"TIA-V_MASTER2"

signal disable_anim_tree

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bruh()
	
func bruh():
	ap.play("Dolly_Camera")
	tia.disable_anim_tree()
	$"TIA-V_MASTER2/TIA_player".play("TIA-V_VictoryCheery_skel/TIA-V_VICTORY_CHEERY")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
