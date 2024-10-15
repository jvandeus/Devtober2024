class_name FlipBoard
extends CanvasItem

var tween
var digits: Array[FlipDigit]
var target_text
var queue: Array[int] = []
@export var delay: float = 0.1

@onready var digit_container: HBoxContainer = $DigitContainer

var text:
	get:
		return get_current() if digits.size() else ''
	set(value):
		set_display(value)

func get_current() -> String:
	var display = ''
	for i in self.digits.size():
		display = display + self.digits[i].text
	return display

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for digit: FlipDigit in digit_container.get_children():
		digits.push_back(digit)

func set_display(input) -> void:
	var format = ''
	var size = self.digits.size()
	var temp_queue: Array[int] = []
	if typeof(input) == TYPE_INT:
		format = "%0" + str(size) + "d"
	elif typeof(input) == TYPE_FLOAT:
		format = "%0" + str(size) + ".2f"
	elif typeof(input) == TYPE_STRING:
		format = "%" + str(size) + "s"
	else:
		format = "%" + str(size) + "s"
		input = ''
	target_text = format % input
	# set digits only if the are not set
	for i in size:
		if (self.digits[i].text != target_text[i]):
			#print (str(i) + " = " + self.digits[i].text + ' -> ' + target_text[i])
			temp_queue.push_back(i)
	if (temp_queue.size() > 0):
		if tween:
			tween.kill() # Abort the previous animation.
		queue = temp_queue
		tween = self.create_tween()
		tween.tween_method(set_digit, 0, queue.size()-1, 1).set_delay(delay)

func set_digit(index):
	self.digits[queue[index]].text = target_text[queue[index]]

func _input(event: InputEvent) -> void:
	var digit=null
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_0:
				digit = '000000'
			KEY_1:
				digit = 1
			KEY_2:
				digit = 'wwwwwwwwwww'
			KEY_3:
				digit = 121289370
			KEY_4:
				digit = 0
			KEY_5:
				digit = 9999121289370
			KEY_6:
				digit = 'Godot?'
			KEY_7:
				digit = 'More like'
			KEY_8:
				digit = 'GO DONT'
			KEY_9:
				digit = 'Heh'
		self.text = digit
