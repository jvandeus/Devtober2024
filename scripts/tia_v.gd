extends Node3D
@onready var anim_tree: AnimationTree = $AnimationTree
var random_stun := 0
var random_attack := 0
		
func toggle_anim_tree():
	anim_tree.active = !anim_tree.active
	
func play_rnd(state, rand_num, min, max):
	#rand_num = randi_range(min, max)
	print(rand_num)
	var playback = anim_tree["parameters/playback"]
	playback.travel(state)
	
func play_dmg():
	random_stun = randi_range(0, 1)
	play_rnd("HitstunState", random_stun, 0, 1)
	
func play_atk():
	random_attack = randi_range(0, 1)
	play_rnd("AttackState", random_attack, 0, 1)
	
func idle_scared():
	var playback = anim_tree["parameters/playback"]
	anim_tree["parameters/Idle/BlendTree/OneShot/request"] = "Fire"
	
