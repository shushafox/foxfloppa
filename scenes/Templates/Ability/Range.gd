extends Node2D

const CELL_SIZE = 48
const RECT_SIZE = 50
const RECT_COLOR = Color(255,2555,2555,0.5)

var rects: Array[ColorRect]
var time: float

func _process(delta: float) -> void:
	time += delta
	
	for rect in rects:
		rect.scale = Vector2.ONE * (abs(sin(time)))

func use(type: String, range: int) -> void:
	match type:
		"cross":
			_get_tiles(_get_cross(range))
		"line":
			_get_tiles(_get_line(range))
		"circle":
			_get_tiles(_get_circle(range))
		"square":
			_get_tiles(_get_square(range))
		_:
			print("ERROR: unrecognized range type")
	
	if RECT_SIZE % 2 == 0 && type == "line":
		for rect in rects:
			rect.position = rect.position + Vector2(-CELL_SIZE,0)
	
	for rect in rects:
		add_child(rect)

func _get_tiles(raster: Array):
	var rectangles: Array[ColorRect] = []
	
	for i in range(raster.size()):
		for j in range(raster[i].size()):
			if raster[i][j] == 1:
				# Calculate the position of the rectangle
				var position = Vector2(j * CELL_SIZE, i * CELL_SIZE) - (Vector2(RECT_SIZE * CELL_SIZE,RECT_SIZE * CELL_SIZE) / 2)
				
				# Create a ColorRect node
				var color_rect = ColorRect.new()
				color_rect.color = RECT_COLOR
				color_rect.size = Vector2(CELL_SIZE - 4,CELL_SIZE - 4)
				color_rect.position = position + Vector2(2,2)
				color_rect.pivot_offset = Vector2(CELL_SIZE / 2.0, CELL_SIZE / 2.0)
				
				# Add the ColorRect to the array
				rectangles.append(color_rect)
	
	rects = rectangles

func _get_cross(arm_length: int) -> Array:
	var center = RECT_SIZE / 2  # Center index of the raster

	# Initialize a 2D array filled with 0s
	var raster = []
	for i in range(RECT_SIZE):
		raster.append([])
		for j in range(RECT_SIZE):
			raster[i].append(0)

	# Fill the cross
	for i in range(RECT_SIZE):
		for j in range(RECT_SIZE):
			# Vertical line (within arm length)
			if j == center and abs(i - center) <= arm_length:
				raster[i][j] = 1
			# Horizontal line (within arm length)
			if i == center and abs(j - center) <= arm_length:
				raster[i][j] = 1
	
	return raster

func _get_circle(radius: int) -> Array:
	var center_x = RECT_SIZE / 2.0
	var center_y = RECT_SIZE / 2.0
	
	var raster = []
	for i in range(RECT_SIZE):
		raster.append([])
		for j in range(RECT_SIZE):
			raster[i].append(0)
	
	for i in range(RECT_SIZE):
		for j in range(RECT_SIZE):
			var distance = sqrt(pow(j - center_x, 2) + pow(i - center_y, 2))
			if distance <= radius - 1:
				raster[i][j] = 1
	
	return raster

func _get_line(lenght: int) -> Array:
	# Initialize a 2D array filled with 0s
	var raster = []
	for i in range(RECT_SIZE):
		raster.append([])
		for j in range(RECT_SIZE):
			raster[i].append(0)
	
	# Fill the line
	for i in range(RECT_SIZE):
		for j in range(RECT_SIZE):
			if i == RECT_SIZE / 2 && j - RECT_SIZE / 2 > 0 && j - RECT_SIZE / 2 <= lenght:
				raster[i][j] = 1
	
	return raster

func _get_square(size: int) -> Array:
	var center_x = RECT_SIZE / 2.0
	var center_y = RECT_SIZE / 2.0

	# Initialize grid
	var raster = []
	for i in range(RECT_SIZE):
		raster.append([])
		for j in range(RECT_SIZE):
			raster[i].append(0)
	
	# Fill the square
	for i in range(RECT_SIZE):
		for j in range(RECT_SIZE):
			var x = j - center_x
			var y = i - center_y
			
			# Check if within the square boundaries
			if abs(x) <= size - 0.5 and abs(y) <= size - 0.5:
				raster[i][j] = 1
	
	return raster
