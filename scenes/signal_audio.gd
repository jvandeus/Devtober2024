extends Node

@onready var place_sfx: AudioStreamPlayer = $PlaceSFX
@onready var move_sfx: AudioStreamPlayer = $MoveSFX
@onready var move_sfx_2: AudioStreamPlayer = $MoveSFX2
@onready var blocked_sfx: AudioStreamPlayer = $BlockedSFX
@onready var rotate_sfx: AudioStreamPlayer = $RotateSFX
@onready var combo_sfx: AudioStreamPlayer = $ComboSFX

func _on_placed() -> void:
	place_sfx.play()

func _on_player_move(not_blocked: bool, is_vertical: bool = false) -> void:
	if not_blocked:
		if is_vertical:
			move_sfx_2.play()
		else:
			move_sfx.play()
	else:
		blocked_sfx.play()

func _on_player_rotate() -> void:
	rotate_sfx.play()

func _on_pieces_cleared(num_pieces: int, combo: int) -> void:
	if combo == 1:
		reset_randomizer(combo_sfx)
	combo_sfx.play();

func reset_randomizer(sfx):
	#THIS DOESN'T WORK!! - I tried everything to make a list that would "reset" except the AudioPlayerInteractive one.
	sfx.stop()
	sfx.seek(0.0)
