extends Sprite2D

var t
var movement_speed = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	t = 0	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t += delta
	position.x = position.x + sin(t * 10) * 20 * delta
	position.y = position.y + sin(t * 10 + 100) * 20 * delta
	
	if Input.is_action_pressed("ui_down"):
		position.y += delta * movement_speed
	if Input.is_action_pressed("ui_up"):
		position.y -= delta * movement_speed
	if Input.is_action_pressed("ui_left"):
		position.x -= delta * movement_speed
	if Input.is_action_pressed("ui_right"):
		position.x += delta * movement_speed
