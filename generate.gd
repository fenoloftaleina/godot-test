extends Node2D

var img : Image
var sprite : Sprite2D

var n
var angles = []

var pos : Vector2
var velocity : Vector2
var angle_vector : Vector2

var particles = []
var points : PackedVector2Array

var t = 0.0
var ti


# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = get_node("/root/genartscene/Sprite2D")
	# await sprite.texture.changed
	img = sprite.texture.get_image()
	
	print(img.get_size())
	
	
	t = 0.0
	ti = 0
	
	n = img.get_size().x
	print("N: " + str(n))
	for j in range(n):
		for i in range(n):
			angles.append(img.get_pixel(i, j).r * 2 * PI)
	
	var color = Color.RED
	color.a = 0.5
	
	for i in range(1000):
		var particle = {}
		particle.pos = Vector2(randf() * 1000, randf() * 1000)
		particle.color = color
		particle.color += Color.WHITE * randf()
		particle.thickness = int((1 - particle.color.v) * randf() * 25 + 5)
		particle.velocity = particle.pos / 1000
		particle.points = PackedVector2Array([])
		particle.colors = PackedColorArray([])
		
		particles.append(particle)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t += delta
	
#	if t < 1:
#		return
#	else:
#		t = 0.0

	var m = 1000 / n
	for p in particles:
		var j = int((p.pos.y / 1000) * n)
		var i = int((p.pos.x / 1000) * n)
		var angle = angles[j * n + i]
		angle_vector = Vector2.from_angle(angle * (p.pos.x / 1000) * (p.pos.y / 1000))
		p.pos += angle_vector * m * 20 * delta
		p.color = img.get_pixel(i, j)
		
		if (p.pos.x < 0 || p.pos.y < 0 || p.pos.x > 1000 || p.pos.y > 1000):
			p.pos = Vector2(randf() * 1000, randf() * 1000)
			p.points.clear()
		
		p.points.append(p.pos)
		p.colors.append(p.color)
	
	queue_redraw()


var around : Vector2
var v1 : Vector2
var v2 : Vector2


func _draw():
#	var m = 1000 / n
#	for j in range(n):
#		for i in range(n):
#			v1.x = i * m
#			v1.y = j * m
#			v2 = v1 + Vector2.from_angle(angles[j * n + i]) * m
#			draw_line(v1, v2, Color.BLACK, 1, true)

	
	for p in particles:
#		draw_circle(p.pos, 2, Color.AQUAMARINE)
		draw_polyline_colors(p.points, p.colors, p.thickness, true)
		
#	for p in points:
#		draw_polyline(points, Color.AQUAMARINE, 1, true)



