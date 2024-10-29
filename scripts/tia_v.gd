extends Node3D
@onready var anim_tree: AnimationTree = $AnimationTree
@export var random_stun := 0
@export var random_attack := 0
		
func disable_anim_tree():
	anim_tree.active = false
	
func play_rnd(state, rand_num, min, max):
	rand_num = randi_range(min, max)
	var playback = anim_tree["parameters/playback"]
	playback.travel(state)
	
func play_dmg():
	play_rnd("HitstunState", random_stun, 0, 1)
	
func play_atk():
	play_rnd("AttackState", random_attack, 0, 1)
	
func idle_scared():
	var playback = anim_tree["parameters/playback"]
	anim_tree["parameters/Idle/BlendTree/OneShot/request"] = "Fire"
	
