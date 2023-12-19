extends Node

var map

var ripple_i = 0
var ripple_plans = []
var ripple_item_ids = []


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
#
#
#
#
# - winda
# - balon
# - mysz?
# maybe cat is a lizard that holds on to the wall?
#
#
# Moze ruszanie tymi samymi typami obiektow razem? (albo typ-kolor or sth,
# albo jeden typ obiektu - mrowki, czy cos)
#
#
# Ale to później - na razie wypracować dobrze działanie obecnych typów itemów
#
#


var reactions = {
	"Ball": {
		"Ball": func(a, b):
			return func(): pass,
		"Mover": func(ball, mover):
			var mi = ball.i - mover.i
			var mj = ball.j - mover.j
			return func():
				print("Moving ball " + str(mi) + " " + str(mj) + " by mover " + str(mover.i) + " " + str(mover.j))
				ball.next_i += mi
				ball.next_j += mj
				return true,
		"Cat": func(ball, cat):
			return func(): pass,
		"Wall": func(ball, wall):
			return func():
				return,
		"Empty": func(ball, empty):
			return func():
				if ball.j < empty.j:
					print("ball falling")
					ball.next_j = ball.j + 1
					return true,
		"SideWalker": func(ball, side_walker):
			return func():
				if ball.j == side_walker.j:
					# print("walker bounce off ball")
					side_walker.prev_i = ball.i
					return true,
	},
	"Mover": {
		"Mover": func(mover1, mover2):
			return func():
				return,
		"Wall": func(a, b):
			return func(): pass,
		"Empty": func(a, b):
			return func(): pass,
		"SideWalker": func(mover, side_walker):
			return func():
				if mover.j == side_walker.j:
					# print("walker bounce off ball")
					side_walker.prev_i = mover.i
					return true
				else:
					side_walker.next_j = side_walker.j + side_walker.j - mover.j
					return true,
	},
	"Cat": {
		"Mover": func(cat, mover):
			var mi = cat.i - mover.i
			var mj = cat.j - mover.j
			return func():
				print("Moving cat")
				cat.next_i = cat.i + mi
				cat.next_j = cat.j + mj
				return true,
		"Cat": func(cat1, cat2):
			var mi = cat1.i - cat2.i
			var mj = cat1.j - cat2.j
			return func():
				if mi == 0:
					cat1.next_i += 1
					cat2.next_i += 1
					return true
				elif mj == 0:
					cat1.next_j += 1
					cat2.next_j += 1
					return true,
		"Wall": func(a, b):
			return func(): pass,
		"Empty": func(a, b):
			return func(): pass,
		"SideWalker": func(cat, side_walker):
			var cat_on = cat.j < side_walker.j
			return func():
				if cat_on:
					cat.next_i += side_walker.i - side_walker.prev_i
					return true,
	},
	"Wall": {
		"Wall": func(a, b):
			return func(): pass,
		"Empty": func(a, b):
			return func(): pass,
	},
	"SideWalker": {
		"Wall": func(walker, wall):
			# I should know here if anything is happening, planning before executing, no need for the return bools then...
			# I kind of want to rewrite this
			var same_j = walker.j == wall.j
			# var just_bounced = walker.just_bounced
			return func():
				if same_j:
					# print("walker bounce")
					walker.prev_i = wall.i
					return false,
		"Empty": func(walker, empty):
			return func():
				# print("walker check " + str(walker.prev_i) + " " + str(walker.i))
				if empty.j != walker.j:
					return
				if walker.prev_i <= walker.i && walker.i < empty.i:
					# print("walker plus")
					walker.next_i = walker.i + 1
				elif walker.prev_i > walker.i && walker.i > empty.i:
					# print("walker minus")
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
	
	for j in map.size - 1:
		for i in map.size - 1:
			prepare_ripple_plan(i, j)
			
	executed_some_plans = execute_ripple_plans()
	
	if executed_some_plans:
		print("executed some")
	else:
		print("NOT executed any")
	
	trigger_move()


func prepare_ripple_plan(ni, nj):
	prepare_ripple_plan_reaction(ni, nj, ni + 1, nj)
	prepare_ripple_plan_reaction(ni, nj, ni, nj + 1)


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
# - vacuum cleaner that pulls towards itself (looking farther than one field away - different design)
#
# - what about moves continuing? <--- THIS NOW
#
#
# 


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


var executed_some_plans = false


func execute_ripple_plans():
	var plan = []
	var some_executed = false
	for j in map.size:
		for i in map.size:
			plan = ripple_plans[j * map.size + i]
			#if plan.len() == 1:
			#	plan[0].call()
			for p in plan:
				if p.call():
					some_executed = true
	
	return some_executed


func empty_ripple_plans():
	for i in map.size * map.size:
		ripple_plans[i] = []



var t : float = 0.0


func animate(dt):
	if t >= 1.0:
		return
	
	t += dt
	if t > 1.0:
		t = 1.0
		
		for item in map.items:
			map.move_item(item, item.next_i, item.next_j)
		
		if executed_some_plans:
			run_from(0, 0)
	
	# print("animating " + str(t))
	
	for item in map.items:
		# print("item i j, ni nj: ", str(item.i) + " " + str(item.j) + ", " + str(item.next_i) + " " + str(item.next_j))
		item.position.x = (item.i * (1.0 - t) + item.next_i * t) * map.offset + map.offset
		item.position.y = (item.j * (1.0 - t) + item.next_j * t) * map.offset + map.offset


func trigger_move():
	print("trigger_move()")
	t = 0.0
