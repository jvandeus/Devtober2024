extends Node3D
@onready var ap: AnimationPlayer = $AnimationPlayer
var al: StringName = "TIA-V_anim_library/"
@onready var anim_tree: AnimationTree = $AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
		
func disable_anim_tree():
	anim_tree.active = false
	
	
func play_dmg():
	ap.play(al+"HITSTUN_01")
	
func play_atk():
	ap.play(al+"ATK_PITCHER")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass
#	if ap.get_animation(anim_name).loop_mode != Animation.LOOP_LINEAR:
#		ap.play(al+"IDLE_DITSY")

func _on_pieces_cleared() -> void:
	self.play_dmg()
