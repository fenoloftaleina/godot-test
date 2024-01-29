extends Node2D


var points : PackedVector2Array
var size : Vector2
var mid : Vector2
var pos : Vector2

var background_points : PackedVector2Array

var n = 8

func _ready():
#	points.append(Vector2(0, 0))
#	points.append(Vector2(100, 100))
	
	size = get_viewport().get_visible_rect().size
	mid = size / 2.0


func _input(event):
	if event is InputEventMouseMotion:
		if true: #points[-1].distance_squared_to(event.position) > 10000 || event.position.length_squared() < 10000:
			pos = event.position
			pos.x = pos.x - mid.x
			pos.y = mid.y - pos.y
			
#			points.append(Vector2(pos.x, pos.y) + mid)
#			points.append(Vector2(pos.x + mid.x, pos.y) + mid)
#			points.append(Vector2(pos.x + mid.x, pos.y - mid.y) + mid)
#			points.append(Vector2(pos.x, pos.y - mid.y) + mid)
			
			var angle = atan2(pos.y, pos.x)
			var new_angle
			var r = pos.length()
			# 72, 0.1 * PI
			var v = pos
#			print(str(v.x) + " " + str(v.y))
			points.append(event.position)
			
			background_points.clear()
			for i in range(n):
				new_angle = angle + 2 * PI * i / (n * 2)
				background_points.append(Vector2(cos(new_angle) * size.x, sin(new_angle) * size.y) + mid)
				background_points.append(Vector2(cos(PI + new_angle) * size.x, sin(PI + new_angle) * size.y) + mid)
			
			for i in range(n * 2):
				new_angle = angle + (i + 1) * PI * 2 / (n * 2)
				v = Vector2(cos(new_angle), sin(new_angle)) * r
#				print(str(v.x) + " " + str(v.y) + " angle->angle: " + str(angle) + " " + str(new_angle) + " r: " + str(r))
				v.x = v.x + mid.x
				v.y = mid.y - v.y
				points.append(v)
				points.append(v)
				
			points.append(event.position)
#			print("=============================")
			
			# pow(pos.x - mid.x, 2) + pow(pos.y - mid.y, 2) = pos.distance_squared_to(mid)


func _process(dt):
	if points.size() > (n + 1) * 2 * 10:
		points = points.slice((n + 1) * 2)
	
	queue_redraw()


func _draw():
#	draw_line(Vector2(0, 1000), Vector2(2000, 1000), Color.RED)
#	draw_line(Vector2(1000, 0), Vector2(1000, 2000), Color.RED)
#	draw_line(Vector2(0, 0), Vector2(2000, 2000), Color.RED)
#	draw_line(Vector2(2000, 0), Vector2(0, 2000), Color.RED)
	
	draw_multiline(background_points, Color.RED, 1.0)
	draw_multiline(points, Color.CADET_BLUE, 2.0)
