extends Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var idle_anim_name: StringName = "IDLE_DITSY"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play(idle_anim_name)
	
func play_dmg():
	animation_player.play("IDLE_GLITCH")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if animation_player.get_animation(anim_name).loop_mode != Animation.LOOP_LINEAR:
		animation_player.play(idle_anim_name)
