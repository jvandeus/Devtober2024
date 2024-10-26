extends Node3D
@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var anim_tree: AnimationTree = $AnimationTree
var al: StringName = "TIA-V_anim_library/"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
		
func disable_anim_tree():
	anim_tree.active = false
	
	
func play_dmg():
	var r = randi_range(0, 1)
	var playback = anim_tree["parameters/playback"]
	#playback.travel("HitstunState/STUN 1")
	match r:
		0:
			print(r)
		1:
			print(r)
			
	
func play_atk():
	var playback = anim_tree["parameters/playback"]
	playback.travel("Attack")
	#ap.play(al+"ATK_PITCHER")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass
#	if ap.get_animation(anim_name).loop_mode != Animation.LOOP_LINEAR:
#		ap.play(al+"IDLE_DITSY")

func _on_pieces_cleared() -> void:
	play_dmg()
