extends CanvasLayer
@onready var transition_player: AnimationPlayer = $Transition_Player

#func _ready():
	#change_scene()

func trans_scene(target):
	get_tree().change_scene_to_file(target)

func change_scene(target="res://assets/cutscenes/victories/CINE_victory_cheery.tscn") -> void:
	transition_player.play("dissolve")
	await transition_player.animation_finished
	trans_scene(target)
	transition_player.play_backwards("dissolve")
