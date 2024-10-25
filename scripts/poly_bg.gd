class_name PolygonBG
extends Polygon2D

func resize(ref_points: PackedVector2Array, board_width: int, board_height: int, cell_size: int):
	var size: Vector2 = Vector2(board_width * cell_size, board_height * cell_size)
	var ref_size: Vector2
	var offset_amount: Vector2
	
	# get the size of the reference (assuming its at origion)
	for point_i in ref_points.size()-1:
		if (ref_points[point_i].x > ref_size.x):
			ref_size.x = ref_points[point_i].x
		if (ref_points[point_i].y > ref_size.y):
			ref_size.y = ref_points[point_i].y
			
	# check if this tile is close to a one of our reference points.
	for point_i in ref_points.size():
		offset_amount = self.polygon[point_i] - ref_points[point_i]
		# scale reference to new size
		ref_points[point_i].x = size.x * (ref_points[point_i].x / ref_size.x)
		ref_points[point_i].y = size.y * (ref_points[point_i].y / ref_size.y)
		# set the polygon in new position
		self.polygon[point_i] = ref_points[point_i] + (offset_amount)
