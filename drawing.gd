extends Node2D


var points : Array
var size : Vector2
var mid : Vector2
var pos : Vector2
var angle : float
var new_angle : float
var r : float
var v : Vector2
var offset : int
var temp : PackedVector2Array
var colors : PackedColorArray
var temp_colors : PackedColorArray
var last_point : Vector2

var background_points : PackedVector2Array

var n = 8
var m = 50


func add_point(point):
	last_point = point
	pos = point
	pos.x = pos.x - mid.x
	pos.y = mid.y - pos.y
	
	angle = atan2(pos.y, pos.x)
	r = pos.length()
	v = pos
	
	points[0][offset] = point
	for i in range(1, n):
		new_angle = angle + i * PI * 2 / n
		v = Vector2(cos(new_angle), sin(new_angle)) * r
		v.x = v.x + mid.x
		v.y = mid.y - v.y
		points[i][offset] = v
		
	offset = (offset + 1) % m


func _ready():
	offset = 0
	
	size = get_viewport().get_visible_rect().size
	mid = size / 2.0
	
	var mouse_pos = get_viewport().get_mouse_position()

	for i in range(n):
		points.append(PackedVector2Array([]))
		
		for j in range(m):
			points[i].append(Vector2(0, 0))
	
	for j in range(m):
		temp.append(Vector2(0, 0))
	
	for i in range(m):
		add_point(mouse_pos)
	
	for i in range(m):
		colors.append(Color(0.85, 0.85, 0.85))
		temp_colors.append(colors[i])


func _input(event):
	if event is InputEventMouseMotion && event.position.distance_squared_to(last_point) > 50:
		add_point(event.position)


func _process(dt):
#	for i in range(n):
#		points[i] = points[i].slice(1)
	
	queue_redraw()


func _draw():
#	draw_line(Vector2(0, 1000), Vector2(2000, 1000), Color.RED)
#	draw_line(Vector2(1000, 0), Vector2(1000, 2000), Color.RED)
#	draw_line(Vector2(0, 0), Vector2(2000, 2000), Color.RED)
#	draw_line(Vector2(2000, 0), Vector2(0, 2000), Color.RED)
	
	for j in range(offset, m):
		temp_colors[j - offset] = colors[j]
		
	for j in range(offset):
		temp_colors[j + m - offset] = colors[j]
	
	for j in range(m):
		temp_colors[j].a = float(j) / m
	
	for i in range(n):
		for j in range(offset, m):
			temp[j - offset] = points[i][j]
			
		for j in range(offset):
			temp[j + m - offset] = points[i][j]

#		draw_polyline(points[i], Color.CADET_BLUE, 25.0, true)
		draw_polyline_colors(temp, temp_colors, 10.0, true)
