extends Object

# difficulty levels
const EASY = "easy"
const NORMAL = "normal"
const HARD = "hard"
const NIGHTMARE = "nightmare"


const ROOM_EMPTY = "EM"
# room types
const E = "E"
const Entrance = "LTRB"
const L = "L"
const T = "T"
const R = "R"
const B = "B"
const LT = "LT"
const LR = "LR"
const LB = "LB"
const TR = "TR"
const TB = "TB"
const RB = "RB"
const LTR = "LTR"
const LTB = "LTB"
const TRB = "TRB"
const LRB = "LRB"
# every room which can be accesed from room with left exit
const left_neighbours = [R, LR, TR, RB, LTR, TRB, LRB]
# eveny room which can be accesed from room with top exit
const top_neighbours = [B, LB, TB, RB, LTB, TRB, LRB]
# every room which can be accesed from room with right exit
const right_neighbours = [L, LT, LR, LB, LTR, LTB, LRB]
# every room which can be accesed from room with bottom exit
const bot_neighbours = [T, LT, TR, TB, LTR, LTB, TRB] 

const ROOMS_100_60 = [LRB, TRB, LTB, LTR]
const ROOMS_60_45 = [LRB, TRB, LTB, LTR, RB, TB, TR, LB, LR, LT]
const ROOMS_45_10 = [RB, TB, TR, LB, LR, LT]
const ROOMS_10_0 = [B, R, T, L]


# grid sizes by difficulty
#const SIZES_EASY = [Vector2(3, 4), Vector2(3, 5), Vector2(4, 3), Vector2(4, 4), Vector2(5, 3)]
#const SIZES_NORMAL = [Vector2(4, 4), Vector2(4, 5), Vector2(4, 6), Vector2(5, 4), Vector2(5, 5), Vector2(6, 4)]
#const SIZES_HARD = [Vector2(5, 5), Vector2(5, 6), Vector2(5, 7), Vector2(6, 5), Vector2(6, 6), Vector2(7, 5)]
#const SIZES_NIGHTMARE = [Vector2(6, 6), Vector2(6, 7), Vector2(6, 8), Vector2(7, 6), Vector2(7, 7), Vector2(8, 6)]
const SIZES_EASY = [Vector2(3, 4), Vector2(4, 3)]
const SIZES_NORMAL = [Vector2(3, 5), Vector2(4, 4), Vector2(4, 5), Vector2(5, 3), Vector2(5, 4)]
const SIZES_HARD = [Vector2(4, 5), Vector2(5, 4), Vector2(5, 5), Vector2(5, 6), Vector2(6, 5)]
const SIZES_NIGHTMARE = [Vector2(6, 6), Vector2(6, 7),  Vector2(7, 6)]
const SIZES = { EASY: SIZES_EASY, NORMAL: SIZES_NORMAL, HARD: SIZES_HARD, NIGHTMARE: SIZES_NIGHTMARE }

const LEVELS_COUNT_EASY = [6, 9]
const LEVELS_COUNT_NORMAL = [8, 12]
const LEVELS_COUNT_HARD = [12, 16]
const LEVELS_COUNT_NIGHTMARE = [15, 20]
const LEVELS_COUNT = { EASY: LEVELS_COUNT_EASY, NORMAL: LEVELS_COUNT_NORMAL, HARD: LEVELS_COUNT_HARD, NIGHTMARE : LEVELS_COUNT_NIGHTMARE}

# variables
var floors = Array()
var difficulty



func generate(difficulty = NORMAL):
	self.difficulty = difficulty
	floors = _generate_floors()
	return floors


func _generate_floors():
	var floors = Array()
	# possible level count
	var plc = LEVELS_COUNT[difficulty]
	var number_of_floors = randi() % (plc[1] - plc[0]) + plc[0]
	for index in range(0, number_of_floors):
		rooms_to_process = Array()
		all_floor_rooms = Array()
		floors.append(_create_floor_scheme(index))
	return floors


var rooms_to_process = Array()
var all_floor_rooms = Array()
var rooms_to_remove_from_process = Array()

func _create_floor_scheme(floor_index):
	var floor_number = floor_index + 1
	var floor_scheme = Dictionary()
	
	var grid = _generate_floor_sheme(floor_number)
	var entrance = _get_floor_entrance(grid)
	var extreme = _get_floor_extreme(grid, entrance)
#	print(grid, extreme)

	var extreme_grid = _fix_extreme(grid, extreme)
	if extreme_grid:
		grid = extreme_grid["grid"]
		extreme = extreme_grid["extreme"]

	
	floor_scheme["entrance"] = entrance
	floor_scheme["extreme"] = extreme
	floor_scheme["floor_number"] = floor_number
	floor_scheme["rooms"] = _get_floor_other_rooms(grid, entrance, extreme)
	floor_scheme["total_size"] = all_floor_rooms.size()
	floor_scheme["grid"] = grid
	return floor_scheme

func _get_floor_entrance(grid):
	var x = 1
	var y = 1
	
	var r = 0
	for row in grid:
		var c = 0
		for col in row:
			if grid[r][c] == Entrance:
				y = r
				x = c
			c += 1
		r += 1
	return _create_room_dict(grid, x, y)

func _get_floor_extreme(grid, entrance):
	var epos = entrance.position
	
	var canditate_x = 0
	var canditate_y = 0
	
	var max_distance = 0
	
	var r = 0
	for row in grid:
		var c = 0
		for col in row:
			if col.length() == 1:
				var distance = Vector2(c, r).distance_to(epos)
				if distance > max_distance:
					max_distance = distance
					canditate_x = c
					canditate_y = r
			c += 1
		r += 1
	
	return _create_room_dict(grid, canditate_x, canditate_y)

func _get_floor_other_rooms(grid, entrance, extreme):
	var rooms = Array()
	var r = 0
	for row in grid:
		var c = 0
		for col in row:
			if _check_other_room(grid, c, r, entrance, extreme):
				rooms.append(_create_room_dict(grid, c, r))
			c += 1
		r += 1
	
	return rooms
	

func _check_other_room(grid, x, y, entrance, extreme):
	var room = grid[y][x]
	if room == "EM":
		return false
	if x == int(entrance.position.x) and y == int(entrance.position.y):
		return false
	if x == int(extreme.position.x) and y == int(extreme.position.y):
		return false
	return true


func _create_room_dict(grid, x, y):
	return {"position": Vector2(x, y), "type": grid[y][x]}






func _generate_floor_sheme(floor_number):
	var grid = _create_random_floor_grid()
	var width = grid[0].size()
	var height = grid.size()
	var entrance_pos = _get_random_entrance_position(width, height)
	_insert_room_into_grid(grid, Entrance, int(entrance_pos.x), int(entrance_pos.y))
	_generate_rooms(grid)
	_post_process_rooms(grid)
	return grid


# create random empty floor grid by choosen difficulty 
func _create_random_floor_grid():
	var sizes = SIZES[difficulty]
	var rand_size = sizes[randi() % sizes.size()]
	var size_x = int(rand_size.x)
	var size_y = int(rand_size.y)
	
	var grid = Array()
	for x in range(0, size_x):
		var row = Array()
		for y in range(0, size_y):
			row.append(ROOM_EMPTY)
		grid.append(row)
	
	return grid

# entrance cannot be at border of the grid
func _get_random_entrance_position(grid_width, grid_height):
	var x = randi() % (grid_width - 2) + 1
	var y = randi() % (grid_height - 2) + 1
	return Vector2(x, y)




func _get_random_room_type_by_grid_emptiness_and_neighbour(grid, neighbour):
	var total_size = grid[0].size() * grid.size()
	var all_rooms_size = all_floor_rooms.size()
	if all_rooms_size == 0:
		all_rooms_size = 1
	var emptiness = (total_size * 100.0) / (all_rooms_size * 1.0)
	
	var emptiness_rooms = ROOMS_10_0
	if emptiness >= 5:
		emptiness_rooms = ROOMS_45_10
	if emptiness >= 35:
		emptiness_rooms = ROOMS_60_45
	if emptiness >= 50:
		emptiness_rooms = ROOMS_100_60
	
	var neighbour_rooms = _get_neighbours_by_type(neighbour)
	
	var rooms = _get_room_types_intersection(emptiness_rooms, neighbour_rooms)
	return rooms[randi() % rooms.size()]


const NEIGHBOUR_POSITION_BY_TYPE = {L: Vector2(-1, 0), R: Vector2(1, 0), T: Vector2(0, -1), B: Vector2(0, 1)}

func _generate_neighbour(grid, room, neighbour):
	var nx = int(room.x + NEIGHBOUR_POSITION_BY_TYPE[neighbour].x)
	var ny = int(room.y + NEIGHBOUR_POSITION_BY_TYPE[neighbour].y)
	if _is_position_in_grid(grid, nx, ny):
		if _is_grid_position_empty(grid, nx, ny):
			var r = _get_random_room_type_by_grid_emptiness_and_neighbour(grid, neighbour)
			_insert_room_into_grid(grid, r, nx, ny)


func _generate_neighbours(grid, room):
	for label in room.type:
		_generate_neighbour(grid, room, label)


func _generate_rooms(grid):
	rooms_to_remove_from_process = Array()
	
	for index in range(0, rooms_to_process.size()):
		_generate_neighbours(grid, rooms_to_process[index])
		rooms_to_remove_from_process.append(index)
	
	var rooms = Array()
	for r in range(0, rooms_to_process.size()):
		if !(r in rooms_to_remove_from_process):
			rooms.append(rooms_to_process[r])
	
	rooms_to_process = rooms
	
	if rooms_to_process.size() > 0:
		_generate_rooms(grid)




func _insert_room_into_grid(grid, room_type, pos_x, pos_y):
	grid[int(pos_y)][int(pos_x)] = room_type
	rooms_to_process.append({"x": pos_x, "y": pos_y, "type": room_type})
	all_floor_rooms.append({"position": Vector2(pos_x, pos_y), "type": room_type})

func _is_grid_position_empty(grid, pos_x, pos_y):
	return grid[int(pos_y)][int(pos_x)] == ROOM_EMPTY

func _is_position_in_grid(grid, pos_x, pos_y):
	var width = grid[0].size()
	var height = grid.size()
	return pos_x > -1 and pos_x < width and pos_y > -1 and pos_y < height

const NEIGHBOUR_POSITION_BY_TYPE = {L: Vector2(-1, 0), R: Vector2(1, 0), T: Vector2(0, -1), B: Vector2(0, 1)}
func _can_insert_neighbour(grid, x, y, type):
	var nx = int(x + NEIGHBOUR_POSITION_BY_TYPE[type].x)
	var ny = int(y + NEIGHBOUR_POSITION_BY_TYPE[type].y)
	return _is_position_in_grid(grid, nx, ny) and _is_grid_position_empty(grid, nx, ny)


func _get_room_types_intersection(rooms_a, rooms_b):
	var rooms = Array()
	var shorter_array = rooms_a
	var longer_array = rooms_b
	if rooms_b.size() < rooms_a.size():
		shorter_array = rooms_b
		longer_array = rooms_a
	
	for room in shorter_array:
		if room in longer_array:
			rooms.append(room)
	
	return rooms

func _get_neighbours_by_type(type):
	if type == L:
		return left_neighbours
	elif type == T:
		return top_neighbours
	elif type == R:
		return right_neighbours
	else:
		return bot_neighbours
	




# post process
func _post_process_rooms(grid):
	_post_process_borders(grid)
	_post_process_neighbours(grid)



func _post_process_borders(grid):
	var width = grid[0].size()
	var height = grid.size()
	# replace top T and bottom
	for index in range(0, width):
		grid[0][index] = grid[0][index].replace(T, "")
		grid[height-1][index] = grid[height-1][index].replace(B, "")

	# replace L and R
	for index in range(0, height):
		grid[index][0] = grid[index][0].replace(L, "")
		grid[index][width - 1] = grid[index][width - 1].replace(R, "")


const OPOSITES = {L: R, R: L, T:B, B:T}
func _post_process_neighbours(grid):
	var r = 0
	for row in grid:
		var c = 0
		for col in row:
			if col != "EM":
				for type in col:
					var npos = Vector2(c, r) + NEIGHBOUR_POSITION_BY_TYPE[type]
					var ntype = grid[int(npos.y)][int(npos.x)]
					if !(OPOSITES[type] in ntype):
						grid[r][c] = grid[r][c].replace(type, '')
			c += 1
		r += 1


func _get_type_at_position(grid, x, y):
	return grid[y][x]





# fix for extreme
func _fix_extreme(grid, extreme):
	# step 0) check if extreme is already on exit room
	# step 1) check if extreme is neighbour entrance
	# step 2) choose one random extreme exit
	# step 3) remove other exits
	# step 4) post process from all removed neighbours
	
	# step 0)
	var ex_type = extreme.type
	if ex_type.length() == 1:
		return null
	
	# step 1)
	var entrance_neighbour_type = "";
	for type in ex_type:
		var pos = extreme.position + NEIGHBOUR_POSITION_BY_TYPE[type]
		var neighbour_type = _get_type_at_position(grid, int(pos.x), int(pos.y))
		if neighbour_type == Entrance:
			entrance_neighbour_type = type
	
	# step 2)
	var exit_to_remain = ""
	if entrance_neighbour_type.length() == 0:
		exit_to_remain = _fix_process_random_remaining_exit(grid, extreme)
	else:
		exit_to_remain = entrance_neighbour_type
	
	
	# step 3)
	var exits_to_remove = ex_type.replace(exit_to_remain, "")
	var ex_pos_x = int(extreme.position.x)
	var ex_pos_y = int(extreme.position.y)
	extreme.type = exit_to_remain
	grid[ex_pos_y][ex_pos_x] = exit_to_remain
	
	# step 4)
	for exit_type in exits_to_remove:
		var pos = extreme.position + NEIGHBOUR_POSITION_BY_TYPE[exit_type]
		var room_type = grid[int(pos.y)][int(pos.x)]
		var new_room_type = room_type.replace(OPOSITES[exit_type], "")
		grid[int(pos.y)][int(pos.x)] = new_room_type
		if new_room_type.length() == 0:
			grid[int(pos.y)][int(pos.x)] = ROOM_EMPTY
	
	
	return {"grid": grid, "extreme": extreme}


func _get_random_exit_to_remain(extreme_type):
	return extreme_type[randi() % extreme_type.length()]



func _fix_process_random_remaining_exit(grid, extreme):
	var not_possible_exits = ""
	for type in extreme.type:
		var pos = extreme.position + NEIGHBOUR_POSITION_BY_TYPE[type]
		var neighbour = _get_type_at_position(grid, int(pos.x), int(pos.y))
		if neighbour.length() == 1:
			not_possible_exits += OPOSITES[neighbour]
	
	var ex_type = extreme.type
	var remaining_type = ""
	for type in ex_type:
		if !(type in not_possible_exits) and remaining_type.length() == 0:
			remaining_type += type
	return remaining_type
	
