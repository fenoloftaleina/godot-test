extends Node

var map

var ripple_i = 0
var ripple_item_ids = []
var ripple_plans = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func init(_map):
	map = _map
	for i in map.size * map.size:
		ripple_plans.append([])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# rethink this, farther movement
# + crash reactions
#
# side walker mógłby mieć możliwość przesuwania tylko góra-dół
# a kot do końca w każdym kierunku i może rozwalić piłkę, jeżeli ją scrashuje w ścianę
#
# może jeszcze balon, który leci w górę,
# conveyor belt, który przewozi
# coś biegającego po przekątnej? z oznaczeniem, w którą stronę idzie
# winda?
# 
# cel gry: (?)
# klucz do następnego pokoju?
# przycisk do zrzucania jedzonka dla jakiegoś zwierza?
# pojedynek w "szachy"?


var reactions = {
	"Ball": {
		"Ball": func(a, b):
			return func(): pass,
		"Mover": func(a, b):
			return func(): pass,
		"Cat": func(a, b):
			return func():
				if a.j < b.j:
					a.j += 1,
		"Wall": func(a, b):
			return func(): pass,
		"Empty": func(a, b):
			return func():
				if a.j >= b.j:
					print("ball falling")
					map.move_item(a, a.i, a.j + 1)
					return true,
		"SideWalker": func(a, b):
			return func(): pass,
	},
	"Mover": {
		"Mover": func(a, b):
			var mi = b.i - a.i
			var mj = b.j - a.j
			return func():
				print("Moving " + str(b.i) + " " + str(b.j) + " by " + str(mi) + " " + str(mj))
				map.move_item(b, b.i + mi, b.j + mj)
				#map.move_item(a, a.i - mi, a.j - mj)
				return true,
		"Wall": func(a, b):
			return func(): pass,
		"Empty": func(a, b):
			return func(): pass,
		"SideWalker": func(a, b):
			return func(): pass,
	},
	"Cat": {
		"Mover": func(a, b):
			return func(): pass,
		"Cat": func(a, b):
			return func(): pass,
		"Wall": func(a, b):
			return func(): pass,
		"Empty": func(a, b):
			return func(): pass,
		"SideWalker": func(a, b):
			return func(): pass,
	},
	"Wall": {
		"Wall": func(a, b):
			return func(): pass,
		"Empty": func(a, b):
			return func(): pass,
	},
	"SideWalker": {
		"Wall": func(a, b):
			return func():
				print("walker bounce")
				a.prev_i = b.i
				return true,
		"Empty": func(a, b):
			return func():
				print("walker move")
				map.move_item(a, a.i + a.i - a.prev_i, a.j + a.j - a.prev_j)
				return true,
	},
}

func prepare_ripple_plan(ni, nj):
	if ni < map.size - 1:
		prepare_ripple_plan_reaction(ni, nj, ni + 1, nj)
	if nj < map.size - 1:
		prepare_ripple_plan_reaction(ni, nj, ni, nj + 1)
	if ni > 0:
		prepare_ripple_plan_reaction(ni, nj, ni - 1, nj)
	if nj > 0:
		prepare_ripple_plan_reaction(ni, nj, ni, nj - 1)


func run_from(start_i, start_j):
	# left to right, top to bottom
	
	
	#
	# TODO: i should fix this to go in circles
	#
	
	ripple(start_i, start_j)
	ripple(start_i, start_j)


func ripple(start_i, start_j):
	print()
	print("ripple:")
	
	empty_ripple_plans()
	
	for j in map.size:
		for i in map.size:
			if start_i + i < map.size && start_j + j < map.size:
				print("ripple plan " + str(start_i + i) + " " + str(start_j + j))
				prepare_ripple_plan(start_i + i, start_j + j)
			if start_i - i >= 0 && start_j - j >= 0 && !(i == 0 && j == 0):
				print("ripple plan " + str(start_i - i) + " " + str(start_j - j))
				prepare_ripple_plan(start_i - i, start_j - j)
	
	execute_ripple_plans()


func execute_ripple_plans():
	var plan = []
	var executed_some_plans = false
	for j in map.size:
		for i in map.size:
			plan = ripple_plans[j * map.size + i]
			#if plan.len() == 1:
			#	plan[0].call()
			for p in plan:
				if p.call():
					executed_some_plans = true
				
	return executed_some_plans


#
# TODO:
# mark a vector of where the thing goes in the plan (array of multiple plans, to show (in the future) what was about to happen
#
# try something
# ripples happen until they're over
#
# effect types (like translate, or change color, or whatever)
#
#
# teach a neural net to apply the rules?
#
#
#
#
#
# everything fires at the same time, movement is lerped


var items_ordered = []

func prepare_ripple_plan_reaction(ai, aj, bi, bj):
	items_ordered = [map.get_item(ai, aj), map.get_item(bi, bj)]
	# sort by type, "Empty" last
	
	if items_ordered[0].type == "Empty" && items_ordered[1].type == "Empty":
		return
	
	items_ordered.sort_custom(func(a, b):
		if a.type == "Empty":
			return false
		elif b.type == "Empty":
			return true
		else:
			return a.type < b.type)
	ripple_plans[aj * map.size + ai].append(reactions[items_ordered[0].type][items_ordered[1].type].call(items_ordered[0], items_ordered[1]))


func empty_ripple_plans():
	for i in map.size * map.size:
		ripple_plans[i] = []
