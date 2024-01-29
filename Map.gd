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


func combine_types(item, other_item):
	var types_set = {}
	for item_type in item.types:
		types_set[item_type] = null
	for other_item_type in other_item.types:
		types_set[other_item_type] = null 
	
	item.types = types_set.keys()
	for child in other_item.get_children():
		item.add_child(child.duplicate())


func move_item(item, i, j):
	if i >= size || j >= size || i < 0 || j < 0 || (item.i == i && item.j == j):
		# || get_item(i, j).type != "Empty": <--- to allow collisions/mutations
		return
	
	var other_item = get_item(i, j)
	set_item(item.i, item.j, empty_item.duplicate())
	
	if other_item.types[0] == "Wall":
		#var temp
		#temp = item.next_i
		#item.next_i = item.i
		#item.i = temp
		#temp = item.next_j
		#item.next_j = item.j
		#item.j = temp
		
		
		# just die when hitting the wall for now
		remove_item(item)
		item.queue_free()
		
		
		# AAA, this could/should loop endlessly
		# Do I need a check for wall collisions before starting the move_item for anything?
		# What about collisions with other stuff?
		# Or bounce off a wall towards the side that depends on the walls around this wall?
		
		
	elif other_item.types[0] != "Empty":
			combine_types(item, other_item)
			remove_item(other_item)
			other_item.queue_free()
			set_item(i, j, item)
	else:
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
		var i = int((child.position.x - offset) / 100)
		var j = int((child.position.y - offset) / 100)
		var existing_item = get_item(i, j)
		if existing_item:
			combine_types(existing_item, child)
			child.queue_free()
		else:
			set_item(i, j, child)
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
