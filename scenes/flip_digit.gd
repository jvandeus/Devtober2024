class_name FlipDigit
extends CanvasItem
	
@onready var back_top: PanelContainer = $Back/Top
@onready var back_bottom: PanelContainer = $Back/Bottom
@onready var front_top: PanelContainer = $Front/Top
@onready var front_bottom: PanelContainer = $Front/Bottom

@onready var back_top_label: Label = $Back/Top/Margin/Label
@onready var back_bottom_label: Label = $Back/Bottom/Margin/Label
@onready var front_top_label: Label = $Front/Top/Margin/Label
@onready var front_bottom_label: Label = $Front/Bottom/Margin/Label

@onready var flip_sfx: AudioStreamPlayer = $FlipSfx

var tween
var target_text
var current_text

var text:
	get:
		return target_text if target_text else ' '
	set(value):
		if (typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT):
			value = "%1d" % value
		elif (typeof(value) == TYPE_STRING):
			value = value[0]
		flip_to(value)

func _ready() -> void:
	front_top.pivot_offset = Vector2(front_top.size.x/2, front_top.size.y)
	front_top.pivot_offset = Vector2(front_top.size.x/2, front_top.size.y)
	target_text = " "

			
func flip_to(digit):
	flip_sfx.play()
	current_text = front_bottom_label.text
	if tween:
		tween.kill() # Abort the previous animation.
		tween = create_tween()
		self.flip_finish()
		#tween.tween_property(front_bottom, "scale", Vector2(1,1), 0.1).from_current().set_trans(Tween.TRANS_ELASTIC)
	tween = create_tween()
	target_text = digit
	self.flip_start()
	tween.tween_property(front_top, "scale", Vector2(1,0), 0.1).from(Vector2(1,1)).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(front_bottom, "scale", Vector2(1,1), 0.3).from(Vector2(1,0)).set_trans(Tween.TRANS_ELASTIC)
	#tween.tween_callback(self.flip_finish)
	#front_bottom_label.text = str(digit)
	
func flip_start():
	back_top_label.text = str(target_text)
	back_bottom_label.text = current_text
	front_bottom.scale = Vector2(1,0)
	front_bottom_label.text = str(target_text)

func flip_finish():
	front_top_label.text = str(target_text)
	front_bottom_label.text = str(target_text)
	front_top.scale = Vector2(1,1)
	front_bottom.scale = Vector2(1,1)
	back_top.scale = Vector2(1,1)
	back_bottom.scale = Vector2(1,1)
