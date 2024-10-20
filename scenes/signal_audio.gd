extends Node

@onready var place_sfx: AudioStreamPlayer = $PlaceSFX

func _on_placed() -> void:
	place_sfx.play()
