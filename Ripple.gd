extends Node

var map

var ripple_i = 0
var ripple_plans = []
var ripple_item_ids = []

var t : float


func init(_map):
	t = 0.0
	map = _map
	for i in map.size * map.size:
		ripple_plans.append([])


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
		"Mover": func(ball, mover):
			return func():
				if ball.j == mover.j:
					ball.next_i = ball.i + ball.i - mover.i
					return true
				elif ball.j < mover.j:
					ball.next_j = ball.j - 1
					return true,
		"Cat": func(a, b):
			return func():
				if a.j < b.j:
					a.j += 1,
		"Wall": func(a, b):
			return func(): pass,
		"Empty": func(ball, empty):
			return func():
				if ball.j < empty.j:
					print("ball falling")
					ball.next_j = ball.j + 1
					return true,
		"SideWalker": func(a, b):
			return func(): pass,
	},
	"Mover": {
		"Mover": func(mover1, mover2):
			var mi = mover2.i - mover2.i
			var mj = mover2.j - mover2.j
			return func():
				print("Moving " + str(mover2.i) + " " + str(mover2.j) + " by " + str(mi) + " " + str(mj))
				mover2.next_i = mover2.i + mi
				mover2.next_j = mover2.j + mj
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
		"Empty": func(walker, empty):
			return func():
				print("walker check " + str(walker.prev_i) + " " + str(walker.i))
				if empty.j != walker.j:
					return
				if walker.prev_i <= walker.i && walker.i < empty.i:
					print("walker plus")
					walker.next_i = walker.i + 1
				elif walker.prev_i > walker.i && walker.i > empty.i:
					print("walker minus")
					walker.next_i = walker.i - 1
					
				return true,
	},
}


func run_from(start_i, start_j):
	ripple(start_i, start_j)


func ripple(start_i, start_j):
	print()
	print("ripple:")
	
	# ripple_item_ids = []
	empty_ripple_plans()
	
	for j in map.size:
		for i in map.size:
			if start_i + i < map.size && start_j + j < map.size:
				prepare_ripple_plan(start_i + i, start_j + j)
			if start_i + i < map.size && start_j - j >= 0:
				prepare_ripple_plan(start_i + i, start_j - j)
			if start_i - i >= 0 && start_j + j < map.size:
				prepare_ripple_plan(start_i - i, start_j + j)
			if start_i - i >= 0 && start_j - j >= 0:
				prepare_ripple_plan(start_i - i, start_j - j)
	
	execute_ripple_plans()


func is_empty_ripple_plan(ni, nj):
	# if ni < 0 || ni >= map.size || nj < 0 || nj >= map.size:
	#  	return false
	return ripple_plans[nj * map.size + ni].is_empty()

func prepare_ripple_plan(ni, nj):
	if ni < map.size - 1 && is_empty_ripple_plan(ni + 1, nj):
		prepare_ripple_plan_reaction(ni, nj, ni + 1, nj)
	if nj < map.size - 1 && is_empty_ripple_plan(ni, nj + 1):
		prepare_ripple_plan_reaction(ni, nj, ni, nj + 1)
	if ni > 0 && is_empty_ripple_plan(ni - 1, nj):
		prepare_ripple_plan_reaction(ni, nj, ni - 1, nj)
	if nj > 0 && is_empty_ripple_plan(ni, nj - 1):
		prepare_ripple_plan_reaction(ni, nj, ni, nj - 1)


#
# NOTES:
# 
# something is happening
#
# TODO:
# - add more reactions
# - implement crash checks after movement is finished
#   - what if crashes are actually mutations - cause combinations of items - WOAH!
# 
# - what about moves continuing?


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


func empty_ripple_plans():
	for i in map.size * map.size:
		ripple_plans[i] = []
