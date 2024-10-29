extends Node3D
@onready var tia: Node3D = $"TIA-V_MASTER"
@onready var main: AnimationPlayer = $MainSequence
@onready var music: AudioStreamPlayer = $Music

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tia.disable_anim_tree()
	music.play(48.5)
	main.play("Main")
