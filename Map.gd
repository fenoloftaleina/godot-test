extends Node

var map = []
var size = 10
var offset = 100

var empty_item = {
	"i": -1,
	"j": -1,
	"type": "Empty"
}

var id_i = -1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


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
	for j in size:
		for i in size:
			if !get_item(i, j):
				var new_empty = empty_item.duplicate()
				new_empty["id"] = next_id()
				set_item(i, j, new_empty)
