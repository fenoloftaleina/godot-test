extends Node2D


var selected = null

var map = load("res://Map.gd").new()
var ripple = load("res://Ripple.gd").new()


# Called when the node enters the scene tree for the first time.
func _ready():
	ripple.init(map)
	map.gather_items(get_node("/root/Scene/Map"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ripple.animate(delta)
	
	if Input.is_action_just_released("left-click"):
		var mouse_position = get_viewport().get_mouse_position()
		var mouse_i = int((mouse_position.x + 50 - map.offset) / 100)
		var mouse_j = int((mouse_position.y + 50 - map.offset) / 100)
		var mouse_item
		if mouse_i >= 0 && mouse_i < map.size && mouse_j >= 0 && mouse_j < map.size:
			mouse_item = map.get_item(mouse_i, mouse_j)
		
		if !mouse_item:
			select(null)
		elif !selected:
			if mouse_item.type != "Empty":
				select(mouse_item)
		else:
			var potential_moves = [
				[selected.i - 1, selected.j],
				[selected.i, selected.j + 1],
				[selected.i, selected.j - 1],
				[selected.i + 1, selected.j]
			]
			var mouse_move = [mouse_i, mouse_j]
			
			if mouse_item.type == "Empty" && potential_moves.any(func(potential_move): return potential_move == mouse_move):
				# print(str(selected.i) + "-" + str(selected.j) + " to " + str(mouse_i) + "-" + str(mouse_j) + " " + mouse_item.type)
				selected.next_i = mouse_i
				selected.next_j = mouse_j
				select(null)
				
				ripple.run_from(mouse_i, mouse_j)
			elif mouse_item.type != "Empty":
				select(mouse_item)
			else:
				select(null)


func select(item):
	if item:
		selected = item
		position = selected.position
		visible = true
	else:
		selected = null
		visible = false
