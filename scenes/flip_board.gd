class_name FlipBoard
extends CanvasItem

var tween
var digits: Array[FlipDigit]
var target_text
var queue: Array[int] = []
var current_index: int
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
	#print('set_display '+str(input))
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
	if (temp_queue.size() == 1):
		queue = temp_queue
		self.set_digit(0)
	elif (temp_queue.size() > 0):
		if tween:
			tween.kill() # Abort the previous animation.
		queue = temp_queue
		current_index = 0
		tween = self.create_tween()
		for i in queue.size():
			tween.tween_callback(set_digit.bind(i)).set_delay(delay)

func set_digit(index):
	#print('set_display['+str(index)+'] = '+target_text[queue[index]])
	self.digits[queue[index]].text = target_text[queue[index]]
	current_index += 1
