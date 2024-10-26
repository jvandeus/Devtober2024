extends Node2D

var board_width := 6
var board_height := 10
var cell_size := 64

# these are set in board.gd
var line_color: Color
var bg_color: Color

func _draw() -> void:
	draw_rect(Rect2(0, 0, board_width * cell_size, board_height * cell_size), bg_color)
	for i in range(1, board_width):
		var x = i * cell_size
		draw_line(Vector2(x, 0), Vector2(x, board_height * cell_size), line_color)
	for i in range(1, board_height):
		var y = i * cell_size
		draw_line(Vector2(0, y), Vector2(board_width * cell_size, y), line_color)
