extends Control

signal unpause
signal restart
signal quit

func initialize() -> void:
	$VBoxContainer/ResumeButton.grab_focus()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		# stop propagation of the event to the parent by calling Control.accept_event()
		# if this is not called, the parent will process this same pause event and re-pause
		accept_event()
		unpause.emit()

func _on_resume_button_pressed() -> void:
	unpause.emit()

func _on_restart_button_pressed() -> void:
	restart.emit()

func _on_quit_button_pressed() -> void:
	quit.emit()
