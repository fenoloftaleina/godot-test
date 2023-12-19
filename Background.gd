extends Node2D

var size = 12
var offset = 100

@export var color1 : Color
@export var color2 : Color

func _draw():
	var colors = [color1, color2]
	for j in size:
		for i in size:
			draw_rect(Rect2(i * offset + 50, j * offset + 50, offset, offset), colors[(i + j) % 2])

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# queue_redraw()
	pass
