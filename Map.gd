extends Node

var map = []
var size = 12
var offset = 100

var empty_item = {
	"i": -1,
	"j": -1,
	"type": "Empty"
}

var id_i = -1
var t : float = 0.0


var items = []


func animate(dt):
	if t >= 1.0:
		return
	
	t += dt
	if t > 1.0:
		t = 1.0
		
		for item in items:
			move_item(item, item.next_i, item.next_j)
	
	for item in items:
		item.position.x = (item.i * (1.0 - t) + item.next_i * t) * 100 + offset
		item.position.y = (item.j * (1.0 - t) + item.next_j * t) * 100 + offset


func trigger_move():
	t = 0.0


func move_item(item, i, j):
	if i >= size || j >= size || i < 0 || j < 0 || get_item(i, j).type != "Empty":
		return
	set_item(item.i, item.j, get_item(i, j))
	item.prev_i = item.i
	item.prev_j = item.j
	set_item(i, j, item)
	item.position.x = i * 100 + offset
	item.position.y = j * 100 + offset


func set_item(i, j, o):
	o.prev_i = o.i
	o.prev_j = o.j
	o.i = i;
	o.j = j;
	o.next_i = i
	o.next_j = j
	map[j * size + i] = o


func get_item(i, j):
	return map[j * size + i]


func next_id():
	return ++id_i


func gather_items(map_node):
	map.resize(size * size)
	for child in map_node.get_children():
		child.id = next_id()
		set_item(int((child.position.x - offset) / 100), int((child.position.y - offset) / 100), child)
		child.prev_i = child.i
		child.prev_j = child.j
		
		items.append(child)
		
	for j in size:
		for i in size:
			if !get_item(i, j):
				var new_empty = empty_item.duplicate()
				new_empty["id"] = next_id()
				set_item(i, j, new_empty)
