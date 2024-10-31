extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$All/CenterColumn/GoBack.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_go_back_pressed() -> void:
	var scene = load("res://scenes/title.tscn").instantiate()
	get_tree().get_root().add_child(scene)
	queue_free()
