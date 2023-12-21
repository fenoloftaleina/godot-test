extends Node

var map = []
var size = 12
var offset = 100

var empty_item = {
	"i": -1,
	"j": -1,
	"types": ["Empty"]
}

var items = []

var id_i = -1


func move_item(item, i, j):
	if i >= size || j >= size || i < 0 || j < 0 || (item.i == i && item.j == j):
		# || get_item(i, j).type != "Empty": <--- to allow collisions/mutations
		return
	
	var other_item = get_item(i, j)
	if other_item.types[0] != "Empty":
		var types_set = {}
		for item_type in item.types:
			types_set[item_type] = null
		for other_item_type in other_item.types:
			types_set[other_item_type] = null 
		
		
		# TODO: add displaying two types (also make gather_items work with more items at the same spot)
		
		
		item.types = types_set.keys()
		remove_item(other_item)
		other_item.queue_free()
	
	set_item(item.i, item.j, empty_item.duplicate())
	
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


func remove_item(item):
	items.erase(item)
