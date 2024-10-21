extends Node

@onready var place_sfx: AudioStreamPlayer = $PlaceSFX
@onready var move_sfx: AudioStreamPlayer = $MoveSFX
@onready var move_sfx_2: AudioStreamPlayer = $MoveSFX2
@onready var blocked_sfx: AudioStreamPlayer = $BlockedSFX
@onready var rotate_sfx: AudioStreamPlayer = $RotateSFX
@onready var combo_sfx: AudioStreamSequence = $ComboSFX
@export var pitch_increment: float = 0.25

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
	if combo_sfx.streams.size() <= 0: return
	if combo == 1:
		reset_sequence(combo_sfx)
	combo_sfx.pitch_scale = 1.0 + floor(combo / combo_sfx.streams.size())
	combo_sfx.play_next();

func reset_sequence(sfx):
	combo_sfx.reset()
