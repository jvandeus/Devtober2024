extends Node

@onready var place_sfx: AudioStreamPlayer = $PlaceSFX
@onready var move_sfx: AudioStreamPlayer = $MoveSFX
@onready var move_sfx_2: AudioStreamPlayer = $MoveSFX2
@onready var blocked_sfx: AudioStreamPlayer = $BlockedSFX
@onready var rotate_sfx: AudioStreamPlayer = $RotateSFX
@onready var combo_sfx: AudioStreamSequence = $ComboSFX
@export var pitch_increment: float = 0.25
@onready var fall_start_sfx: AudioStreamPlayer = $FallStartSFX
@onready var fall_end_sfx: AudioStreamPlayer = $FallEndSFX
@onready var player_attack_launch_sfx: AudioStreamPlayer = $PlayerAttackLaunchSFX
@onready var player_attack_land_sfx: AudioStreamPlayer = $PlayerAttackLandSFX

func reset_sequence(sfx):
	combo_sfx.reset()

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

func _on_fall_start(p: Piece) -> void:
	fall_start_sfx.play()
	
func _on_fall_end(p: Piece) -> void:
	fall_end_sfx.play(0.07)

func _on_player_attack_launch() -> void:
	player_attack_launch_sfx.play()
	
func _on_player_attack_land() -> void:
	player_attack_land_sfx.play()
