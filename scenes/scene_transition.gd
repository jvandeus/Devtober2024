extends CanvasLayer
@onready var transition_player: AnimationPlayer = $Transition_Player

func change_scene(target="res://assets/cutscenes/victories/CINE_victory_cheery.tscn") -> void:
	transition_player.play("dissolve")
	await transition_player.animation_finished
	get_tree().change_scene_to_file(target)
	transition_player.play_backwards("dissolve")
