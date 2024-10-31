extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/Normal.grab_focus()

enum Difficulty { NORMAL, HARD, REALLY_HARD }

func load_main_scene(difficulty: Difficulty) -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	match difficulty:
		Difficulty.NORMAL:
			scene.opponent_attack_num_rows = 2
			scene.opponent_attack_time = 40
		Difficulty.HARD:
			scene.opponent_attack_num_rows = 3
			scene.opponent_attack_time = 30
		Difficulty.REALLY_HARD:
			scene.opponent_attack_num_rows = 3
			scene.opponent_attack_time = 20
	get_tree().get_root().add_child(scene)
	queue_free()


func _on_normal_pressed() -> void:
	load_main_scene(Difficulty.NORMAL)


func _on_hard_pressed() -> void:
	load_main_scene(Difficulty.HARD)


func _on_harder_pressed() -> void:
	load_main_scene(Difficulty.REALLY_HARD)
