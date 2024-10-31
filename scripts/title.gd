extends Control

func _ready() -> void:
	$VBoxContainer/PlayButton.grab_focus()

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

func _on_play_button_pressed() -> void:
	var scene = load("res://scenes/difficulty_select.tscn").instantiate()
	get_tree().get_root().add_child(scene)
	queue_free()
	
func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_credits_button_pressed() -> void:
	var scene = load("res://scenes/credits.tscn").instantiate()
	get_tree().get_root().add_child(scene)
	queue_free()
