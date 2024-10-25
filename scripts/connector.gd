class_name CableConnector
extends Node2D

func resize(ref_points: PackedVector2Array, board_width: int, board_height: int, cell_size: int):
	var size: Vector2 = Vector2(board_width * cell_size, board_height * cell_size)
	var ref_size: Vector2
	var offset_amount: Vector2
	
	# get the size of the reference (assuming its at origion)
	for point_i in ref_points.size()-1:
		if (abs(ref_points[point_i].x) > abs(ref_size.x)):
			ref_size.x = ref_points[point_i].x
		if (abs(ref_points[point_i].y) > abs(ref_size.y)):
			ref_size.y = ref_points[point_i].y
			
	# just use the the point that SHOULD be at the top of the reference box
	#var pos_ref = ref_points[0] + ((ref_points[5] - ref_points[0]) * 0.5)
	var pos_ref = self.position
	offset_amount = self.position - pos_ref
	# scale reference to new size
	pos_ref.x = size.x * (pos_ref.x / ref_size.x)
	pos_ref.y = size.y * (pos_ref.y / ref_size.y)
	# set the thing to the new position
	self.position = pos_ref + (offset_amount)
