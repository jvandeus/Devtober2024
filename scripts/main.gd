extends Node2D

@onready var scene_Bomb = preload("res://scenes/bomb.tscn")
@onready var board = $Board
@onready var opponent_portrait = $OpponentPortrait
@onready var bomb_socket = $BombSocket
@onready var health_bar = $HealthBar
@onready var attack_meter = $AttackMeter
@onready var win_text = $WinText
@onready var lose_text = $LoseText
@onready var signal_audio: Node = $SignalAudio
@onready var bg_music = $BGMusic
@onready var game_over_music = $GameOverMusic
@onready var victory_music = $VictoryMusic
#@onready var tia_v: Node3D = $"SubViewport/CharPortrait3D/TIA-V_MASTER"
@onready var scene_Victory = preload("res://assets/cutscenes/victories/CINE_victory_cheery.tscn")
@onready var scene_Portrait = preload("res://assets/cutscenes/tia_portrait.tscn")
@onready var scene_OHKO = preload("res://assets/cutscenes/spirit_bomb/spiritbomb_scene.tscn")
@onready var scene_defeat = preload("res://assets/cutscenes/defeat/tia_v_death_scene.tscn")
@onready var transition_timer: Timer = $TransitionTimer

var portrait: TiaPortrait
var bomb: Bomb
var attack_charge_timer: SceneTreeTimer
var cutscene_transition_timer: SceneTreeTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	opponent_attack_charge_loop()
	bg_music.play()
	portrait = scene_Portrait.instantiate()
	$SubViewport.add_child(portrait)

func fade_to_black(duration: float) -> void:
	var tween = create_tween()
	tween.tween_property($CanvasLayer/BlackFader, "color", Color(201, 163, 244, 1), duration)
	await tween.finished
	
func fade_from_black(duration: float) -> void:
	var tween = create_tween()
	tween.tween_property($CanvasLayer/BlackFader, "color", Color(201, 163, 244, 0), duration)
	await tween.finished
	
func play_cutscene(scene: Resource, music: AudioStreamPlayer = null, delay : float = 0, show_pause_help_text := false):
	if music:
		bg_music.stop()
		music.play()
	if delay > 0:
		await get_tree().create_timer(delay, false).timeout
	await fade_to_black(0.5)
	fade_from_black(0.5)
	$SubViewport.remove_child(portrait)
	$SubViewport.add_child(scene.instantiate())
	$CanvasLayer/CutscenePlayer.visible = true
	if show_pause_help_text:
		$CanvasLayer/PauseHelpText.visible = true

func play_victory_cutscene() -> void:
	play_cutscene(scene_Victory, victory_music, 3, true)
	
func play_ohko_cutscene() -> void:
	play_cutscene(scene_OHKO, null)
	
func play_defeat_cutscene() -> void:
	play_cutscene(scene_defeat, game_over_music, 3, true)

func stop_cutscene() -> void:
	$SubViewport.remove_child($SubViewport.get_child(0))
	$SubViewport.add_child(portrait)
	$CanvasLayer/CutscenePlayer.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause()

func pause() -> void:
	get_tree().paused = true
	$CanvasLayer/PauseMenu.visible = true
	$CanvasLayer/PauseMenu.initialize()

func unpause() -> void:
	get_tree().paused = false
	$CanvasLayer/PauseMenu.visible = false
	$Board.release_all_inputs()

func _on_pause_menu_unpause() -> void:
	unpause()

func _on_pause_menu_restart() -> void:
	unpause()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_pause_menu_quit() -> void:
	unpause()
	get_tree().change_scene_to_file("res://scenes/title.tscn")

func _on_health_bar_on_empty() -> void:
	opponent_portrait.lose()
	board.stop()
	attack_charge_timer.timeout.disconnect(opponent_attack_charge_loop)
	attack_meter.stop_shaking()
#	await fade_to_black(0.5)
#	fade_from_black(0.5)
	play_victory_cutscene()

func _on_lose() -> void:
	opponent_portrait.win()
	board.stop()
	attack_charge_timer.timeout.disconnect(opponent_attack_charge_loop)
	lose_text.visible = true
	play_defeat_cutscene()
	bg_music.stop()
	game_over_music.play()

func opponent_attack_charge_loop() -> void:
	if not attack_meter.is_full():
		await attack_meter.increment(1)
	attack_charge_timer = get_tree().create_timer(2.5, false)
	attack_charge_timer.timeout.connect(opponent_attack_charge_loop)
		
func opponent_attack() -> void:
	portrait.play_dmg()
	opponent_portrait.attack()
	attack_meter.clear()
	await board.attack2()
	opponent_portrait.idle()

func _on_pieces_cleared(num_pieces: int, combo: int):
	var points = num_pieces * combo
	if not bomb:
		bomb = scene_Bomb.instantiate()
		add_child(bomb)
		bomb.transform.origin = bomb_socket.transform.origin
	bomb.add_points(num_pieces * combo)

func strong_attack_cutscene():
	portrait.super_atk()
	await fade_to_black(0.5)
	fade_from_black(0.5)
	play_ohko_cutscene()
	await get_tree().create_timer(8, false).timeout
	await fade_to_black(0.5)
	fade_from_black(0.5)
	stop_cutscene()

func _on_settled():
	var queue = []
	if bomb and bomb.can_send():
		if bomb.get_damage() >= 40:
			# easter egg cutscene
			await strong_attack_cutscene()
		await player_attack()
	if board.is_stopped:
		return
	if attack_meter.is_full():
		opponent_attack()
		# assumption: opponent_attack triggers another on_settled,
		# so we won't try to restart the board here
		return
	if board.is_stopped:
		return
	board.start()

func _on_almost_dead() -> void:
	if portrait.is_scared == false:
		portrait.is_scared = true
		portrait.idle_scared()
	
func player_attack():
	portrait.play_atk()
	var tween = create_tween()
	var bomb_in_transit = bomb
	bomb = null
	signal_audio._on_player_attack_launch()
	tween.tween_property(bomb_in_transit, "position", opponent_portrait.transform.origin, 1)
	await tween.finished
	health_bar.decrement(bomb_in_transit.get_damage())
	signal_audio._on_player_attack_land()
	bomb_in_transit.queue_free()
	if health_bar.is_empty():
		opponent_portrait.lose()
	else:
		opponent_portrait.hurt()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_safe() -> void:
	if portrait.is_scared == true:
		portrait.is_scared = false
		portrait.idle_ditsy()
