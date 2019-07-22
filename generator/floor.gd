extends Node2D

var E = preload("res://rooms/room_entrance.tscn").instance()

var L = preload("res://rooms/room_L.tscn").instance()
var T = preload("res://rooms/room_T.tscn").instance()
var R = preload("res://rooms/room_R.tscn").instance()
var B = preload("res://rooms/room_B.tscn").instance()

var LT = preload("res://rooms/room_LT.tscn").instance()
var LR = preload("res://rooms/room_LR.tscn").instance()
var LB = preload("res://rooms/room_LB.tscn").instance()
var TR = preload("res://rooms/room_TR.tscn").instance()
var TB = preload("res://rooms/room_TB.tscn").instance()
var RB = preload("res://rooms/room_RB.tscn").instance()

var LTR = preload("res://rooms/room_LTR.tscn").instance()
var LTB = preload("res://rooms/room_LTB.tscn").instance()
var LRB = preload("res://rooms/room_LRB.tscn").instance()
var TRB = preload("res://rooms/room_TRB.tscn").instance()


var all_rooms = Dictionary()


# all room wchich should be processed and then added to $rooms
var rooms_to_process = Array()

var extreme_room = null

func _ready():
#	randomize()
	all_rooms["all_list"] = [L, T, R, B, LT, LR, LB, TR, TB, RB, LTR, LTB, LRB, TRB]
	all_rooms["all_dict"] = {
		"L":L, "T":T, "R":R, "B":B, 
		"LT":LT, "LR":LR, "LB": LB, "TR":TR, "TB": TB, "RB":RB, 
		"LTR":LTR, "LTB":LTB, "LRB":LRB, "TRB":TRB
	}
	all_rooms["L"] = [L,L,L,L,L, LT,LT,LT, LR,LR,LR, LB,LB,LB, LTR, LTB, LRB]
	all_rooms["T"] = [T,T,T,T,T, LT,LT,LT, TR,TR,TR, TB,TB,TB, LTR, LTB, TRB]
	all_rooms["R"] = [R,R,R,R,R, LR,LR,LR, TR,TR,TR, RB,RB,RB, LTR, LRB, TRB]
	all_rooms["B"] = [B,B,B,B,B, LB,LB,LB, TB,TB,TB, RB,RB,RB, LTB, LRB, TRB]

	all_rooms["L2"] = [L, LT, LR, LB, LTR, LTB, LRB]
	all_rooms["T2"] = [T, LT, TR, TB, LTR, LTB, TRB]
	all_rooms["R2"] = [R, LR, TR, RB, LTR, LRB, TRB]
	all_rooms["B2"] = [B, LB, TB, RB, LTB, LRB, TRB]


	var entrance = E.duplicate()
	entrance.name = "entry_point"
	add_child(entrance)
	rooms_to_process.append(entrance)
	generate_rooms()




func generate_rooms():
	var processed_rooms = Array()
	var new_rooms = Array()
	for room in rooms_to_process:
		for ray in room.rays_to_process():
			var new_room = generate_room(room, ray)
			new_rooms.append(new_room)
		processed_rooms.append(room)
		
	for processed_room in processed_rooms:
		rooms_to_process.erase(processed_room)
	
	for new_room in new_rooms:
		if !rooms_to_process.has(new_room):
			rooms_to_process.append(new_room)
	
	if rooms_to_process.size() == 0:
		postprocess_rooms()
	else:
		generate_rooms()

func generate_room(origin, ray):
	var template = generate_random_room_template(ray.get_required_entrance())
	var room = template.duplicate()
	room.position = origin.position + ray.cast_to
	$rooms.add_child(room)
	return room

func generate_random_room_template(entrance):
	var chance = randi() % 100 + 1
	var size = 1
	var offset = 0
	
	if chance <= 60:
		size = 4
		offset = 1
	if chance <= 25:
		size = 3
		offset = 4
	
	var rooms_templates = all_rooms["%s2" % entrance]
	var template = rooms_templates[randi() % size + offset]
	return template

func postprocess_rooms():
	var rooms_to_change = Array()
	
	for room in $rooms.get_children():
#		print("=========================")		
		var possibles = room.get_rays_string()
		var should_change = false
		for ray in room.get_rays():
			var collider = ray.get_current_collider()
#			print(room.name, " ", ray.name, " ", collider.name)
#			print(collider.get_entrances())
			if collider != null:
				if !collider.has_entrance(ray.get_required_entrance()):
					room.modulate = Color(1, .5, .5, 1)
					possibles = possibles.replace(ray.ray_type, "")
					should_change = true
#		print(should_change, " ",possibles)
		if should_change:
			rooms_to_change.append({"room": room, "possible_type": possibles})
	
	for change in rooms_to_change:
		var rooms = $rooms.get_children();
		var index = rooms.find(change.room)
		var origin_room = rooms[index]
		rooms[index].queue_free()
		rooms.remove(index)
		var template = all_rooms.all_dict[change.possible_type]
		var new_room = template.duplicate()
		new_room.position = origin_room.position
		new_room.modulate = Color(1, .6, .2, 1)
		$rooms.add_child(new_room)
	
	select_boss_room()

# the farthest one entrance room from entry point
func select_boss_room():
	var distance = 0
	var extreme_room = $rooms.get_children()[0]
	for room in $rooms.get_children():
		if room.get_rays().size() == 1:
			var dist = room.position.distance_to($entry_point.position)
			if dist > distance:
				distance = dist
				extreme_room = room
	
	extreme_room.modulate = Color(1, .3, .3, 1)
	self.extreme_room = extreme_room
	



func get_rooms_count():
	return $rooms.get_child_count()
	
func get_boss_room():
	return extreme_room

func get_normal_rooms():
	var arr = Array()
	for room in $rooms.get_children():
		if room != extreme_room:
			arr.append(room)
	return arr

func get_floor_dictionary(floor_number = 1):
	var dict = Dictionary()
	dict["entrance"] = $entry_point.get_room_dictionary()
	dict["extreme"] = extreme_room.get_room_dictionary()
	
	var rooms = Array()
	for room in get_normal_rooms():
		rooms.append(room.get_room_dictionary())
	
	dict["rooms"] = rooms
	dict["total_size"] = rooms.size() + 2
	dict["floor_number"] = floor_number
	
	return dict
	