extends Node3D
@onready var tia: Node3D = $"TIA-V_MASTER"
@onready var main_sequence: AnimationPlayer = $MainSequence

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play()
	
func _input(event: InputEvent):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE:
			play()
	
func play():
	#tia.disable_anim_tree()
	main_sequence.play("main")
