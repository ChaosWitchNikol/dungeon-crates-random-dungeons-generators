extends TileMap

const N = 1
const E = 2
const S = 4
const W = 8

var cell_walls = {Vector2(0, -1): N, Vector2(1, 0): E, Vector2(0, 1): S, Vector2(-1, 0): W}

var tile_size = 16

var width = 4
var height = 5
var erase_fraction = 0.1

var entrance = Vector2()
var extreme = Vector2()



func generate_floorv(sizes = Vector2(3, 3), erase_fraction = 0):
	return generate_floor(sizes.x, sizes.y, erase_fraction)

func generate_floor(width = 3, height = 3, erase_fraction = 0):
	self.width = int(width)
	self.height = int(height)
	self.erase_fraction = erase_fraction
	tile_size = self.cell_size
	choose_entrance()
	make_maze()
	erase_entrance_walls()
	erase_walls()
#	choose_extreme()
	create_outside_extreme()
#	print(entrance, extreme, entrance.distance_squared_to(extreme))
	return convert_tile_map_to_floor_layout()



func choose_entrance():
	var x = randi() % (width - 2) + 1
	var y = randi() % (height - 2) + 1
	entrance = Vector2(x, y)

func choose_extreme():
	var candidate = Vector2()
	var max_distance = 0
	for x in range(0, width):
		for y in range(0, height):
			var cell = Vector2(x, y)
			var c = get_cellv(cell)
			if c == 7 or c == 11 or c == 13 or c == 14:
				var distance = entrance.distance_squared_to(cell)
				if distance > max_distance:
					candidate = cell
					max_distance = distance
	
	if max_distance == 0:
		print("zero max distance:", max_distance)
		create_outside_extreme()
	else:
		extreme = candidate



func check_neighbors(cell, unvisited):
	var list = Array()
	for n in cell_walls.keys():
		if cell + n in unvisited:
			list.append(cell + n)
	return list

func make_maze():
	var unvisited = Array()
	var stack = Array()
	# fill map with solid tiles
	self.clear()
	for x in range(width):
		for y in range(height):
			unvisited.append(Vector2(x, y))
			self.set_cellv(Vector2(x, y), N|E|S|W)
	
	var current = entrance
	unvisited.erase(current)
	
	while unvisited:
		var neighbors = check_neighbors(current, unvisited)
		if neighbors.size() > 0:
			var next = neighbors[randi() % neighbors.size()]
			stack.append(current)
			var dir = next - current
			var current_walls = self.get_cellv(current) - cell_walls[dir]
			var next_walls = self.get_cellv(next) - cell_walls[-dir]
			self.set_cellv(current, current_walls)
			self.set_cellv(next, next_walls)
			current = next
			unvisited.erase(current)
		elif stack:
			current = stack.pop_back()

func erase_entrance_walls():
	var entrance_neighbors = Array()
	for n in cell_walls.keys():
		if get_cellv(entrance) & cell_walls[n]:
			var walls = get_cellv(entrance) - cell_walls[n]
			var n_walls = get_cellv(entrance + n) -  cell_walls[-n]
			set_cellv(entrance, walls)
			set_cellv(entrance + n, n_walls)


func select_random_cell():
	var x = int(rand_range(1, width - 1))
	var y = int(rand_range(1, height - 1))
	return Vector2(x, y)
	
func erase_walls():
	if !erase_fraction:
		return
	var val = int(width * height * erase_fraction)
	for i in range(val):
		var cell = select_random_cell()
		var neighbour = cell_walls.keys()[randi() % cell_walls.size()]
		if get_cellv(cell) & cell_walls[neighbour]:
			var walls = get_cellv(cell) - cell_walls[neighbour]
			var n_walls = get_cellv(cell + neighbour) -  cell_walls[-neighbour]
			set_cellv(cell, walls)
			set_cellv(cell + neighbour, n_walls)



func create_outside_extreme():
	var possible_cells = Array()
	for x in range(0, width):
		possible_cells.append(Vector2(x, -1))
		possible_cells.append(Vector2(x, height))
	for y in range(0, height):
		possible_cells.append(Vector2(-1, y))
		possible_cells.append(Vector2(width , y))
	
	# find furthers cell away from entrance
	var extreme_canditate = extreme
	var max_distance = 0
	for cell in possible_cells:
#		set_cellv(cell, N|E|S|W)
		var distance = entrance.distance_squared_to(cell)
		if distance > max_distance:
			extreme_canditate = cell
			max_distance = distance
	
	set_cellv(extreme_canditate, N|E|S|W)
	var neighbour = Vector2()
	for n in cell_walls.keys():
		var cell = get_cellv(extreme_canditate + n)
		if cell > -1:
			neighbour = extreme_canditate + n
	var e_walls = get_cellv(extreme_canditate) - cell_walls[neighbour - extreme_canditate]
	var n_walls = get_cellv(neighbour) - cell_walls[extreme_canditate - neighbour]
	set_cellv(extreme_canditate, e_walls)
	set_cellv(neighbour, n_walls)
	
	extreme = extreme_canditate
	


# left exit = doest not have West wall
const L = "L"
const T = "T"
const R = "R"
const B = "B"

###
#	L = NES
#	R = NSW
#	B = 
var exits = {
	0: L+T+R+B,
	N|E|S: L, E|S|W: T, N|S|W:R, N|E|W:B,
	N|E: L+B, N|S: L+R, N|W: R+B, E|S: L+T, E|W: T+B, S|W: T+R,
	N: L+R+B, E: L+T+B, S: L+T+R, W: T+R+B
}

func convert_tile_to_room(pos):
	var cell = get_cellv(pos)
	var type = ""
	if exits.has(cell):
		type = exits[cell]
	var shift_pos = pos - entrance
	return {"position": shift_pos, "type": type}

func convert_tile_map_to_floor_layout():
	var layout = Dictionary()
	layout["entrance"] = convert_tile_to_room(entrance)
	layout["extreme"] = convert_tile_to_room(extreme)
	
	var rooms = Array()
	for cell in get_used_cells():
		if cell != extreme and cell != entrance:
			rooms.append(convert_tile_to_room(cell))
	layout["rooms"] = rooms
	return layout
