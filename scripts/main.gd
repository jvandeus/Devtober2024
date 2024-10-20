extends Node2D

@onready var scene_Bomb = preload("res://scenes/bomb.tscn")
@onready var board = $Board
@onready var opponent_portrait = $OpponentPortrait
@onready var bomb_socket = $BombSocket
@onready var health_bar = $HealthBar
@onready var attack_meter = $AttackMeter
@onready var win_text = $WinText
@onready var preview_pane = $PreviewPane

var bomb: Bomb
var attack_charge_timer: SceneTreeTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#board.on_pieces_cleared.connect(_on_pieces_cleared)
	#board.on_combo_finished.connect(_on_combo_finished)
	health_bar.on_empty.connect(win)
	attack_meter.on_full.connect(opponent_attack)
	opponent_attack_charge_loop()

func win() -> void:
	opponent_portrait.lose()
	attack_charge_timer.timeout.disconnect(opponent_attack_charge_loop)
	board.stop()
	win_text.visible = true

func opponent_attack_charge_loop() -> void:
	await attack_meter.increment(1)
	attack_charge_timer = get_tree().create_timer(1)
	attack_charge_timer.timeout.connect(opponent_attack_charge_loop)
		
func opponent_attack() -> void:
	attack_meter.clear()

func _on_pieces_cleared(num_pieces: int, combo: int):
	var points = num_pieces * combo
	if not bomb:
		bomb = scene_Bomb.instantiate()
		add_child(bomb)
		bomb.transform.origin = bomb_socket.transform.origin
	bomb.add_points(num_pieces * combo)
	
func _on_combo_finished():
	if not bomb:
		return
	if bomb.is_too_weak_to_send():
		bomb = null
		return
	var tween = create_tween()
	var bomb_in_transit = bomb
	bomb = null
	tween.tween_property(bomb_in_transit, "position", opponent_portrait.transform.origin, 1)
	await tween.finished
	opponent_portrait.hurt()
	health_bar.decrement(bomb_in_transit.get_damage())
	bomb_in_transit.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_placed(double_peice: RefCounted) -> void:
	pass # Replace with function body.

func _on_player_move(blocked: bool) -> void:
	pass # Replace with function body.
