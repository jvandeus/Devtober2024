extends Control

func _ready() -> void:
	$VBoxContainer/PlayButton.grab_focus()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	
func _on_options_button_pressed() -> void:
	pass
	
func _on_quit_button_pressed() -> void:
	get_tree().quit()
