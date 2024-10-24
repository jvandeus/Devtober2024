extends Node3D

@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var tia: Node3D = $"TIA-V_MASTER2"

signal disable_anim_tree

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ap.play("Dolly_Camera")
	tia.disable_anim_tree()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
